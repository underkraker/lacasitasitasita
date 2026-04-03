#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# PROXY ELITE WEBSOCKET GATEWAY V2.0
# Autor: Antigravity AI Expert
# Optimizador para HTTP Custom y WebSocket Over SSH

import sys
import socket
import threading
import select

# Configuración
LISTENING_PORT = 8799
SSH_HOST = '127.0.0.1'
SSH_PORT = 80  # Puerto de Dropbear/SSH
BUFFER_SIZE = 32768  # 32KB para alta velocidad

def handle_client(client_socket):
    try:
        # Recibir la primera parte de la petición (Handshake)
        data = client_socket.recv(BUFFER_SIZE)
        if not data:
            client_socket.close()
            return

        request = data.decode('utf-8', errors='ignore')
        
        # Detectar si es una petición WebSocket o HTTP Direct
        if "Upgrade: websocket" in request or "GET / HTTP/1.1" in request:
            # Responder con Handshake Exitoso para engañar al ISP/DPI
            # Usamos 101 Switching Protocols para WebSockets
            if "Upgrade: websocket" in request:
                response = "HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n"
            else:
                response = "HTTP/1.1 200 Connection Established\r\n\r\n"
            
            client_socket.sendall(response.encode('utf-8'))
        
        # Conectar al SSH Local (Backend)
        ssh_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        ssh_socket.connect((SSH_HOST, SSH_PORT))
        
        # Iniciar el puente de datos (Bridge)
        sockets = [client_socket, ssh_socket]
        while True:
            r, w, e = select.select(sockets, [], sockets, 300)
            if e:
                break
            for sock in r:
                data = sock.recv(BUFFER_SIZE)
                if not data:
                    break
                if sock is client_socket:
                    ssh_socket.sendall(data)
                else:
                    client_socket.sendall(data)
            else:
                continue
            break
            
    except Exception as e:
        pass
    finally:
        client_socket.close()
        try:
            ssh_socket.close()
        except:
            pass

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    # Escuchar en todas las interfaces
    try:
        server.bind(('0.0.0.0', LISTENING_PORT))
    except socket.error as e:
        print(f"Error al iniciar Proxy: {e}")
        sys.exit(1)
        
    server.listen(100)
    print(f"Elite WebSocket Gateway activo en puerto {LISTENING_PORT} -> SSH:{SSH_PORT}")
    
    while True:
        client_sock, addr = server.accept()
        thread = threading.Thread(target=handle_client, args=(client_sock,))
        thread.daemon = True
        thread.start()

if __name__ == '__main__':
    main()
