#!/bin/bash
# OPTIMIZADOR ELITE - SSL (TLS 1.2+ MOD)
# Autor: Antigravity AI Expert
# Versión: 2.0 (Elite Gateway Edition)

STUNNEL_CONF="/etc/stunnel/stunnel.conf"
STUNNEL_DIR="/etc/stunnel"

# Asegurar que stunnel4 esté instalado
if [ ! -d "$STUNNEL_DIR" ]; then
    apt-get update > /dev/null 2>&1
    apt-get install stunnel4 -y > /dev/null 2>&1
    mkdir -p "$STUNNEL_DIR"
fi

# Generar certificado auto-firmado
if [ ! -f "$STUNNEL_DIR/stunnel.pem" ]; then
    openssl genrsa -out "$STUNNEL_DIR/stunnel.pem" 2048 > /dev/null 2>&1
    openssl req -new -x509 -key "$STUNNEL_DIR/stunnel.pem" -out "$STUNNEL_DIR/stunnel.pem" -days 3650 -subj "/C=MX/ST=CDMX/L=CDMX/O=VPS-MX/OU=Elite/CN=VPS-MX" > /dev/null 2>&1
fi

# Nueva configuración Optimizada para WebSockets
cat <<EOF > "$STUNNEL_CONF"
# Global Options
cert = /etc/stunnel/stunnel.pem
key = /etc/stunnel/stunnel.pem
pid = /var/run/stunnel.pid
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[stunnel-ssl]
accept = 443
# IMPORTANTE: Conectamos al Proxy Python (8799) no al SSH directo
connect = 127.0.0.1:8799
sslVersionMin = TLSv1.2
options = NO_COMPRESSION
EOF

# Reiniciar servicio
systemctl restart stunnel4 > /dev/null 2>&1
service stunnel4 restart > /dev/null 2>&1

echo "Configuración SSL Elite Gateway (TLS 1.2+ -> Proxy:8799) aplicada."
