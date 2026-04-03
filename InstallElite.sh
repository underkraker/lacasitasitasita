#!/bin/bash
# INSTALADOR ELITE - VPS-MX MOD
# Autor: Antigravity AI Expert
# Versión: 1.0 (Elite Edition)

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

echo "Instalando Scripts de Optimización..."
cp protocolos/tuning_elite.sh "$PROTO_DIR/tuning_elite.sh"
cp protocolos/ssl_elite.sh "$PROTO_DIR/ssl_elite.sh"
chmod +x "$PROTO_DIR/tuning_elite.sh"
chmod +x "$PROTO_DIR/ssl_elite.sh"

# 3. Crear accesos directos (Comando Secundario)
echo "Configurando acceso secundario 'elite'..."
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
