#!/bin/bash
# INSTALADOR FULL ELITE (TODO-EN-UNO) - VPS-MX MOD
# Autor: Antigravity AI Expert
# Versión: 2.0 (Elite Unified)

# Configuración Inicial
export DEBIAN_FRONTEND=noninteractive
BASE_DIR="/etc/VPS-MX"
PROTO_DIR="$BASE_DIR/protocolos"
HOME_DIR=$(getent passwd $SUDO_USER | cut -d: -f6)
[[ -z "$HOME_DIR" ]] && HOME_DIR="/root"

# Colores Profesionales
RED='\e[31m' && GREEN='\e[32m' && YELLOW='\e[33m'
BLUE='\e[34m' && MAG'\033[1;36m' && NC='\e[0m'

msg() {
    echo -e "${RED}————————————————————————————————————————————————————${NC}"
    echo -e "${CYAN}  $1 ${NC}"
    echo -e "${RED}————————————————————————————————————————————————————${NC}"
}

clear
echo -e "${RED}👑  INICIANDO INSTALACIÓN FULL ELITE (UNIFIED)  👑${NC}"
echo -e "${YELLOW}  Preparando el sistema para optimización máxima...${NC}"

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

# 2. Configuración de Directorios y Estructura
msg "Fase 2: Estructura VPS-MX"
mkdir -p "$BASE_DIR"
mkdir -p "$PROTO_DIR"
mkdir -p "$BASE_DIR/controlador"
mkdir -p "/usr/local/lib/ubuntn/apache/ver"
mkdir -p "/usr/share/mediaptre/local/log/lognull"
mkdir -p "$BASE_DIR/B-VPS-MXuser"

# 3. Despliegue de Archivos (Clonando o Copiando locales)
msg "Fase 3: Despliegue de Archivos"
# Copiar archivos originales de la carpeta actual (cloncasita)
cp menu "$BASE_DIR/menu"
chmod +x "$BASE_DIR/menu"
cp menu_elite.sh "$BASE_DIR/menu_elite.sh"
chmod +x "$BASE_DIR/menu_elite.sh"
cp -r protocolos/* "$PROTO_DIR/"
chmod +x "$PROTO_DIR"/*.sh
chmod +x "$PROTO_DIR"/*.py 2>/dev/null

# Descargar utilidades originales se faltan
[[ ! -f "$BASE_DIR/controlador/nombre.log" ]] && wget -O "$BASE_DIR/controlador/nombre.log" https://github.com/lacasitamx/VPSMX/raw/master/ArchivosUtilitarios/nombre.log &>/dev/null
[[ ! -f "$BASE_DIR/controlador/IDT.log" ]] && wget -O "$BASE_DIR/controlador/IDT.log" https://github.com/lacasitamx/VPSMX/raw/master/ArchivosUtilitarios/IDT.log &>/dev/null
[[ ! -f "$BASE_DIR/controlador/tiemlim.log" ]] && wget -O "$BASE_DIR/controlador/tiemlim.log" https://github.com/lacasitamx/VPSMX/raw/master/ArchivosUtilitarios/tiemlim.log &>/dev/null
wget https://github.com/lacasitamx/VPSMX/raw/master/SCRIPT-V8.4g/Fix/HELP -O /usr/bin/HELP &>/dev/null
chmod 775 /usr/bin/HELP &>/dev/null

# 4. Capa de Optimización Elite
msg "Fase 4: Optimización Avanzada"
# BBR y TCP tuning
/bin/bash "$PROTO_DIR/tuning_elite.sh"
# SSL TLS 1.3
/bin/bash "$PROTO_DIR/ssl_elite.sh"

# 5. Configuración de Red y Seguridad
msg "Fase 5: Configuración de Red"
sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf >/dev/null 2>&1
service apache2 restart >/dev/null 2>&1
grep -v "^PasswordAuthentication" /etc/ssh/sshd_config >/tmp/passlogin && mv /tmp/passlogin /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >>/etc/ssh/sshd_config
service ssh restart &>/dev/null

# 6. Vinculación de Comandos Globales
msg "Fase 6: Comandos y Accesos"
ln -sf /etc/VPS-MX/menu /usr/bin/menu
ln -sf /etc/VPS-MX/menu /usr/bin/vps-mx
ln -sf /etc/VPS-MX/menu /usr/bin/VPS-MX
ln -sf /etc/VPS-MX/menu_elite.sh /usr/bin/elite
ln -sf /etc/VPS-MX/menu_elite.sh /usr/bin/ELITE

# 7. Persistencia y Banner
msg "Fase 7: Persistencia y Banner"
# rc.local
echo '#!/bin/sh -e' >/etc/rc.local
echo "exit 0" >>/etc/rc.local
chmod +x /etc/rc.local

# .bashrc (Banner Pro)
sed -i '/DASHBOARD ELITE/d' $HOME_DIR/.bashrc
cat <<EOF >> $HOME_DIR/.bashrc

# DASHBOARD ELITE WELCOME
clear
echo -e "\t\033[91m __     ______  ____        __  ____  __ "
echo -e "\t\033[91m \ \   / /  _ \/ ___|      |  \/  \ \/ / "
echo -e "\t\033[91m  \ \ / /| |_) \___ \ _____| |\/| |\  /  "
echo -e "\t\033[91m   \ V / |  __/ ___) |_____| |  | |/  \  "
echo -e "\t\033[91m    \_/  |_|   |____/      |_|  |_/_/\_\ "
echo ""
echo -e "\t\033[97mPARA MOSTRAR PANEL BASH ESCRIBA: menu o elite"
echo ""
EOF

echo -e "${GREEN}————————————————————————————————————————————————————${NC}"
echo -e "${YELLOW}  👑 INSTALACIÓN DE PANEL FULL ELITE COMPLETADA 👑${NC}"
echo -e "${GREEN}————————————————————————————————————————————————————${NC}"
echo -e "  Comandos Disponibles:"
echo -e "  [${CYAN}menu${NC}]   : Panel de Gestión Original"
echo -e "  [${CYAN}elite${NC}]  : Dashboard Avanzado en Tiempo Real"
echo -e "${GREEN}————————————————————————————————————————————————————${NC}"
