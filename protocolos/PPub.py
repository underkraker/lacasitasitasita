#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# PROXY ELITE - VPS-MX ORIGINAL (MIGRADO A PYTHON 3)
# Versión: Original (Sin Handshakes WebSocket)

import sys
import os
import socket
import select
import threading

# Configuración
LISTENING_PORT = 8799
BUFFER_SIZE = 32768  # 32KB

def handle_connection(client_socket):
    try:
        # Petición inicial (Direct/HTTP)
        data = client_socket.recv(BUFFER_SIZE)
        if not data:
            client_socket.close()
            return
            
        # Puentear a SSH Local (Dropbear)
        ssh_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        ssh_socket.connect(('127.0.0.1', 80))
        
        # Enviar primer bloque (Payload)
        ssh_socket.sendall(data)
        
        # Iniciar Bridge de datos
        sockets = [client_socket, ssh_socket]
        while True:
            r, w, e = select.select(sockets, [], sockets, 300)
            if e: break
            for sock in r:
                data = sock.recv(BUFFER_SIZE)
                if not data: break
                other = ssh_socket if sock is client_socket else client_socket
                other.sendall(data)
            else: continue
            break
            
    except Exception:
        pass
    finally:
        client_socket.close()
        try: ssh_socket.close()
        except: pass

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('0.0.0.0', LISTENING_PORT))
    server.listen(100)
    print(f"Proxy Original iniciado en puerto {LISTENING_PORT}")
    
    while True:
        client_sock, addr = server.accept()
        threading.Thread(target=handle_connection, args=(client_sock,), daemon=True).start()

if __name__ == '__main__':
    main()
