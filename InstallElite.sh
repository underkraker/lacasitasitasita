#!/bin/bash
# FULL ELITE AUTOMATOR V4.2 (WEBSOCKET GATEWAY) - VPS-MX MOD
# Autor: Antigravity AI Expert
# Versión: 4.2 (Elite Master)

# Configuración Inicial
export DEBIAN_FRONTEND=noninteractive
BASE_DIR="/etc/VPS-MX"
PROTO_DIR="$BASE_DIR/protocolos"
HOME_DIR=$(getent passwd $SUDO_USER | cut -d: -f6)
[[ -z "$HOME_DIR" ]] && HOME_DIR="/root"

# Colores Profesionales
RED='\e[31m' && GREEN='\e[32m' && YELLOW='\e[33m'
BLUE='\e[34m' && MAG='\033[1;36m' && NC='\e[0m'
CYAN='\e[36m'

msg() {
    echo -e "${RED}————————————————————————————————————————————————————${NC}"
    echo -e "${CYAN}  $1 ${NC}"
    echo -e "${RED}————————————————————————————————————————————————————${NC}"
}

clear
echo -e "${RED}👑  INICIANDO FULL ELITE AUTOMATOR V4.2  👑${NC}"
echo -e "${YELLOW}  Configurando Elite WebSocket Gateway total...${NC}"

# 0. Preparación
msg "Fase 0: Preparación"
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf
rm -rf /etc/localtime &>/dev/null
ln -s /usr/share/zoneinfo/America/Mexico_City /etc/localtime &>/dev/null
rm /var/lib/dpkg/lock-frontend > /dev/null 2>&1
rm /var/lib/apt/lists/lock > /dev/null 2>&1

# 1. Instalación de Dependencias
msg "Fase 1: Instalación de Dependencias"
apt-get update -y
apt-get install net-tools openssl stunnel4 grep gawk plocate lolcat at nano bc lsof figlet cowsay screen python3 python3-pip ufw unzip zip apache2 dropbear squid software-properties-common -y

# 2. Configuración de Directorios y Extracción Core
msg "Fase 2: Restauración del Núcleo"
mkdir -p "$BASE_DIR"
mkdir -p "$PROTO_DIR"
mkdir -p "$BASE_DIR/controlador"
mkdir -p "/usr/local/lib/ubuntn/apache/ver"
mkdir -p "/usr/share/mediaptre/local/log/lognull"

if [[ -f "Files/VPS-MX.tar.xz" ]]; then
    tar -xf Files/VPS-MX.tar.xz -C "$BASE_DIR/"
fi

# 3. Capa Elite y Reparación de IP / Versión
msg "Fase 3: Capa Elite y Fixes"
IP_PUBLIC=$(curl -s v4.ident.me || wget -qO- v4.ident.me)
echo "$IP_PUBLIC" > "$BASE_DIR/MEUIPvps"
echo "8.4g" > /etc/versin_script_new
echo "8.4g" > /etc/versin_script
echo "ELITE-MOD" > "$BASE_DIR/message.txt"

cp menu "$BASE_DIR/menu"
chmod +x "$BASE_DIR/menu"
sed -i 's/ifconfig.me/v4.ident.me/g' "$BASE_DIR/menu" 2>/dev/null

cp menu_elite.sh "$BASE_DIR/menu_elite.sh"
chmod +x "$BASE_DIR/menu_elite.sh"
cp -r protocolos/* "$PROTO_DIR/"
chmod +x "$PROTO_DIR"/*.sh
chmod +x "$PROTO_DIR"/*.py 2>/dev/null

# 4. INSTALACIÓN AUTOMÁTICA DE PUERTOS (SILENT MODE)
msg "Fase 4: Elitización de Puertos"

# --- DROPBEAR (80, 109, 110) ---
echo "Configurando Dropbear..."
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=.*/DROPBEAR_PORT=80/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=.*/DROPBEAR_EXTRA_ARGS="-p 109 -p 110"/g' /etc/default/dropbear
service dropbear restart &>/dev/null

# --- PROXY ELITE WEBSOCKET (8799) ---
echo "Activando Elite WebSocket Gateway (Proxy:8799)..."
pkill -f PPub.py &>/dev/null
screen -dmS python_proxy python3 "$PROTO_DIR/PPub.py"

# --- STUNNEL4 / SSL (443) -> Proxy (8799) ---
echo "Configurando Stunnel Gateway (SSL:443 -> Proxy:8799)..."
/bin/bash "$PROTO_DIR/ssl_elite.sh"

# --- SQUID PROXY (8080) ---
echo "Configurando Squid..."
cat <<EOF > /etc/squid/squid.conf
acl localhost src 127.0.0.1/32 ::1
acl to_localhost dst 127.0.0.1/32 ::1
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 443
acl CONNECT method CONNECT
http_access allow all
http_port 3128
http_port 8080
coredump_dir /var/spool/squid
refresh_pattern . 0 20% 4320
EOF
service squid restart &>/dev/null

# --- BADVPN (7300) ---
ARCH=$(uname -m)
[[ "$ARCH" == "x86_64" ]] && URL_BAD="https://github.com/yuliskov/badvpn-udpgw-binaries/raw/master/badvpn-udpgw-linux-x86_64" || URL_BAD="https://github.com/yuliskov/badvpn-udpgw-binaries/raw/master/badvpn-udpgw-linux-arm64"
wget -O /usr/bin/badvpn-udpgw "$URL_BAD" &>/dev/null
chmod +x /usr/bin/badvpn-udpgw
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000

# 5. Vinculación y Persistencia
ln -sf /etc/VPS-MX/menu /usr/bin/menu
ln -sf /etc/VPS-MX/menu /usr/bin/vps-mx

# Tuning Kernel
/bin/bash "$PROTO_DIR/tuning_elite.sh"

msg "¡ACTUALIZACIÓN ELITE V4.2 COMPLETADA!"
echo -e " El Gateway WebSocket está activo. Tu payload ahora conectará."
