#!/bin/bash
# ==============================================================================
# SSL STUNNEL MANAGER - KRAKER REFACTORED
# ==============================================================================
[[ -f /etc/newadm/kraker_core.sh ]] && source /etc/newadm/kraker_core.sh || source ./kraker_core.sh

# Aliases para compatibilidad con código existente
alias msg=kraker_msg
alias fun_trans=kraker_trans
alias mportas=kraker_list_ports
alias fun_bar=kraker_bar

ssl_stunel() {
  # Verificar si ya está corriendo para detenerlo
  if pgrep -x stunnel4 > /dev/null || ss -tunlp | grep -qi "stunnel"; then
    kraker_msg -ama "Deteniendo Stunnel4..."
    local p_off=$(grep "accept =" /etc/stunnel/stunnel.conf 2>/dev/null | awk '{print $NF}')
    for p in $p_off; do ufw delete allow "$p" > /dev/null 2>&1; done
    kraker_service stop stunnel4
    pkill -9 stunnel4 > /dev/null 2>&1
    kraker_msg -verd "Detenido con éxito!"
    return 0
  fi

  kraker_msg -bar
  kraker_msg -azu "INSTALADOR SSL - KRAKER CORE"
  kraker_msg -bar
  
  # Selección de Puerto Local
  while true; do
    read -p " Puerto Local (Ej: 22, 80, 443): " portx
    [[ $(mportas | grep -w "$portx") ]] && break || kraker_msg -verm "Puerto no activo en el sistema."
  done
  
  DPORT=$(mportas | grep -w "$portx" | awk '{print $2}' | head -1)
  
  # Selección de Puerto SSL
  while true; do
    read -p " Puerto para SSL (Escucha): " SSLPORT
    [[ $(mportas | grep -w "$SSLPORT") ]] && kraker_msg -verm "Puerto ya en uso." || break
  done

  kraker_msg -bar
  kraker_msg -ama "Instalando Stunnel4..."
  kraker_bar "apt-get install stunnel4 -y"

  # Configuración Quirúrgica
  echo -e "client = no\n[SSL]\ncert = /etc/stunnel/stunnel.pem\naccept = ${SSLPORT}\nconnect = 127.0.0.1:${DPORT}" > /etc/stunnel/stunnel.conf
  
  # Certificado Auto-Firmado Profesional
  openssl genrsa -out stunnel.key 2048 > /dev/null 2>&1
  (echo "MX"; echo "Kraker"; echo "Master"; echo "IT"; echo "Dev"; echo "SSL"; echo "@vpsmx") | openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt > /dev/null 2>&1
  cat stunnel.crt stunnel.key > /etc/stunnel/stunnel.pem
  rm stunnel.crt stunnel.key

  sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 2>/dev/null
  kraker_service restart stunnel4
  kraker_ufw "$SSLPORT"

  kraker_msg -bar
  kraker_msg -verd "SSL INSTALADO CON ÉXITO EN PUERTO $SSLPORT"
  kraker_msg -bar
}

# Menu de SSL
clear
kraker_msg -bar
kraker_msg -azu "GESTOR SSL STUNNEL4 - REFACTORED"
kraker_msg -bar
echo -e " 1) INICIAR / DETENER SSL"
echo -e " 2) SALIR"
kraker_msg -bar
read -p " Seleccione una opción: " opcao

case $opcao in
  1) ssl_stunel ;;
  *) exit ;;
esac