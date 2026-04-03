#!/bin/bash
# INSTALADOR MAESTRO VPS-MX (v8.2 Desbloqueado y Universal)
# Repositorio: https://github.com/underkraker/lacasitasitasita

# 1. Colores y Banner
RED='\e[31m' && GREEN='\e[32m' && YELLOW='\e[33m' && NC='\e[0m'
clear
echo -e "${YELLOW}————————————————————————————————————————————————————"
echo -e " | 🐲 INSTALADOR MAESTRO VPS•MX | Version 8.2u ◄ | "
echo -e "————————————————————————————————————————————————————${NC}"

# 2. Instalación de Dependencias Críticas
echo -ne " Preparando dependencias... "
sudo apt update &>/dev/null
sudo apt install -y lsof psmisc net-tools curl git python3 ufw &>/dev/null
echo -e "${GREEN}OK${NC}"

# 3. Limpieza y Clonación
echo -ne " Repositorio: underkraker/lacasitasitasita... "
rm -rf /etc/VPS-MX
mkdir -p /etc/VPS-MX/protocolos
cd $HOME; rm -rf lacasitasitasita
git clone https://github.com/underkraker/lacasitasitasita &>/dev/null
if [[ ! -d "lacasitasitasita" ]]; then echo -e "${RED}ERROR DE CLONACIÓN${NC}"; exit 1; fi
echo -e "${GREEN}OK${NC}"

# 4. Instalación de Archivos
echo -ne " Configurando sistema... "
cp -r lacasitasitasita/* /etc/VPS-MX/
mv /etc/VPS-MX/ssl.sh /etc/VPS-MX/protocolos/ &>/dev/null
mv /etc/VPS-MX/dropbear.sh /etc/VPS-MX/protocolos/ &>/dev/null
mv /etc/VPS-MX/v2ray.sh /etc/VPS-MX/protocolos/ &>/dev/null
# ... mover el resto a protocolos/ como es costumbre
find /etc/VPS-MX/*.sh -maxdepth 1 -not -name "menu" -exec mv {} /etc/VPS-MX/protocolos/ \; &>/dev/null

# Permisos
chmod +x /etc/VPS-MX/menu
chmod +x /etc/VPS-MX/protocolos/*.sh
echo -e "${GREEN}OK${NC}"

# 5. Enlaces de Comandos
ln -sf /etc/VPS-MX/menu /usr/bin/menu
ln -sf /etc/VPS-MX/menu /usr/bin/vps-mx
ln -sf /etc/VPS-MX/menu /usr/bin/VPS-MX

# 6. Parche Ninja de Puertos (Ubuntu 24.04 OK)
cat <<'EOF' > /etc/VPS-MX/mportas.sh
mportas () {
unset portas
portas_var=$(ss -tunlp | grep LISTEN | sed 's/users:(("\([^"]*\)".*)/ \1/' | awk '{port=$NF; sub(/.*:/, "", port); print $NF, port}' | sort -u)
while read -r line; do [[ -z "$line" ]] || portas+="$line\n"; done <<< "$portas_var"
echo -ne "$portas"
}
EOF

clear
echo -e "${GREEN}————————————————————————————————————————————————————"
echo -e "         INSTALACIÓN COMPLETADA CON ÉXITO            "
echo -e "————————————————————————————————————————————————————${NC}"
echo -e " Escriba ${YELLOW}'menu'${NC} para iniciar el panel."
echo -e "————————————————————————————————————————————————————"
