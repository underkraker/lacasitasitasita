#!/bin/bash
# ==============================================================================
# KRAKER ELITE MASTER INSTALLER (v3.1) - INPUT FIX
# ==============================================================================

K_DIR="/etc/kraker"
RED='\e[31m' && GREEN='\e[32m' && YELLOW='\e[33m' && NC='\e[0m'

clear
echo -e "${YELLOW}————————————————————————————————————————————————————"
echo -e " | 🐲 INSTALADOR MAESTRO ELITE (v3.1-FIXED) | "
echo -e "————————————————————————————————————————————————————${NC}"

# ROOT CHECK
[[ $UID -ne 0 ]] && echo -e "${RED}[!] Error: Ejecuta como root (sudo su)${NC}" && exit 1

# 1. Purga Total
echo -ne " Preparando sistema... "
rm -rf /etc/kraker /usr/bin/kraker /usr/bin/menu
mkdir -p "$K_DIR/protocols" "$K_DIR/users" "$K_DIR/logs"
echo -e "${GREEN}OK${NC}"

# 2. Inyección Inmune a Errores
echo -ne " Inyectando Módulos Elite v3.1... "

# --- Motor Core ---
cat <<'EOF' > "$K_DIR/core.sh"
#!/bin/bash
export RED='\e[31m'; export GREEN='\e[32m'; export YELLOW='\e[33m'; export BLUE='\e[34m'; export CYA='\e[36m'; export GRA='\e[90m'; export BOL='\e[1m'; export NC='\e[0m'
export K_DIR="/etc/kraker"; export K_PRT="${K_DIR}/protocols"; export K_USR="${K_DIR}/users"
k_msg() { local type="$1"; local text="$2"; case "$type" in "-bar") echo -e "${GRA}————————————————————————————————————————————————————${NC}" ;; "-info") echo -e "${CYA}ℹ ${BOL}${text}${NC}" ;; "-ok") echo -e "${GREEN}✔ ${BOL}${text}${NC}" ;; "-warn") echo -e "${YELLOW}⚠ ${BOL}${text}${NC}" ;; "-err") echo -e "${RED}✖ ${BOL}${text}${NC}" ;; "-title") echo -e "${GRA}————————————————————————————————————————————————————${NC}"; echo -e "${BOL}${BLUE}  $text  ${NC}"; echo -e "${GRA}————————————————————————————————————————————————————${NC}" ;; esac; }
k_service() { local action="$1"; local service="$2"; service=$(echo "$service" | sed 's/\.service$//'); case "$action" in "start"|"restart"|"stop") systemctl "$action" "$service" >/dev/null 2>&1 || service "$service" "$action" >/dev/null 2>&1 ;; "status") systemctl is-active --quiet "$service" && echo -ne "${GREEN}[ON]${NC}" || echo -ne "${RED}[OFF]${NC}" ;; esac; }
k_ufw() { local port="$1"; ufw allow "$port" >/dev/null 2>&1; }
k_get_os() { [[ -f /etc/os-release ]] && . /etc/os-release && echo "$NAME" || echo "Ubuntu"; }
export -f k_msg k_service k_ufw k_get_os
EOF

# --- Interfaz Menu (v3.1 FIXED CASE) ---
cat <<'EOF' > "$K_DIR/menu"
#!/bin/bash
source /etc/kraker/core.sh
clear
k_msg -title "KRAKER ELITE COMMAND CENTER"
read r_total r_used r_free <<< $(free -h | awk '/Mem:/ {print $2, $3, $4}')
cpu_load=$(top -bn1 | awk '/Cpu/ {print $2 + $4 "%"}')
k_msg "-info" "RAM: ${BOL}$r_used / $r_total${NC} | CPU: ${BOL}$cpu_load${NC} | OS: ${BOL}$(k_get_os)${NC}"
k_msg -bar
echo -ne " SSH: "; k_service status sshd; echo -ne "  Dropbear: "; k_service status dropbear; echo -ne "  SSL: "; k_service status stunnel4
echo -ne "\n Squid: "; k_service status squid; echo -ne "  Web: "; k_service status apache2; echo ""
k_msg -bar
echo -e " [1] Gestiön de Protocolos\n [2] Administraciön de Usuarios\n [3] Herramientas de Red\n [0] SALIR"
k_msg -bar
echo -ne " ➤ Elija: " && read sel
case "$sel" in
  1|01) exec /etc/kraker/protocols.sh ;;
  2|02) exec /etc/kraker/user_manager.sh ;;
  3|03) exec /etc/kraker/utils.sh ;;
  0|00) exit 0 ;;
  *) exec /etc/kraker/menu ;;
esac
EOF

# --- Gestor de Protocolos (v3.1 FIXED) ---
cat <<'EOF' > "$K_DIR/protocols.sh"
#!/bin/bash
source /etc/kraker/core.sh
clear
k_msg -title "GESTIÓN DE PROTOCOLOS"
echo -e " [1] SSL STUNNEL\n [2] BADVPN UDP\n [3] DROPBEAR\n [0] VOLVER"
k_msg -bar
read -p " ➤ Protocolo: " psel
case "$psel" in
  1|01) 
    if pgrep -x stunnel4 >/dev/null; then k_service stop stunnel4; k_msg -ok "SSL OFF"; else 
    apt-get install stunnel4 -y >/dev/null 2>&1
    read -p " Puerto SSL (443): " sslp; [[ -z "$sslp" ]] && sslp="443"
    openssl genrsa -out /etc/stunnel/stunnel.key 2048 >/dev/null 2>&1
    (echo "BR"; echo "SP"; echo "SP"; echo "ADM"; echo "ADM"; echo "KRK"; echo "@elite") | openssl req -new -key /etc/stunnel/stunnel.key -x509 -days 3650 -out /etc/stunnel/stunnel.crt >/dev/null 2>&1
    cat /etc/stunnel/stunnel.crt /etc/stunnel/stunnel.key > /etc/stunnel/stunnel.pem
    echo -e "cert = /etc/stunnel/stunnel.pem\nclient = no\n[SSL]\naccept = $sslp\nconnect = 127.0.0.1:22" > /etc/stunnel/stunnel.conf
    sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 2>/dev/null
    k_service restart stunnel4 && k_ufw "$sslp" && k_msg -ok "SSL ON: $sslp"
    fi ;;
  2|02)
    if pgrep -f badvpn-udpgw >/dev/null; then pkill -9 -f badvpn-udpgw; k_msg -ok "UDP OFF"; else
    wget -O /usr/bin/badvpn-udpgw https://github.com/itxtunnel/badvpn/raw/master/badvpn-udpgw >/dev/null 2>&1; chmod +x /usr/bin/badvpn-udpgw
    screen -dmS bdvpn /usr/bin/badvpn-udpgw --listen-addr 0.0.0.0:7300 --max-clients 1000
    k_ufw 7300; k_msg -ok "UDP ON: 7300"
    fi ;;
  0|00) exec /etc/kraker/menu ;;
  *) exec /etc/kraker/protocols.sh ;;
esac
sleep 2; exec /etc/kraker/protocols.sh
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
  1|01) read -p " User: " user; read -p " Pass: " pass; useradd -M -s /bin/false "$user"; (echo "$pass"; echo "$pass") | passwd "$user" >/dev/null 2>&1; k_msg -ok "User $user creado" ;;
  2|02) k_msg -info "Conectados:"; journalctl --since today | grep -iE "sshd.*Accepted|dropbear.*Password" | tail -n 12 ;;
  0|00) exec /etc/kraker/menu ;;
esac
sleep 2; exec /etc/kraker/user_manager.sh
EOF

# --- Utilidades ---
cat <<'EOF' > "$K_DIR/utils.sh"
#!/bin/bash
source /etc/kraker/core.sh
clear
k_msg -warn "Limpiando Caché y Optimizando RAM..."
sync && echo 3 > /proc/sys/vm/drop_caches
k_msg -ok "Operación Elite de Limpieza Completa."
sleep 2; exec /etc/kraker/menu
EOF

# 4. Finalización Legítima
sed -i 's/\r$//' "$K_DIR"/* 2>/dev/null
chmod +x "$K_DIR"/*
ln -sf "$K_DIR/menu" /usr/bin/kraker
ln -sf "$K_DIR/menu" /usr/bin/menu
echo -e "\n${GREEN}————————————————————————————————————————————————————"
echo -e "      ${BOL}KRAKER ELITE v3.1-FIXED INSTALADO${NC}"
echo -e "————————————————————————————————————————————————————"
echo -e " Escribe ${YELLOW}'kraker'${NC} para entrar."
echo -e "————————————————————————————————————————————————————${NC}"
