#!/bin/bash
# INSTALADOR MAESTRO VPS-MX (v8.2u - Edición Compatibilidad)
# Repositorio: https://github.com/underkraker/lacasitasitasita

# 1. Colores y Banner
RED='\e[31m' && GREEN='\e[32m' && YELLOW='\e[33m' && NC='\e[0m'
clear
echo -e "${YELLOW}————————————————————————————————————————————————————"
echo -e " | 🐲 REPARANDO INSTALACIÓN VPS•MX | Version 8.2u | "
echo -e "————————————————————————————————————————————————————${NC}"

# 2. Instalación de Dependencias
echo -ne " Preparando dependencias... "
sudo apt update &>/dev/null
sudo apt install -y lsof psmisc net-tools curl git python3 ufw &>/dev/null
echo -e "${GREEN}OK${NC}"

# 3. Estructura de Carpetas Original v8.2
echo -ne " Configurando rutas del sistema... "
rm -rf /etc/newadm /etc/ger-inst /etc/ger-frm
mkdir -p /etc/newadm
mkdir -p /etc/ger-inst
mkdir -p /etc/ger-frm
echo -e "${GREEN}OK${NC}"

# 4. Clonación y Distribución
echo -ne " Sincronizando con repositorio... "
cd $HOME; rm -rf lacasitasitasita
git clone https://github.com/underkraker/lacasitasitasita &>/dev/null
cd lacasitasitasita

# Copiar archivos a sus lugares correspondientes
cp menu /etc/newadm/menu
cp message.txt /etc/newadm/message.txt &>/dev/null

# Mover protocolos (instaladores)
cp ssl.sh dropbear.sh v2ray.sh openvpn.sh shadowsocks.sh squid.sh budp.sh /etc/ger-inst/ &>/dev/null

# Mover herramientas (utilidades)
cp ports.sh gestor.sh tcp.sh blockBT.sh fai2ban.sh utils.sh paysnd.sh ultrahost speed.sh /etc/ger-frm/ &>/dev/null

# Copiar archivos python a root para sockspy
cp *.py /etc/newadm/ &>/dev/null
echo -e "${GREEN}OK${NC}"

# 5. Permisos y Enlaces
echo -ne " Finalizando configuración... "
chmod +x /etc/newadm/menu
chmod +x /etc/ger-inst/*.sh
chmod +x /etc/ger-frm/*.sh
chmod +x /etc/ger-frm/*

ln -sf /etc/newadm/menu /usr/bin/menu
ln -sf /etc/newadm/menu /usr/bin/vps-mx
echo -e "${GREEN}OK${NC}"

clear
echo -e "${GREEN}————————————————————————————————————————————————————"
echo -e "         INSTALACIÓN REPARADA Y LISTA             "
echo -e "————————————————————————————————————————————————————${NC}"
echo -e " Escriba ${YELLOW}'menu'${NC} para iniciar el panel."
echo -e "————————————————————————————————————————————————————"
