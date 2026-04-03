#!/bin/bash
# INSTALADOR VPS-MX ORIGINAL (RESTORE)
# Versión: Original (Sin Modificaciones Elite)

# Configuración Inicial
export DEBIAN_FRONTEND=noninteractive
BASE_DIR="/etc/VPS-MX"
PROTO_DIR="$BASE_DIR/protocolos"

# Colores Estándar
RED='\e[31m' && GREEN='\e[32m' && YELLOW='\e[33m' && NC='\e[0m'

echo -e "${RED}RESTAURANDO VPS-MX AL ESTADO ORIGINAL...${NC}"

# 1. Limpiar Rastros Elite
echo "Eliminando componentes Elite..."
rm -f /usr/bin/elite &>/dev/null
rm -f "$BASE_DIR/menu_elite.sh" &>/dev/null
rm -f "$PROTO_DIR/ssl_elite.sh" &>/dev/null
rm -f "$PROTO_DIR/tuning_elite.sh" &>/dev/null

# 2. Restaurar Directorios Base
mkdir -p "$BASE_DIR"
mkdir -p "$BASE_DIR/controlador"
mkdir -p "$PROTO_DIR"

# 3. Extraer Núcleo Original (Sin parches de Handshake)
if [[ -f "Files/VPS-MX.tar.xz" ]]; then
    tar -xf Files/VPS-MX.tar.xz -C "$BASE_DIR/"
    echo "Núcleo original restaurado."
fi

# 4. Restaurar Scripts Originales (Copiados del repo limpio)
cp menu "$BASE_DIR/menu"
cp -r protocolos/* "$PROTO_DIR/"
chmod +x "$BASE_DIR/menu"
chmod +x "$PROTO_DIR"/*.sh

# 5. Deshacer Cambios en Bashrc
sed -i '/elite/d' /root/.bashrc &>/dev/null
sed -i '/menu/d' /root/.bashrc &>/dev/null
echo '[[ -e /etc/VPS-MX/menu ]] && /etc/VPS-MX/menu' >> /root/.bashrc

# 6. Reinstalar Puertos Originales (Interactivos)
echo -e "${YELLOW}¿Deseas ejecutar el instalador original ahora?${NC}"
read -p " [S/N]: " run_orig
if [[ "$run_orig" =~ ^[Ss]$ ]]; then
    /bin/bash "$BASE_DIR/menu"
fi

echo "RESTAURACIÓN COMPLETADA. EL PANEL ES AHORA EL ORIGINAL."
