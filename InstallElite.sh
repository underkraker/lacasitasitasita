#!/bin/bash
# INSTALADOR FULL ELITE V3.0 (TOTAL & INTERACTIVO) - VPS-MX MOD
# Autor: Antigravity AI Expert
# Versión: 3.0 (Elite Professional)

# Configuración Inicial
export DEBIAN_FRONTEND=noninteractive
BASE_DIR="/etc/VPS-MX"
PROTO_DIR="$BASE_DIR/protocolos"
HOME_DIR=$(getent passwd $SUDO_USER | cut -d: -f6)
[[ -z "$HOME_DIR" ]] && HOME_DIR="/root"

# Colores Profesionales
RED='\e[31m' && GREEN='\e[32m' && YELLOW='\e[33m'
BLUE='\e[34m' && MAG'\033[1;36m' && NC='\e[0m'
CYAN='\e[36m'

msg() {
    echo -e "${RED}————————————————————————————————————————————————————${NC}"
    echo -e "${CYAN}  $1 ${NC}"
    echo -e "${RED}————————————————————————————————————————————————————${NC}"
}

clear
echo -e "${RED}👑  INICIANDO INSTALACIÓN FULL ELITE V3.0  👑${NC}"
echo -e "${YELLOW}  Restaurando núcleo completo y optimizaciones...${NC}"

# 0. Preparación del Sistema (DNS, Zona Horaria, Locks)
msg "Fase 0: Preparación del Sistema"
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf
rm -rf /etc/localtime &>/dev/null
ln -s /usr/share/zoneinfo/America/Mexico_City /etc/localtime &>/dev/null
rm /var/lib/dpkg/lock-frontend > /dev/null 2>&1
rm /var/lib/apt/lists/lock > /dev/null 2>&1

# 1. Instalación de Dependencias Core
msg "Fase 1: Instalación de Dependencias"
apt-get update -y
apt-get install net-tools openssl stunnel4 grep gawk mlocate lolcat at nano bc lsof figlet cowsay screen python3 python3-pip ufw unzip zip apache2 software-properties-common -y

# 2. Configuración de Directorios
msg "Fase 2: Estructura VPS-MX"
mkdir -p "$BASE_DIR"
mkdir -p "$PROTO_DIR"
mkdir -p "$BASE_DIR/controlador"
mkdir -p "/usr/local/lib/ubuntn/apache/ver"
mkdir -p "/usr/share/mediaptre/local/log/lognull"

# 3. Extracción del Núcleo Core (Fix Opción [1] y Gestión)
msg "Fase 3: Restauración del Núcleo (.tar.xz)"
if [[ -f "Files/VPS-MX.tar.xz" ]]; then
    tar -xf Files/VPS-MX.tar.xz -C "$BASE_DIR/"
    echo "Núcleo extraído con éxito."
else
    echo "ADVERTENCIA: Files/VPS-MX.tar.xz no encontrado localmente."
fi

# 4. Despliegue de Archivos Locales (Elite Layer)
msg "Fase 4: Capa Elite y Parches"
# Generar cache de IP
IP_PUBLIC=$(curl -s v4.ident.me || wget -qO- v4.ident.me)
echo "$IP_PUBLIC" > "$BASE_DIR/MEUIPvps"
echo "8.4g" > /etc/versin_script_new
echo "8.4g" > /etc/versin_script
echo "ELITE-MOD" > "$BASE_DIR/message.txt"

# Copiar archivos del repositorio
cp menu "$BASE_DIR/menu"
chmod +x "$BASE_DIR/menu"
# Parche de IP en el menú (ifconfig.me -> v4.ident.me)
sed -i 's/ifconfig.me/v4.ident.me/g' "$BASE_DIR/menu" 2>/dev/null

cp menu_elite.sh "$BASE_DIR/menu_elite.sh"
chmod +x "$BASE_DIR/menu_elite.sh"
cp -r protocolos/* "$PROTO_DIR/"
chmod +x "$PROTO_DIR"/*.sh
chmod +x "$PROTO_DIR"/*.py 2>/dev/null

# 5. Optimización Elite (BBR & TLS 1.3)
msg "Fase 5: Optimización de Rendimiento"
/bin/bash "$PROTO_DIR/tuning_elite.sh"
/bin/bash "$PROTO_DIR/ssl_elite.sh"

# 6. Vinculación de Comandos
msg "Fase 6: Comandos Globales"
ln -sf /etc/VPS-MX/menu /usr/bin/menu
ln -sf /etc/VPS-MX/menu /usr/bin/vps-mx
ln -sf /etc/VPS-MX/menu /usr/bin/VPS-MX
ln -sf /etc/VPS-MX/menu_elite.sh /usr/bin/elite

# 7. Suite de Instalación Interactiva (No cambiamos nada original)
msg "Fase 7: Suite de Instalación de Protocolos"
echo -e "${YELLOW}¿Deseas iniciar la instalación de protocolos ahora?${NC}"
read -p " (SSH, SSL, Dropbear, Squid, V2Ray) [S/N]: " inst_now
if [[ "$inst_now" =~ ^[Ss]$ ]]; then
    # SSL/Stunnel
    read -p " ¿Instalar SSL (Stunnel)? [S/N]: " run_ssl
    [[ "$run_ssl" =~ ^[Ss]$ ]] && /bin/bash "$PROTO_DIR/ssl.sh"
    # Dropbear
    read -p " ¿Instalar Dropbear? [S/N]: " run_drop
    [[ "$run_drop" =~ ^[Ss]$ ]] && /bin/bash "$PROTO_DIR/dropbear.sh"
    # Squid
    read -p " ¿Instalar Squid Proxy? [S/N]: " run_squid
    [[ "$run_squid" =~ ^[Ss]$ ]] && /bin/bash "$PROTO_DIR/squid.sh"
    # V2Ray
    read -p " ¿Instalar V2Ray? [S/N]: " run_v2
    [[ "$run_v2" =~ ^[Ss]$ ]] && /bin/bash "$PROTO_DIR/v2ray.sh"
fi

# Persistencia
echo '#!/bin/sh -e' >/etc/rc.local
echo "exit 0" >>/etc/rc.local
chmod +x /etc/rc.local
service ssh restart &>/dev/null

msg "¡INSTALACIÓN TOTAL V3.0 COMPLETADA!"
echo -e " Escribe 'menu' para gestionar cuentas o 'elite' para monitorear."
