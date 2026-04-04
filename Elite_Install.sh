#!/bin/bash
# ==============================================================================
# KRAKER ELITE MASTER INSTALLER (v4.0) - MONOLITHIC STANDALONE
# ==============================================================================

RED='\e[31m' && GREEN='\e[32m' && YELLOW='\e[33m' && NC='\e[0m'

clear
echo -e "${YELLOW}————————————————————————————————————————————————————"
echo -e " | 🐲 INSTALADOR MAESTRO ELITE (v4.0 - BLINDADO) | "
echo -e "————————————————————————————————————————————————————${NC}"

# ROOT CHECK
[[ $UID -ne 0 ]] && echo -e "${RED}[!] Error: Ejecuta como root (sudo su)${NC}" && exit 1

# 1. Purga Total
echo -ne " Preparando sistema... "
rm -rf /etc/kraker \
       /usr/bin/kraker \
       /usr/bin/menu \
       /etc/newadm \
       /etc/ger-inst \
       /etc/ger-frm \
       /usr/local/bin/kraker
echo -e "${GREEN}OK${NC}"

# 2. Descarga del Súper-Archivo Monolítico
echo -ne " Inyectando Motor Monolítico Elite... "

# Bajar directo al binario de usuario
wget -qO /usr/bin/kraker https://raw.githubusercontent.com/underkraker/lacasitasitasita/master/kraker_monolithic.sh
# Forzar a formato UNIX
sed -i 's/\r$//' /usr/bin/kraker

chmod +x /usr/bin/kraker
ln -sf /usr/bin/kraker /usr/bin/menu

echo -e "${GREEN}OK${NC}"

echo -e "\n${GREEN}————————————————————————————————————————————————————"
echo -e "      KRAKER ELITE v4.0 INSTALADO EXITOSAMENTE"
echo -e "————————————————————————————————————————————————————"
echo -e " Escribe ${YELLOW}'kraker'${NC} para entrar al panel."
echo -e "————————————————————————————————————————————————————${NC}"
