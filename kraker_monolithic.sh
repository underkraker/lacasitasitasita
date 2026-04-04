#!/bin/bash
# ==============================================================================
# KRAKER ELITE (v4.0) - ALL-IN-ONE MONOLITHIC STANDALONE
# ==============================================================================
export RED='\e[31m'; export GREEN='\e[32m'; export YELLOW='\e[33m'; export BLUE='\e[34m'; export CYA='\e[36m'; export GRA='\e[90m'; export BOL='\e[1m'; export NC='\e[0m'

k_msg() { local type="$1"; local text="$2"; case "$type" in "-bar") echo -e "${GRA}————————————————————————————————————————————————————${NC}" ;; "-info") echo -e "${CYA}ℹ ${BOL}${text}${NC}" ;; "-ok") echo -e "${GREEN}✔ ${BOL}${text}${NC}" ;; "-warn") echo -e "${YELLOW}⚠ ${BOL}${text}${NC}" ;; "-err") echo -e "${RED}✖ ${BOL}${text}${NC}" ;; "-title") echo -e "${GRA}————————————————————————————————————————————————————${NC}"; echo -e "${BOL}${BLUE}  $text  ${NC}"; echo -e "${GRA}————————————————————————————————————————————————————${NC}" ;; esac; }
k_service() { local action="$1"; local service="$2"; service=$(echo "$service" | sed 's/\.service$//'); case "$action" in "start"|"restart"|"stop") systemctl "$action" "$service" >/dev/null 2>&1 || service "$service" "$action" >/dev/null 2>&1 ;; "status") systemctl is-active --quiet "$service" && echo -ne "${GREEN}[ON]${NC}" || echo -ne "${RED}[OFF]${NC}" ;; esac; }
k_ufw() { local port="$1"; ufw allow "$port" >/dev/null 2>&1; }
k_get_os() { [[ -f /etc/os-release ]] && . /etc/os-release && echo "$NAME" || echo "Ubuntu"; }

# --- SUB-MENUS DE PROTOCOLOS ---
sub_ssl() {
  while true; do
    clear
    k_msg -title "ADMINISTRAR SSL STUNNEL"
    echo -e " [1] Instalar / Iniciar SSL\n [2] Detener SSL\n [0] Atras"
    k_msg -bar
    echo -ne " ➤ Opción: " && read -r sub
    sub="${sub//[^0-9]/}"
    case "$sub" in
      1|01)
        k_msg -info "Iniciando instalación de SSL Stunnel..."
        apt-get install stunnel4 -y >/dev/null 2>&1
        echo -ne " Puerto SSL Externo (Ej: 443): " && read -r sslp; sslp="${sslp//[^0-9]/}"; [[ -z "$sslp" ]] && sslp="443"
        echo -ne " Puerto Destino Interno (Ej: 80 para Dropbear): " && read -r intp; intp="${intp//[^0-9]/}"; [[ -z "$intp" ]] && intp="80"
        mkdir -p /etc/stunnel
        openssl genrsa -out /etc/stunnel/stunnel.key 2048 >/dev/null 2>&1
        (echo "BR"; echo "SP"; echo "SP"; echo "ADM"; echo "ADM"; echo "KRK"; echo "@elite") | openssl req -new -key /etc/stunnel/stunnel.key -x509 -days 3650 -out /etc/stunnel/stunnel.crt >/dev/null 2>&1
        cat /etc/stunnel/stunnel.crt /etc/stunnel/stunnel.key > /etc/stunnel/stunnel.pem
        cat <<EOF > /etc/stunnel/stunnel.conf
pid = /var/run/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[SSL]
accept = $sslp
connect = 127.0.0.1:$intp
EOF
        sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 2>/dev/null
        k_service restart stunnel4 && k_ufw "$sslp" && k_msg -ok "SSL ACTIVADO (EXT: $sslp -> INT: $intp)"
        sleep 3; return ;;
      2|02)
        k_msg -warn "Deteniendo servicios SSL..."
        systemctl stop stunnel4 >/dev/null 2>&1
        systemctl stop stunnel >/dev/null 2>&1
        pkill -9 stunnel4 >/dev/null 2>&1
        pkill -9 stunnel >/dev/null 2>&1
        k_msg -ok "SSL DETENIDO CORRECTAMENTE"
        sleep 2; return ;;
      0|00) return ;;
      *) k_msg -err "Opción Inválida"; sleep 1 ;;
    esac
  done
}

sub_udp() {
  while true; do
    clear
    k_msg -title "ADMINISTRAR BADVPN UDP"
    echo -e " [1] Instalar / Iniciar BADVPN\n [2] Detener BADVPN\n [0] Atras"
    k_msg -bar
    echo -ne " ➤ Opción: " && read -r sub
    sub="${sub//[^0-9]/}"
    case "$sub" in
      1|01)
        k_msg -info "Descargando binario y activando UDP..."
        wget -O /usr/bin/badvpn-udpgw https://github.com/itxtunnel/badvpn/raw/master/badvpn-udpgw >/dev/null 2>&1; chmod +x /usr/bin/badvpn-udpgw
        pkill -9 -f badvpn-udpgw >/dev/null 2>&1
        screen -dmS bdvpn /usr/bin/badvpn-udpgw --listen-addr 0.0.0.0:7300 --max-clients 1000
        k_ufw 7300; k_msg -ok "UDP ACTIVADO EN PUERTO 7300"
        sleep 3; return ;;
      2|02)
        k_msg -warn "Apagando BadVPN UDP Gateway..."
        pkill -9 -f badvpn-udpgw >/dev/null 2>&1
        k_msg -ok "UDP DETENIDO CORRECTAMENTE"
        sleep 2; return ;;
      0|00) return ;;
      *) k_msg -err "Opción Inválida"; sleep 1 ;;
    esac
  done
}

sub_dropbear() {
  while true; do
    clear
    k_msg -title "ADMINISTRAR DROPBEAR"
    echo -e " [1] Instalar / Iniciar DROPBEAR\n [2] Detener DROPBEAR\n [0] Atras"
    k_msg -bar
    echo -ne " ➤ Opción: " && read -r sub
    sub="${sub//[^0-9]/}"
    case "$sub" in
      1|01)
        k_msg -info "Instalando Dropbear..."
        apt-get install dropbear -y >/dev/null 2>&1
        echo -ne " Puertos (Ej: 80 443 22): " && read -r dpts
        dpts=$(echo "$dpts" | tr -d '\r')
        [[ -z "$dpts" ]] && dpts="80 22"
        sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config 2>/dev/null
        args=""
        for p in $dpts; do args="$args -p $p"; k_ufw "$p"; done
        cat <<EOF > /etc/default/dropbear
NO_START=0
DROPBEAR_EXTRA_ARGS="$args"
DROPBEAR_RECEIVE_WINDOW=65536
EOF
        k_service restart dropbear && k_msg -ok "DROPBEAR ACTIVADO EN PUERTOS: $dpts"
        sleep 3; return ;;
      2|02)
        k_msg -warn "Deteniendo Dropbear..."
        k_service stop dropbear >/dev/null 2>&1
        pkill -9 dropbear >/dev/null 2>&1
        k_msg -ok "DROPBEAR DETENIDO"
        sleep 2; return ;;
      0|00) return ;;
      *) k_msg -err "Opción Inválida"; sleep 1 ;;
    esac
  done
}

menu_protocols() {
  while true; do
    clear
    k_msg -title "GESTIÓN DE PROTOCOLOS ELITE"
    echo -e " [1] Administrar SSL STUNNEL\n [2] Administrar BADVPN UDP\n [3] Administrar DROPBEAR\n [0] VOLVER AL MENÚ PRINCIPAL"
    k_msg -bar
    echo -ne " ➤ Opción: " && read -r psel
    psel="${psel//[^0-9]/}"
    case "$psel" in
      1|01) sub_ssl ;;
      2|02) sub_udp ;;
      3|03) sub_dropbear ;;
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
    echo -ne " ➤ Elija: " && read -r usel
    usel="${usel//[^0-9]/}"
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
    echo -ne " ➤ Opciön: " && read -r sel
    sel="${sel//[^0-9]/}"
    
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
