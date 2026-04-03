#!/bin/bash
# FULL ELITE AUTOMATOR V4.1 (ULTIMATE SETUP) - VPS-MX MOD
# Autor: Antigravity AI Expert
# Versión: 4.1 (Elite Master)

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
echo -e "${RED}👑  INICIANDO FULL ELITE AUTOMATOR V4.1  👑${NC}"
echo -e "${YELLOW}  Automatización Total y Reparación de BadVPN...${NC}"

# 0. Preparación del Sistema (DNS, Zona Horaria, Locks)
msg "Fase 0: Preparación"
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf
rm -rf /etc/localtime &>/dev/null
ln -s /usr/share/zoneinfo/America/Mexico_City /etc/localtime &>/dev/null
rm /var/lib/dpkg/lock-frontend > /dev/null 2>&1
rm /var/lib/apt/lists/lock > /dev/null 2>&1

# 1. Instalación de Dependencias Core (Fix mlocate -> plocate)
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
msg "Fase 4: Configuración de Puertos Automática"

# --- DROPBEAR (80, 109, 110) ---
echo "Configurando Dropbear..."
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=.*/DROPBEAR_PORT=80/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=.*/DROPBEAR_EXTRA_ARGS="-p 109 -p 110"/g' /etc/default/dropbear
service dropbear restart &>/dev/null

# --- STUNNEL4 / SSL (443) ---
echo "Configurando Stunnel (SSL 443)..."
CERT_FILE="/etc/stunnel/stunnel.pem"
if [ ! -f "$CERT_FILE" ]; then
    openssl genrsa -out key.pem 2048 >/dev/null 2>&1
    openssl req -new -x509 -key key.pem -out cert.pem -days 1095 -subj "/C=MX/ST=Elite/L=Elite/O=Elite/CN=Elite" >/dev/null 2>&1
    cat key.pem cert.pem > "$CERT_FILE"
    rm key.pem cert.pem
fi
cat <<EOF > /etc/stunnel/stunnel.conf
pid = /var/run/stunnel4.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
sslVersion = TLSv1.3
[ssh]
accept = 443
connect = 127.0.0.1:80
EOF
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart &>/dev/null

# --- SQUID PROXY (8080) ---
echo "Configurando Squid..."
cat <<EOF > /etc/squid/squid.conf
acl localhost src 127.0.0.1/32 ::1
acl to_localhost dst 127.0.0.1/32 ::1
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 443
acl CONNECT method CONNECT
http_access allow localhost
http_access allow all
http_port 3128
http_port 8080
coredump_dir /var/spool/squid
refresh_pattern . 0 20% 4320
EOF
service squid restart &>/dev/null

# --- BADVPN FIX (UDP 7300) ---
msg "Fase 5: Reparación Total de BadVPN"
ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    URL_BAD="https://github.com/yuliskov/badvpn-udpgw-binaries/raw/master/badvpn-udpgw-linux-x86_64"
elif [ "$ARCH" == "aarch64" ]; then
    URL_BAD="https://github.com/yuliskov/badvpn-udpgw-binaries/raw/master/badvpn-udpgw-linux-arm64"
fi
wget -O /usr/bin/badvpn-udpgw "$URL_BAD" &>/dev/null
wget -O /bin/badvpn-udpgw "$URL_BAD" &>/dev/null
chmod +x /usr/bin/badvpn-udpgw
chmod +x /bin/badvpn-udpgw
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000

# Parchear el script budp.sh original para que use nuestro binario y no de error
cat <<EOF > "$PROTO_DIR/budp.sh"
#!/bin/bash
clear
echo "————————————————————————————————————————————————————"
echo "            ACTIVADOR DE BADVPN (UDP 7300)"
echo "————————————————————————————————————————————————————"
if pgrep -x "badvpn-udpgw" > /dev/null; then
    echo "  BADVPN YA ESTÁ ACTIVO EN EL PUERTO 7300"
else
    screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000
    echo "  BADVPN ACTIVADO CON ÉXITO (PUERTO 7300)"
fi
echo "————————————————————————————————————————————————————"
sleep 2s
EOF
chmod +x "$PROTO_DIR/budp.sh"

# --- PROXY PYTHON 3 (8799) ---
screen -dmS python_proxy python3 "$PROTO_DIR/PPub.py" 8799

# 6. Vinculación Final
ln -sf /etc/VPS-MX/menu /usr/bin/menu
ln -sf /etc/VPS-MX/menu /usr/bin/vps-mx
ln -sf /etc/VPS-MX/menu_elite.sh /usr/bin/elite

# Tuning Kernel
/bin/bash "$PROTO_DIR/tuning_elite.sh"

msg "¡INSTALACIÓN TOTAL V4.1 FINALIZADA!"
echo -e " Todos los puertos están configurados y BadVPN reparado."
