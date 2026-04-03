#!/bin/bash
# INSTALADOR ELITE - VPS-MX MOD
# Autor: Antigravity AI Expert
# Versión: 1.0 (Elite Edition)

# 0. Instalar dependencias necesarias
echo "Verificando dependencias (net-tools, openssl)..."
if ! command -v netstat &> /dev/null || ! command -v openssl &> /dev/null; then
    echo "Instalando paquetes faltantes..."
    rm /var/lib/dpkg/lock-frontend > /dev/null 2>&1
    rm /var/lib/apt/lists/lock > /dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install net-tools openssl stunnel4 -y
else
    echo "Dependencias ya instaladas."
fi

# 1. Definir directorios
BASE_DIR="/etc/VPS-MX"
PROTO_DIR="$BASE_DIR/protocolos"

# Asegurar que los directorios existan
mkdir -p "$BASE_DIR"
mkdir -p "$PROTO_DIR"

# 2. Mover archivos a sus ubicaciones finales
echo "Instalando Dashboard Elite..."
cp menu_elite.sh "$BASE_DIR/menu_elite.sh"
chmod +x "$BASE_DIR/menu_elite.sh"

echo "Instalando Scripts Originales (Menu, Protocolos)..."
cp menu "$BASE_DIR/menu"
chmod +x "$BASE_DIR/menu"
cp -r protocolos/* "$PROTO_DIR/"
chmod +x "$PROTO_DIR"/*.sh
chmod +x "$PROTO_DIR"/*.py 2>/dev/null

echo "Instalando Scripts de Optimización..."
cp protocolos/tuning_elite.sh "$PROTO_DIR/tuning_elite.sh"
cp protocolos/ssl_elite.sh "$PROTO_DIR/ssl_elite.sh"
chmod +x "$PROTO_DIR/tuning_elite.sh"
chmod +x "$PROTO_DIR/ssl_elite.sh"

# 3. Crear accesos directos
echo "Configurando accesos directos ('menu', 'elite')..."
ln -sf /etc/VPS-MX/menu /usr/bin/menu
ln -sf /etc/VPS-MX/menu /usr/bin/vps-mx
ln -sf /etc/VPS-MX/menu /usr/bin/VPS-MX
ln -sf /etc/VPS-MX/menu_elite.sh /usr/bin/elite
ln -sf /etc/VPS-MX/menu_elite.sh /usr/bin/ELITE

# Verificar que el menú exista
if [ ! -f "/etc/VPS-MX/menu" ]; then
    echo "ERROR: No se encontró el archivo 'menu' en /etc/VPS-MX/"
fi

# 4. Aplicar Optimización del Sistema
echo "Aplicando BBR y Optimización de Red..."
/bin/bash "$PROTO_DIR/tuning_elite.sh"

# 5. Aplicar Optimización SSL (Opcional, pero recomendado)
# Nota: Esto modificará el archivo stunnel.conf para TLS 1.3
echo "Aplicando TLS 1.3 a Stunnel (SSL)..."
/bin/bash "$PROTO_DIR/ssl_elite.sh"

echo "————————————————————————————————————————————————————"
echo "  👑 UPGRADE ELITE (FASE 1) COMPLETADO 👑"
echo "————————————————————————————————————————————————————"
echo "  Escribe 'elite' en tu terminal para abrir el Dashboard."
echo "  El comando 'menu' original sigue funcionando igual."
echo "————————————————————————————————————————————————————"
