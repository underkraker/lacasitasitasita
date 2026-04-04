#!/usr/bin/env python3

import sys
import socket
import ssl
import threading
import select

def handle_client(client_socket, target_host, target_port):
    backend_socket = None
    try:
        # First read from client to intercept HTTP payload
        client_socket.settimeout(10.0)
        data = client_socket.recv(8192)
        client_socket.settimeout(None)
        
        if not data:
            client_socket.close()
            return
            
        # Parse data to see if we need to spoof HTTP 101/200
        text_data = data.decode('utf-8', errors='ignore')
        initial_data = b""
        
        if text_data.startswith("GET ") or text_data.startswith("HTTP/"):
            # Spoof WS response
            client_socket.sendall(b"HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n")
        elif text_data.startswith("CONNECT ") or text_data.startswith("POST ") or text_data.startswith("PUT "):
            # Spoof Proxy response
            client_socket.sendall(b"HTTP/1.1 200 Connection Established\r\n\r\n")
        else:
            # Pure SSH traffic, pass it through directly
            initial_data = data
            
        # Connect to Backend (Dropbear/SSH)
        backend_socket = socket.create_connection((target_host, target_port))
        
        # Send initial data if it was pure SSH
        if initial_data:
            backend_socket.sendall(initial_data)
            
        sockets = [client_socket, backend_socket]
        while True:
            r, w, e = select.select(sockets, [], sockets, 300)
            if e or not r:
                break
            for sock in r:
                other = backend_socket if sock is client_socket else client_socket
                chunk = sock.recv(8192)
                if not chunk:
                    raise Exception("Closed")
                other.sendall(chunk)
                
    except Exception as e:
        pass
    finally:
        try: client_socket.close()
        except: pass
        if backend_socket:
            try: backend_socket.close()
            except: pass

def main():
    if len(sys.argv) < 6:
        print("Usage: python3 gateway.py <port> <cert> <key> <target_ip> <target_port>")
        sys.exit(1)
        
    listen_port = int(sys.argv[1])
    cert_file = sys.argv[2]
    key_file = sys.argv[3]
    target_ip = sys.argv[4]
    target_port = int(sys.argv[5])
    
    # Setup Modern SSL Context
    context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
    context.check_hostname = False
    context.verify_mode = ssl.CERT_NONE
    context.load_cert_chain(certfile=cert_file, keyfile=key_file)
    
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    # TCP tuning for injection speed
    server.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    
    server.bind(('0.0.0.0', listen_port))
    server.listen(500)
    
    print(f"WS+Direct SSL Gateway listening on {listen_port} -> {target_ip}:{target_port}")
    
    while True:
        try:
            client_socket, addr = server.accept()
            client_socket.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
            ssl_socket = context.wrap_socket(client_socket, server_side=True)
            threading.Thread(target=handle_client, args=(ssl_socket, target_ip, target_port), daemon=True).start()
        except Exception as e:
            pass

if __name__ == '__main__':
    main()
