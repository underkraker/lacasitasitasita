#!/usr/bin/env python3

import sys
import socket
import select
from socketserver import ThreadingMixIn
from http.server import HTTPServer, BaseHTTPRequestHandler

class ThreadingHTTPServer(ThreadingMixIn, HTTPServer):
    address_family = socket.AF_INET
    daemon_threads = True

class SSLGatewayHandler(BaseHTTPRequestHandler):
    def do_CONNECT(self):
        target_port = int(sys.argv[4]) if len(sys.argv) > 4 else 80
        
        try:
            conn = socket.create_connection(('127.0.0.1', target_port))
        except Exception as e:
            self.send_error(502, f"Bad Gateway: {e}")
            return
            
        self.send_response(200, "Connection Established")
        self.end_headers()
        
        conns = [self.connection, conn]
        try:
            while True:
                rlist, wlist, xlist = select.select(conns, [], conns, 300)
                if xlist or not rlist:
                    break
                for r in rlist:
                    other = conns[1] if r is conns[0] else conns[0]
                    data = r.recv(8192)
                    if not data:
                        raise Exception("Connection closed")
                    other.sendall(data)
        except Exception:
            pass
        finally:
            conn.close()

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 443
    server_address = ('', port)
    httpd = ThreadingHTTPServer(server_address, SSLGatewayHandler)
    print(f"SSL Gateway proxy started on port {port}")
    httpd.serve_forever()
