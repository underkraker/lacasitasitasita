# Sourcing Core Library
[[ -f /etc/newadm/kraker_core.sh ]] && source /etc/newadm/kraker_core.sh || source ./kraker_core.sh

BadVPN () {
  local PID_BADVPN=$(pgrep -f "badvpn-udpgw")
  
  if [[ -z "$PID_BADVPN" ]]; then
    kraker_msg -ama "ACTIVANDO BADVPN (UDP Gateway)..."
    kraker_msg -bar 
    
    if [[ ! -e /bin/badvpn-udpgw ]]; then
      kraker_msg -info "Descargando binario BadVPN..."
      wget -O /bin/badvpn-udpgw https://raw.githubusercontent.com/underkraker/lacasitasitasita/master/badvpn-udpgw &>/dev/null
      chmod +x /bin/badvpn-udpgw
    fi
    
    # Iniciar en Screen (Escuchando en todas las interfaces: 0.0.0.0)
    screen -dmS badvpn2 /bin/badvpn-udpgw --listen-addr 0.0.0.0:7300 --max-clients 1000 --max-connections-for-client 10 
    sleep 1
    
    if pgrep -f "badvpn-udpgw" > /dev/null; then
       kraker_ufw 7300
       kraker_msg -verd "ACTIVADO CON ÉXITO EN PUERTO 7300"
    else
       kraker_msg -verm "ERROR: No se pudo iniciar BadVPN"
    fi
    kraker_msg -bar
  else
    kraker_msg -ama "DESACTIVANDO BADVPN..."
    kraker_msg -bar
    pkill -9 -f "badvpn-udpgw" > /dev/null 2>&1
    ufw delete allow 7300 > /dev/null 2>&1
    kraker_msg -verd "DESACTIVADO CON ÉXITO"
    kraker_msg -bar
  fi
}

BadVPN