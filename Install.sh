#!/bin/bash
# ==============================================================================
# KRAKER ELITE INSTALLER (v2.0) - RECONSTRUCCIÓN TOTAL
# ==============================================================================

# 1. Configuración de Entorno Elite
RED='\e[38;5;196m' && GREEN='\e[38;5;46m' && YELLOW='\e[38;5;226m' && NC='\e[0m'
export K_DIR="/etc/kraker"
clear

echo -e "${YELLOW}————————————————————————————————————————————————————"
echo -e " | 🐲 INSTALADOR KRAKER ELITE | Version 2.0 | "
echo -e "————————————————————————————————————————————————————${NC}"

# Chequeo de Root
[[ $UID -ne 0 ]] && echo -e "${RED}[!] Error: Ejecuta como root (sudo su)${NC}" && exit 1

# 2. Limpieza de Versiones Antiguas
echo -ne " Preparando sistema para la nueva versión Elite... "
rm -rf /etc/newadm /etc/ger-inst /etc/ger-frm /etc/kraker
mkdir -p "$K_DIR/protocols" "$K_DIR/users" "$K_DIR/logs"
echo -e "${GREEN}OK${NC}"

# 3. Instalación de Dependencias Críticas
echo -ne " Instalando dependencias del sistema... "
apt-get update &>/dev/null
apt-get install -y lsof psmisc net-tools curl git python3 ufw bc screen stunnel4 zip unzip &>/dev/null
echo -e "${GREEN}OK${NC}"

# 4. Clonación de Repositorio Elite
echo -ne " Descargando archivos maestros Elite... "
cd $HOME; rm -rf lacasitasitasita
git clone https://github.com/underkraker/lacasitasitasita &>/dev/null
cd lacasitasitasita
echo -e "${GREEN}OK${NC}"

# 5. Distribución Modular
echo -ne " Sincronizando módulos de gestión... "
cp kraker_core.sh "$K_DIR/core.sh"
cp menu "$K_DIR/menu"
cp protocols.sh "$K_DIR/protocols.sh"
cp usercodes "$K_DIR/usercodes" # Proximo: Refactorizar como user_manager.sh
# Mover archivos extra
cp message.txt "$K_DIR/message.txt" &>/dev/null
chmod +x "$K_DIR"/*
echo -e "${GREEN}OK${NC}"

# 6. Finalización y Enlaces Elite
echo -ne " Configurando enlaces de comando... "
ln -sf "$K_DIR/menu" /usr/bin/menu
ln -sf "$K_DIR/menu" /usr/bin/kraker
ln -sf "$K_DIR/menu" /usr/bin/vps-mx
echo -e "${GREEN}OK${NC}"

clear
echo -e "${GREEN}————————————————————————————————————————————————————"
echo -e "      ${BOLD}KRAKER ELITE INSTALADO EXITOSAMENTE${NC}"
echo -e "————————————————————————————————————————————————————"
echo -e " Escribe ${YELLOW}'kraker'${NC} o ${YELLOW}'menu'${NC} para entrar al panel."
echo -e "————————————————————————————————————————————————————"
echo -e " [!] Recomendado: Reinicia tu sesión SSH para aplicar cambios."
echo -e "————————————————————————————————————————————————————"
