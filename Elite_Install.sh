#!/bin/bash
# ==============================================================================
# KRAKER ELITE MASTER INSTALLER (v3.0) - ALL-IN-ONE
# ==============================================================================

K_DIR="/etc/kraker"
RED='\e[31m' && GREEN='\e[32m' && YELLOW='\e[33m' && NC='\e[0m'

clear
echo -e "${YELLOW}————————————————————————————————————————————————————"
echo -e " | 🐲 INSTALADOR INDESTRUCTIBLE ELITE (v3.0) | "
echo -e "————————————————————————————————————————————————————${NC}"

# ROOT CHECK
[[ $UID -ne 0 ]] && echo -e "${RED}[!] Error: Ejecuta como root (sudo su)${NC}" && exit 1

# 1. Purga Profunda
echo -ne " Limpiando rastros anteriores... "
rm -rf /etc/kraker /etc/krk_elite /usr/bin/kraker /usr/bin/menu
mkdir -p "$K_DIR/protocols" "$K_DIR/users" "$K_DIR/logs"
echo -e "${GREEN}OK${NC}"

# 2. Generación de Módulos Inyectados
echo -ne " Inyectando Módulos Elite (Sin red)... "

# --- Motor Core ---
cat <<'EOF' > "$K_DIR/core.sh"
#!/bin/bash
export RED='\e[31m'; export GREEN='\e[32m'; export YELLOW='\e[33m'; export BLUE='\e[34m'; export CYA='\e[36m'; export GRA='\e[90m'; export NC='\e[0m'; export BOL='\e[1m'
export K_DIR="/etc/kraker"; export K_PRT="${K_DIR}/protocols"; export K_USR="${K_DIR}/users"
mkdir -p "${K_PRT}" "${K_USR}"
k_msg() { local type="$1"; local text="$2"; case "$type" in "-bar") echo -e "${GRA}————————————————————————————————————————————————————${NC}" ;; "-info") echo -e "${CYA}ℹ ${WHITE}${text}${NC}" ;; "-ok") echo -e "${GREEN}✔ ${WHITE}${text}${NC}" ;; "-warn") echo -e "${YELLOW}⚠ ${WHITE}${text}${NC}" ;; "-err") echo -e "${RED}✖ ${BOL}${text}${NC}" ;; "-title") echo -e "${GRA}————————————————————————————————————————————————————${NC}"; echo -e "${BLUE}${BOL}  $text  ${NC}"; echo -e "${GRA}————————————————————————————————————————————————————${NC}" ;; esac; }
k_service() { local action="$1"; local service="$2"; service=$(echo "$service" | sed 's/\.service$//'); case "$action" in "start"|"restart"|"stop") systemctl "$action" "$service" >/dev/null 2>&1 || service "$service" "$action" >/dev/null 2>&1 ;; "status") systemctl is-active --quiet "$service" && echo -ne "${GREEN}[ON]${NC}" || echo -ne "${RED}[OFF]${NC}" ;; esac; }
k_ufw() { local port="$1"; ufw allow "$port" >/dev/null 2>&1; }
k_get_os() { [[ -f /etc/os-release ]] && . /etc/os-release && echo "$NAME" || echo "Ubuntu"; }
export -f k_msg k_service k_ufw k_get_os
EOF

# --- Interfaz Menu ---
cat <<'EOF' > "$K_DIR/menu"
#!/bin/bash
source /etc/kraker/core.sh
clear
k_msg -title "KRAKER ELITE COMMAND CENTER"
read r_total r_used r_free <<< $(free -h | awk '/Mem:/ {print $2, $3, $4}')
cpu_load=$(top -bn1 | awk '/Cpu/ {print $2 + $4 "%"}')
k_msg "-info" "RAM: ${GREEN}$r_used / $r_total${NC} | CPU: ${GREEN}$cpu_load${NC} | OS: ${CYA}$(k_get_os)${NC}"
k_msg -bar
echo -ne " SSH: "; k_service status sshd; echo -ne "  Dropbear: "; k_service status dropbear; echo -ne "  SSL: "; k_service status stunnel4
echo -ne "\n Squid: "; k_service status squid; echo -ne "  Web: "; k_service status apache2; echo ""
k_msg -bar
echo -e " [01] Gestiön de Protocolos\n [02] Administraciön de Usuarios\n [03] Herramientas de Red\n [00] SALIR"
k_msg -bar
echo -ne " ➤ Elija: " && read sel
case "$sel" in
  01) /etc/kraker/protocols.sh ;;
  02) /etc/kraker/user_manager.sh ;;
  03) /etc/kraker/utils.sh ;;
  00) exit 0 ;;
  *) exec "$0" ;;
esac
EOF

# --- Gestor de Protocolos ---
cat <<'EOF' > "$K_DIR/protocols.sh"
#!/bin/bash
source /etc/kraker/core.sh
clear
k_msg -title "GESTIÓN DE PROTOCOLOS ELITE"
echo -e " [1] SSL STUNNEL\n [2] BADVPN UDP\n [3] DROPBEAR\n [0] VOLVER"
k_msg -bar
read -p " ➤ Protocolo: " psel
case "$psel" in
  1) 
    if pgrep -x stunnel4 >/dev/null; then k_service stop stunnel4; k_msg -ok "SSL OFF"; else 
    apt-get install stunnel4 -y >/dev/null 2>&1
    read -p " Puerto SSL: " sslp; [[ -z "$sslp" ]] && sslp="443"
    openssl genrsa -out /etc/stunnel/stunnel.key 2048 >/dev/null 2>&1
    (echo "BR"; echo "SP"; echo "SP"; echo "ADM"; echo "ADM"; echo "KRK"; echo "@elite") | openssl req -new -key /etc/stunnel/stunnel.key -x509 -days 3650 -out /etc/stunnel/stunnel.crt >/dev/null 2>&1
    cat /etc/stunnel/stunnel.crt /etc/stunnel/stunnel.key > /etc/stunnel/stunnel.pem
    echo -e "cert = /etc/stunnel/stunnel.pem\nclient = no\n[SSL]\naccept = $sslp\nconnect = 127.0.0.1:22" > /etc/stunnel/stunnel.conf
    sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 2>/dev/null
    k_service restart stunnel4 && k_ufw "$sslp" && k_msg -ok "SSL ON: $sslp"
    fi ;;
  2)
    if pgrep -f badvpn-udpgw >/dev/null; then pkill -9 -f badvpn-udpgw; k_msg -ok "UDP OFF"; else
    wget -O /usr/bin/badvpn-udpgw https://github.com/itxtunnel/badvpn/raw/master/badvpn-udpgw >/dev/null 2>&1; chmod +x /usr/bin/badvpn-udpgw
    screen -dmS bdvpn /usr/bin/badvpn-udpgw --listen-addr 0.0.0.0:7300 --max-clients 1000
    k_ufw 7300; k_msg -ok "UDP ON: 7300"
    fi ;;
  0) exec /etc/kraker/menu ;;
esac
sleep 2; exec "$0"
EOF

# --- Gestor de Usuarios ---
cat <<'EOF' > "$K_DIR/user_manager.sh"
#!/bin/bash
source /etc/kraker/core.sh
clear
k_msg -title "ADMINISTRACIÓN DE USUARIOS"
echo -e " [1] Crear Usuario\n [2] Monitor\n [0] VOLVER"
k_msg -bar
read -p " Elija: " usel
case "$usel" in
  1) read -p " User: " user; read -p " Pass: " pass; useradd -M -s /bin/false "$user"; (echo "$pass"; echo "$pass") | passwd "$user" >/dev/null 2>&1; k_msg -ok "User $user creado" ;;
  2) k_msg -info "Conectados (Journal Scan):"; journalctl --since today | grep -iE "sshd.*Accepted|dropbear.*Password" | tail -n 10 ;;
  0) exec /etc/kraker/menu ;;
esac
sleep 2; exec "$0"
EOF

# --- Utilidades ---
cat <<'EOF' > "$K_DIR/utils.sh"
#!/bin/bash
source /etc/kraker/core.sh
clear
k_msg -info "Limpiando RAM y Cache..."
sync && echo 3 > /proc/sys/vm/drop_caches
k_msg -ok "Limpieza completada."
sleep 1; exec /etc/kraker/menu
EOF

# 4. Finalización
chmod +x "$K_DIR"/*
ln -sf "$K_DIR/menu" /usr/bin/kraker
ln -sf "$K_DIR/menu" /usr/bin/menu

echo -e "\n${GREEN}————————————————————————————————————————————————————"
echo -e "      ${BOLD}KRAKER ELITE v3.0 INSTALADO EXITOSAMENTE${NC}"
echo -e "————————————————————————————————————————————————————"
echo -e " Escribe ${YELLOW}'kraker'${NC} para entrar al panel."
echo -e "————————————————————————————————————————————————————${NC}"
