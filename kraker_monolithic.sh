#!/bin/bash
# ==============================================================================
# KRAKER ELITE (v4.0) - ALL-IN-ONE MONOLITHIC STANDALONE
# ==============================================================================
export RED='\e[31m'; export GREEN='\e[32m'; export YELLOW='\e[33m'; export BLUE='\e[34m'; export CYA='\e[36m'; export GRA='\e[90m'; export BOL='\e[1m'; export NC='\e[0m'

k_msg() { local type="$1"; local text="$2"; case "$type" in "-bar") echo -e "${GRA}————————————————————————————————————————————————————${NC}" ;; "-info") echo -e "${CYA}ℹ ${BOL}${text}${NC}" ;; "-ok") echo -e "${GREEN}✔ ${BOL}${text}${NC}" ;; "-warn") echo -e "${YELLOW}⚠ ${BOL}${text}${NC}" ;; "-err") echo -e "${RED}✖ ${BOL}${text}${NC}" ;; "-title") echo -e "${GRA}————————————————————————————————————————————————————${NC}"; echo -e "${BOL}${BLUE}  $text  ${NC}"; echo -e "${GRA}————————————————————————————————————————————————————${NC}" ;; esac; }
k_service() { local action="$1"; local service="$2"; service=$(echo "$service" | sed 's/\.service$//'); case "$action" in "start"|"restart"|"stop") systemctl "$action" "$service" >/dev/null 2>&1 || service "$service" "$action" >/dev/null 2>&1 ;; "status") systemctl is-active --quiet "$service" && echo -ne "${GREEN}[ON]${NC}" || echo -ne "${RED}[OFF]${NC}" ;; esac; }
k_ufw() { local port="$1"; ufw allow "$port" >/dev/null 2>&1; }
k_get_os() { [[ -f /etc/os-release ]] && . /etc/os-release && echo "$NAME" || echo "Ubuntu"; }

# --- MODULOS ---
menu_protocols() {
  while true; do
    clear
    k_msg -title "GESTIÓN DE PROTOCOLOS ELITE"
    echo -e " [1] SSL STUNNEL\n [2] BADVPN UDP\n [3] DROPBEAR\n [0] VOLVER AL MENÚ PRINCIPAL"
    k_msg -bar
    echo -ne " ➤ Protocolo: " && read psel
    psel=$(echo "$psel" | tr -d '\r') # Strip blind carriage returns
    case "$psel" in
      1|01) 
        if pgrep -x stunnel4 >/dev/null; then k_service stop stunnel4; k_msg -ok "SSL DETENIDO"; else 
        k_msg -info "Instalando dependencias SSL..."
        apt-get install stunnel4 -y >/dev/null 2>&1
        echo -ne " Puerto SSL (443): " && read sslp; sslp=$(echo "$sslp" | tr -d '\r'); [[ -z "$sslp" ]] && sslp="443"
        mkdir -p /etc/stunnel
        openssl genrsa -out /etc/stunnel/stunnel.key 2048 >/dev/null 2>&1
        (echo "BR"; echo "SP"; echo "SP"; echo "ADM"; echo "ADM"; echo "KRK"; echo "@elite") | openssl req -new -key /etc/stunnel/stunnel.key -x509 -days 3650 -out /etc/stunnel/stunnel.crt >/dev/null 2>&1
        cat /etc/stunnel/stunnel.crt /etc/stunnel/stunnel.key > /etc/stunnel/stunnel.pem
        echo -e "cert = /etc/stunnel/stunnel.pem\nclient = no\n[SSL]\naccept = $sslp\nconnect = 127.0.0.1:22" > /etc/stunnel/stunnel.conf
        sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 2>/dev/null
        k_service restart stunnel4 && k_ufw "$sslp" && k_msg -ok "SSL ACTIVADO (Puerto: $sslp)"
        fi
        sleep 2 ;;
      2|02)
        if pgrep -f badvpn-udpgw >/dev/null; then pkill -9 -f badvpn-udpgw; k_msg -ok "UDP GATEWAY DETENIDO"; else
        k_msg -info "Descargando binario y activando UDP..."
        wget -O /usr/bin/badvpn-udpgw https://github.com/itxtunnel/badvpn/raw/master/badvpn-udpgw >/dev/null 2>&1; chmod +x /usr/bin/badvpn-udpgw
        screen -dmS bdvpn /usr/bin/badvpn-udpgw --listen-addr 0.0.0.0:7300 --max-clients 1000
        k_ufw 7300; k_msg -ok "UDP ACTIVADO (Puerto: 7300)"
        fi
        sleep 2 ;;
      0|00) return ;;
      *) k_msg -err "Opción Inválida"; sleep 1 ;;
    esac
  done
}

menu_users() {
  while true; do
    clear
    k_msg -title "ADMINISTRACIÓN DE USUARIOS"
    echo -e " [1] Crear Usuario Inteligente\n [2] Monitor de Conexiones en Vivo\n [0] VOLVER"
    k_msg -bar
    echo -ne " ➤ Elija: " && read usel
    usel=$(echo "$usel" | tr -d '\r')
    case "$usel" in
      1|01) 
        echo -ne " Nuevo Usuario: " && read user; user=$(echo "$user" | tr -d '\r')
        echo -ne " Contraseña: " && read pass; pass=$(echo "$pass" | tr -d '\r')
        useradd -M -s /bin/false "$user" 2>/dev/null
        (echo "$pass"; echo "$pass") | passwd "$user" >/dev/null 2>&1
        k_msg -ok "Usuario '$user' creado exitosamente."
        sleep 2 ;;
      2|02) 
        k_msg -info "Usuarios Conectados (En Vivo):"
        k_msg -bar
        journalctl --since today | grep -iE "sshd.*Accepted|dropbear.*Password" | tail -n 12
        k_msg -bar
        echo -ne " Presiona ENTER para salir." && read dump ;;
      0|00) return ;;
      *) k_msg -err "Opción Inválida"; sleep 1 ;;
    esac
  done
}

# --- CONTROL PRINCIPAL ---
main_menu() {
  while true; do
    clear
    k_msg -title "KRAKER ELITE COMMAND CENTER (v4.0)"
    read r_total r_used r_free <<< $(free -h | awk '/Mem:/ {print $2, $3, $4}')
    cpu_load=$(top -bn1 | awk '/Cpu/ {print $2 + $4 "%"}')
    k_msg "-info" "RAM: ${BOL}$r_used / $r_total${NC} | CPU: ${BOL}$cpu_load${NC} | OS: ${BOL}$(k_get_os)${NC}"
    k_msg -bar
    echo -ne " SSH: "; k_service status sshd; echo -ne "  Dropbear: "; k_service status dropbear; echo -ne "  SSL: "; k_service status stunnel4
    echo -ne "\n Squid: "; k_service status squid; echo -ne "  Web: "; k_service status apache2; echo ""
    k_msg -bar
    echo -e " [1] Gestiön de Protocolos y Puertos\n [2] Administraciön de Usuarios y Accesos\n [3] Limpiar RAM y Optimizaciön\n [0] SALIR"
    k_msg -bar
    echo -ne " ➤ Opciön: " && read sel
    sel=$(echo "$sel" | tr -d '\r') # Evita saltos de línea destructivos
    
    case "$sel" in
      1|01) menu_protocols ;;
      2|02) menu_users ;;
      3|03) 
        k_msg -warn "Limpiando Caché RAM..."
        sync && echo 3 > /proc/sys/vm/drop_caches
        k_msg -ok "Sistema Optimizado."
        sleep 2 ;;
      0|00) clear; exit 0 ;;
      *) k_msg -err "Selecciön no reconocida"; sleep 1 ;;
    esac
  done
}

main_menu
