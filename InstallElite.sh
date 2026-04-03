#!/bin/bash
# INSTALADOR VPS-MX ORIGINAL (RESTORE + NO-KEY BYPASS)
# Versión: Original (Sin Bloqueo de Key)

# Configuración Inicial
export DEBIAN_FRONTEND=noninteractive
BASE_DIR="/etc/VPS-MX"
PROTO_DIR="$BASE_DIR/protocolos"

# Colores Estándar
RED='\e[31m' && GREEN='\e[32m' && YELLOW='\e[33m' && NC='\e[0m'

echo -e "${RED}RESTAURANDO VPS-MX ORIGINAL (SIN BLOQUEO DE KEY)...${NC}"

# 1. Limpiar Rastros Elite y Bloqueos de Key
echo "Limpiando bloqueos de licencia anteriores..."
rm -f /usr/bin/vps-mx &>/dev/null
rm -f /usr/bin/VPS-MX &>/dev/null
rm -f /usr/bin/elite &>/dev/null

# 2. Restaurar Directorios Base
mkdir -p "$BASE_DIR"
mkdir -p "$BASE_DIR/controlador"
mkdir -p "$PROTO_DIR"

# 3. Extraer Núcleo Original
if [[ -f "Files/VPS-MX.tar.xz" ]]; then
    tar -xf Files/VPS-MX.tar.xz -C "$BASE_DIR/"
    echo "Núcleo original extraído."
fi

# 4. Aplicar Bypass de Licencia
echo "Aplicando parches de licencia (No-Key)..."
# Copiar el menu parchado (Sin function_verify de Dropbox)
cp Decode/menu "$BASE_DIR/menu"
chmod +x "$BASE_DIR/menu"

# Copiar el ssl.sh parchado (Sin check_keyoficial de Dropbox)
cp Decode/ssl.sh "$PROTO_DIR/ssl.sh"
chmod +x "$PROTO_DIR/ssl.sh"

# Restaurar el resto de protocolos
cp -r protocolos/* "$PROTO_DIR/"
chmod +x "$PROTO_DIR"/*.sh

# 5. Crear Vínculos de Comandos (Limpios)
ln -sf "$BASE_DIR/menu" /usr/bin/menu
ln -sf "$BASE_DIR/menu" /usr/bin/vps-mx
ln -sf "$BASE_DIR/menu" /usr/bin/VPS-MX

# 6. Deshacer Cambios en Bashrc
sed -i '/elite/d' /root/.bashrc &>/dev/null
sed -i '/menu/d' /root/.bashrc &>/dev/null
echo '[[ -e /etc/VPS-MX/menu ]] && /etc/VPS-MX/menu' >> /root/.bashrc

echo -e "\n${GREEN}RESTAURACIÓN COMPLETADA CON ÉXITO.${NC}"
echo "El panel es original y el bloqueo de Key ha sido eliminado."
