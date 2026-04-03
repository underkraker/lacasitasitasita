#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import http.client
from socketserver import ThreadingMixIn
from http.server import HTTPServer, BaseHTTPRequestHandler
from threading import Lock, Timer
from io import BytesIO
from urllib.parse import urlsplit
import socket
import select
import gzip
import zlib
import re
import traceback

# Configuración de respuesta estándar para apps como HTTP Custom
STATUS_200 = "Connection Established"

class ThreadingHTTPServer(ThreadingMixIn, HTTPServer):
    address_family = socket.AF_INET
    daemon_threads = True

    def handle_error(self, request, client_address):
        print('-'*40, file=sys.stderr)
        print(f'Error en conexión desde {client_address}', file=sys.stderr)
        traceback.print_exc()
        print('-'*40, file=sys.stderr)

class ThreadingHTTPServer6(ThreadingHTTPServer):
    address_family = socket.AF_INET6

class SimpleHTTPProxyHandler(BaseHTTPRequestHandler):
    global_lock = Lock()
    conn_table = {}
    timeout = 300               
    upstream_timeout = 300    
    proxy_via = None          
    
    # Optimizamos el buffer para mejorar latencia en apps de inyección
    BUFFER_SIZE = 32768 # 32KB

    def log_error(self, format, *args):
        if format == "Request timed out: %r":
            return
        self.log_message(format, *args)

    def do_CONNECT(self):
        """Maneja túneles SSL/TLS para apps como HTTP Custom"""
        req = self
        req.path = "https://%s/" % req.path.replace(':443', '')

        u = urlsplit(req.path)
        address = (u.hostname, u.port or 443)
        
        try:
            conn = socket.create_connection(address, timeout=10)
        except socket.error:
            self.send_error(502, "Bad Gateway")
            return

        # Respuesta ESTÁNDAR 200 para evitar detección de DPI por el ISP
        self.send_response(200, STATUS_200)
        self.send_header('Proxy-Agent', 'VPS-MX-Elite/1.0')
        self.end_headers()

        conns = [self.connection, conn] 
        keep_connection = True
        while keep_connection:
            keep_connection = False
            rlist, wlist, xlist = select.select(conns, [], conns, self.timeout)
            if xlist:
                break
            for r in rlist:
                other = conns[1] if r is conns[0] else conns[0]
                try:
                    data = r.recv(self.BUFFER_SIZE)
                    if data:
                        other.sendall(data)
                        keep_connection = True
                except Exception:
                    break
        conn.close()

    def do_GET(self):
        self.do_SPAM()

    def do_POST(self):
        self.do_SPAM()

    def do_HEAD(self):
        self.do_SPAM()

    def do_SPAM(self):
        """Maneja peticiones HTTP con soporte para modificación de headers"""
        req = self
        content_length = int(req.headers.get('Content-Length', 0))
        reqbody = self.rfile.read(content_length) if content_length > 0 else None

        # Handlers para futuras inyecciones (Payloads)
        replaced_reqbody = self.request_handler(req, reqbody)
        if replaced_reqbody is True:
            return
        elif replaced_reqbody is not None:
            reqbody = replaced_reqbody
            if 'Content-Length' in req.headers:
                req.headers['Content-Length'] = str(len(reqbody))

        self.remove_hop_by_hop_headers(req.headers)
        req.headers['Connection'] = 'Keep-Alive' if self.upstream_timeout else 'close'

        try:
            res, resdata = self.request_to_upstream_server(req, reqbody)
        except Exception:
            return

        content_encoding = res.headers.get('Content-Encoding', 'identity')
        resbody = self.decode_content_body(resdata, content_encoding)

        replaced_resbody = self.response_handler(req, reqbody, res, resbody)
        if replaced_resbody is True:
            return
        elif replaced_resbody is not None:
            resdata = self.encode_content_body(replaced_resbody, content_encoding)
            if 'Content-Length' in res.headers:
                res.headers['Content-Length'] = str(len(resdata))
            resbody = replaced_resbody

        self.remove_hop_by_hop_headers(res.headers)
        res.headers['Connection'] = 'Keep-Alive' if self.timeout else 'close'

        self.send_response(res.status, res.reason)
        for k, v in res.headers.items():
            if k.lower() != 'set-cookie':
                self.send_header(k, v)
            else:
                for value in self.split_set_cookie_header(v):
                    self.send_header(k, value)
        self.end_headers()

        if self.command != 'HEAD':
            self.wfile.write(resdata)

    def request_to_upstream_server(self, req, reqbody):
        u = urlsplit(req.path)
        origin = (u.scheme, u.netloc)
        req.headers['Host'] = u.netloc
        selector = "%s?%s" % (u.path, u.query) if u.query else u.path

        while True:
            with self.lock_origin(origin):
                conn = self.open_origin(origin)
                try:
                    conn.request(req.command, selector, reqbody, headers=dict(req.headers))
                except socket.error:
                    self.close_origin(origin)
                    raise
                try:
                    res = conn.getresponse()
                except http.client.BadStatusLine as e:
                    if e.line == "''":
                        self.close_origin(origin)
                        continue
                    else:
                        raise
                resdata = res.read()
                res.headers = res.msg    
                if not self.upstream_timeout or 'close' in res.headers.get('Connection', ''):
                    self.close_origin(origin)
                else:
                    self.reset_timer(origin)
            return res, resdata

    def lock_origin(self, origin):
        d = self.conn_table.setdefault(origin, {})
        if 'lock' not in d:
            d['lock'] = Lock()
        return d['lock']

    def open_origin(self, origin):
        conn = self.conn_table[origin].get('connection')
        if not conn:
            scheme, netloc = origin
            if scheme == 'https':
                conn = http.client.HTTPSConnection(netloc)
            else:
                conn = http.client.HTTPConnection(netloc)
            self.reset_timer(origin)
            self.conn_table[origin]['connection'] = conn
        return conn

    def reset_timer(self, origin):
        timer = self.conn_table[origin].get('timer')
        if timer:
            timer.cancel()
        if self.upstream_timeout:
            timer = Timer(self.upstream_timeout, self.close_origin, args=[origin])
            timer.daemon = True
            timer.start()
        else:
            timer = None
        self.conn_table[origin]['timer'] = timer

    def close_origin(self, origin):
        timer = self.conn_table[origin].get('timer', None)
        if timer:
            timer.cancel()
        conn = self.conn_table[origin].get('connection', None)
        if conn:
            conn.close()
            del self.conn_table[origin]['connection']

    def remove_hop_by_hop_headers(self, headers):
        hop_by_hop = ['connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization', 'te', 'trailers', 'trailer', 'transfer-encoding', 'upgrade']
        for k in list(headers.keys()):
            if k.lower() in hop_by_hop:
                del headers[k]

    def decode_content_body(self, data, content_encoding):
        if content_encoding in ('gzip', 'x-gzip'):
            io = BytesIO(data)
            with gzip.GzipFile(fileobj=io) as f:
                body = f.read()
        elif content_encoding == 'deflate':
            body = zlib.decompress(data)
        else:
            body = data
        return body

    def encode_content_body(self, body, content_encoding):
        if content_encoding in ('gzip', 'x-gzip'):
            io = BytesIO()
            with gzip.GzipFile(fileobj=io, mode='wb') as f:
                f.write(body)
            data = io.getvalue()
        elif content_encoding == 'deflate':
            data = zlib.compress(body)
        else:
            data = body
        return data

    def split_set_cookie_header(self, value):
        re_cookies = r'([^=]+=[^,;]+(?:;\s*Expires=[^,]+,[^,;]+|;[^,;]+)*)(?:,\s*)?'
        return re.findall(re_cookies, value, flags=re.IGNORECASE)

    def request_handler(self, req, reqbody):
        pass

    def response_handler(self, req, reqbody, res, resbody):
        pass

def run_server(HandlerClass=SimpleHTTPProxyHandler, ServerClass=ThreadingHTTPServer, protocol="HTTP/1.1"):
    port = int(sys.argv[1]) if sys.argv[1:] else 8799
    server_address = ('', port)
    HandlerClass.protocol_version = protocol
    httpd = ServerClass(server_address, HandlerClass)
    print(f"Proxy Elite iniciado en puerto {port}...")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nApagando servidor...")
        httpd.server_close()

if __name__ == '__main__':
    run_server()
