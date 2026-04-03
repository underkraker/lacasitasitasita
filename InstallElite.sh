#!/bin/bash
# INSTALADOR ELITE - VPS-MX MOD
# Autor: Antigravity AI Expert
# Versión: 1.0 (Elite Edition)

# 0. Instalar dependencias necesarias
echo "Verificando dependencias (net-tools, openssl)..."
apt-get update > /dev/null 2>&1
apt-get install net-tools openssl -y > /dev/null 2>&1

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
echo "/etc/VPS-MX/menu" > /usr/bin/menu && chmod +x /usr/bin/menu
echo "/etc/VPS-MX/menu" > /usr/bin/vps-mx && chmod +x /usr/bin/vps-mx
echo "/etc/VPS-MX/menu" > /usr/bin/VPS-MX && chmod +x /usr/bin/VPS-MX
echo "/etc/VPS-MX/menu_elite.sh --loop" > /usr/bin/elite && chmod +x /usr/bin/elite
echo "/etc/VPS-MX/menu_elite.sh --loop" > /usr/bin/ELITE && chmod +x /usr/bin/ELITE

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
