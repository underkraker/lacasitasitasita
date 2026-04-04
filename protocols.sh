#!/bin/bash
# ==============================================================================
# KRAKER ELITE PROTOCOL MANAGER (v2.0)
# ==============================================================================
[[ -f /etc/kraker/core.sh ]] && source /etc/kraker/core.sh || source ./kraker_core.sh

clear
k_msg -title "GESTIÓN DE PROTOCOLOS ELITE"

# -- Función de Toggle Universal --
toggle_service() {
  local service=$1
  local display=$2
  local script_path=$3
  
  if systemctl is-active --quiet "$service" || pgrep -x "$service" >/dev/null; then
    k_msg -warn "Deteniendo ${display}..."
    k_service stop "$service"
    pkill -9 "$service" >/dev/null 2>&1
    k_msg -ok "${display} DESACTIVADO"
  else
    k_msg -info "Activando ${display}..."
    $script_path
    k_msg -ok "${display} ACTIVADO"
  fi
  sleep 1
}

# --- MODULO SSL (STUNNEL) ELITE ---
elite_ssl() {
  if pgrep -x stunnel4 >/dev/null; then
    k_msg -warn "Deteniendo SSL Stunnel..."
    k_service stop stunnel4
    pkill -9 stunnel4 >/dev/null 2>&1
    k_msg -ok "SSL Stunnel DESACTIVADO"
    return 0
  fi
  
  k_msg -bar
  k_msg -info "Iniciando Instalador SSL Elite..."
  apt-get install stunnel4 -y >/dev/null 2>&1
  
  read -p " Puerto SSL Destino (ej: 443): " sslp
  [[ -z "$sslp" ]] && sslp="443"
  read -p " Puerto Interno de Redirecciön (ej: SSH=22): " intp
  [[ -z "$intp" ]] && intp="22"

  k_msg -info "Generando Certificado SSL..."
  openssl genrsa -out stunnel.key 2048 > /dev/null 2>&1
  (echo "ELITE"; echo "KRK"; echo "HQ"; echo "VPS"; echo "ADM"; echo "SRV"; echo "@elite") | openssl req -new -key stunnel.key -x509 -days 3650 -out stunnel.crt > /dev/null 2>&1
  cat stunnel.crt stunnel.key > /etc/stunnel/stunnel.pem
  rm stunnel.crt stunnel.key

  cat <<EOF > /etc/stunnel/stunnel.conf
cert = /etc/stunnel/stunnel.pem
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
[ELITE-SSL]
accept = $sslp
connect = 127.0.0.1:$intp
EOF

  sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 2>/dev/null
  systemctl enable stunnel4 >/dev/null 2>&1
  k_service restart stunnel4
  k_ufw "$sslp"
  k_msg -ok "SSL ELITE ACTIVADO EN PUERTO $sslp"
}

# --- MODULO BADVPN (UDP) ELITE ---
elite_udp() {
  if pgrep -f badvpn-udpgw >/dev/null; then
    k_msg -warn "Deteniendo BadVPN Gateway..."
    pkill -9 -f badvpn-udpgw >/dev/null 2>&1
    k_msg -ok "UDP Gateway DESACTIVADO"
    return 0
  fi

  k_msg -info "Activando BadVPN UDP Gateway..."
  if [[ ! -e /usr/bin/badvpn-udpgw ]]; then
    wget -O /usr/bin/badvpn-udpgw https://github.com/itxtunnel/badvpn/raw/master/badvpn-udpgw >/dev/null 2>&1
    chmod +x /usr/bin/badvpn-udpgw
  fi
  
  screen -dmS bdvpn /usr/bin/badvpn-udpgw --listen-addr 0.0.0.0:7300 --max-clients 1000 --max-connections-for-client 10 
  k_ufw 7300 "udp"
  k_msg -ok "UDP GATEWAY ACTIVADO EN PUERTO 7300"
}

# -- MENÚ DE PROTOCOLOS --
k_msg -info "Seleccione un protocolo para Toggle (ON/OFF)"
k_msg -bar
echo -e " [01] ${CYAN}SSL STUNNEL${NC}"
echo -e " [02] ${CYAN}BADVPN (UDP:7300)${NC}"
echo -e " [03] ${CYAN}DROPBEAR SSH${NC}"
echo -e " [04] ${CYAN}SQUID PROXY${NC}"
k_msg -bar
echo -e " [00] ${RED}VOLVER AL MENU PRINCIPAL${NC}"
k_msg -bar

echo -ne " ${CYAN}➤ ${WHITE}Protocolo: ${NC}" && read prot_sel

case "$prot_sel" in
  01) elite_ssl ;;
  02) elite_udp ;;
  00) exec ./menu ;;
  *) exec "$0" ;;
esac

sleep 2
exec "$0"
