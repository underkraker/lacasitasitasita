#!/bin/bash
# OPTIMIZADOR ELITE - SSL (TLS 1.3 MOD)
# Autor: Antigravity AI Expert
# Versión: 1.0 (Elite Edition)

STUNNEL_CONF="/etc/stunnel/stunnel.conf"
STUNNEL_DIR="/etc/stunnel"

# Asegurar que stunnel4 esté instalado y el directorio exista
if [ ! -d "$STUNNEL_DIR" ]; then
    echo "Instalando Stunnel4..."
    apt-get update > /dev/null 2>&1
    apt-get install stunnel4 -y > /dev/null 2>&1
    mkdir -p "$STUNNEL_DIR"
fi

# Generar certificado auto-firmado si no existe
if [ ! -f "$STUNNEL_DIR/stunnel.pem" ]; then
    echo "Generando certificado certificado para SSL..."
    openssl genrsa -out "$STUNNEL_DIR/stunnel.pem" 2048 > /dev/null 2>&1
    openssl req -new -x509 -key "$STUNNEL_DIR/stunnel.pem" -out "$STUNNEL_DIR/stunnel.pem" -days 365 -subj "/C=MX/ST=CDMX/L=CDMX/O=VPS-MX/OU=Elite/CN=VPS-MX" > /dev/null 2>&1
fi

# Backup de la configuración actual
if [ -f "$STUNNEL_CONF" ]; then
    cp "$STUNNEL_CONF" "${STUNNEL_CONF}.bak"
fi

# Generar nueva configuración Optimizada para TLS 1.3
cat <<EOF > "$STUNNEL_CONF"
# Global Options
cert = /etc/stunnel/stunnel.pem
key = /etc/stunnel/stunnel.pem
foreground = no
debug = notice
pid = /var/run/stunnel.pid

# Performance Optimizations
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[stunnel-ssl]
accept = 443
connect = 127.0.0.1:80
sslVersionMin = TLSv1.3
sslVersionMax = TLSv1.3
ciphersuites = TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384
options = NO_COMPRESSION
options = NO_TICKET
EOF

# Reiniciar servicio
service stunnel4 restart > /dev/null 2>&1
systemctl restart stunnel4 > /dev/null 2>&1

echo "Configuración SSL Elite (TLS 1.3 + TCP_NODELAY) aplicada."
