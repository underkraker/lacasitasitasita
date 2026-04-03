#!/bin/bash
# INSTALADOR MAESTRO VPS-MX (v8.2u - Edición Usuarios)
# Repositorio: https://github.com/underkraker/lacasitasitasita

# 1. Colores y Banner
RED='\e[31m' && GREEN='\e[32m' && YELLOW='\e[33m' && NC='\e[0m'
clear
echo -e "${YELLOW}————————————————————————————————————————————————————"
echo -e " | 🐲 REPARANDO GESTIÓN DE USUARIOS | Version 8.2u | "
echo -e "————————————————————————————————————————————————————${NC}"

# 2. Instalación de Dependencias
echo -ne " Preparando dependencias... "
sudo apt update &>/dev/null
sudo apt install -y lsof psmisc net-tools curl git python3 ufw bc &>/dev/null
echo -e "${GREEN}OK${NC}"

# 3. Estructura de Carpetas Completa v8.2
echo -ne " Configurando rutas de ger-user... "
rm -rf /etc/newadm /etc/ger-inst /etc/ger-frm
mkdir -p /etc/newadm/ger-user
mkdir -p /etc/ger-inst
mkdir -p /etc/ger-frm
echo -e "${GREEN}OK${NC}"

# 4. Clonación y Distribución
echo -ne " Sincronizando archivos de gestión... "
cd $HOME; rm -rf lacasitasitasita
git clone https://github.com/underkraker/lacasitasitasita &>/dev/null
cd lacasitasitasita

# Copiar archivos base
cp menu /etc/newadm/menu
cp message.txt /etc/newadm/message.txt &>/dev/null
cp usercodes /etc/newadm/ger-user/usercodes &>/dev/null

# Mover protocolos (instaladores)
cp ssl.sh dropbear.sh v2ray.sh openvpn.sh shadowsocks.sh squid.sh budp.sh /etc/ger-inst/ &>/dev/null

# Mover herramientas (utilidades)
cp ports.sh gestor.sh tcp.sh blockBT.sh fai2ban.sh utils.sh paysnd.sh ultrahost speed.sh /etc/ger-frm/ &>/dev/null

# Copiar archivos python a /etc/newadm/
cp *.py /etc/newadm/ &>/dev/null
echo -e "${GREEN}OK${NC}"

# 5. Permisos y Enlaces
echo -ne " Finalizando permisos... "
chmod +x /etc/newadm/menu
chmod +x /etc/newadm/ger-user/usercodes
chmod +x /etc/ger-inst/*.sh
chmod +x /etc/ger-frm/*.sh
chmod +x /etc/ger-frm/*

ln -sf /etc/newadm/menu /usr/bin/menu
ln -sf /etc/newadm/menu /usr/bin/vps-mx
echo -e "${GREEN}OK${NC}"

clear
echo -e "${GREEN}————————————————————————————————————————————————————"
echo -e "         GESTIÓN DE USUARIOS CORREGIDA               "
echo -e "————————————————————————————————————————————————————${NC}"
echo -e " Escriba ${YELLOW}'menu'${NC} y pruebe la Opción 1."
echo -e "————————————————————————————————————————————————————"
