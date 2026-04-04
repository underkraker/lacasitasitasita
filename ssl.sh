#!/bin/bash
# SSL MANAGER - KRAKER REFACTORED
[[ -f /etc/newadm/kraker_core.sh ]] && source /etc/newadm/kraker_core.sh || source ./kraker_core.sh

ssl_stunel() {
  # Detección Robusta (Procesos, Puertos o Systemd)
  if pgrep -f stunnel > /dev/null || ss -tunlp | grep -qi "stunnel" || systemctl is-active --quiet stunnel4; then
    kraker_msg -ama "Deteniendo Stunnel..."
    
    # Cerrar puertos Firewall (Opcional pero recomendado)
    if [[ -f /etc/stunnel/stunnel.conf ]]; then
       local p_off=$(grep -E "^accept =" /etc/stunnel/stunnel.conf | awk '{print $NF}')
       for p in $p_off; do [[ $p =~ ^[0-9]+$ ]] && ufw delete allow "$p" > /dev/null 2>&1; done
    fi
    
    kraker_service stop stunnel4 > /dev/null 2>&1
    kraker_service stop stunnel > /dev/null 2>&1
    pkill -9 -f stunnel > /dev/null 2>&1
    
    kraker_msg -verd "Servicio detenido y puertos cerrados."
    return 0
  fi

  kraker_msg -bar
  kraker_msg -azu "CONFIGURACIÓN SSL (STUNNEL)"
  kraker_msg -bar
  
  # Instalar si no existe
  if ! command -v stunnel4 >/dev/null; then
    kraker_msg -info "Instalando Stunnel4..."
    kraker_bar "apt-get install stunnel4 -y"
  fi

  # Selección de Puertos
  kraker_msg -ne " Puerto SSL (ej: 443): "
  read SSLPORT
  [[ -z "$SSLPORT" ]] && SSLPORT="443"
  
  kraker_msg -ne " Puerto Destino (ej: SSH=22): "
  read DPORT
  [[ -z "$DPORT" ]] && DPORT="22"

  kraker_msg -ama "Generando Certificado SSL..."
  rm -f /etc/stunnel/stunnel.pem
  openssl genrsa -out stunnel.key 2048 > /dev/null 2>&1
  (echo "BR"; echo "SP"; echo "SAO"; echo "VPS"; echo "ADM"; echo "VPS"; echo "@adm") | openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt > /dev/null 2>&1
  cat stunnel.crt stunnel.key > /etc/stunnel/stunnel.pem
  rm -f stunnel.crt stunnel.key

  kraker_msg -ama "Configurando Stunnel.conf..."
  cat <<EOF > /etc/stunnel/stunnel.conf
pid = /var/run/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[SSL]
accept = $SSLPORT
connect = 127.0.0.1:$DPORT
EOF

  sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 2>/dev/null
  systemctl enable stunnel4 >/dev/null 2>&1
  kraker_service restart stunnel4 || kraker_service restart stunnel
  
  sleep 1
  if pgrep -f stunnel > /dev/null || ss -tunlp | grep -q ":$SSLPORT "; then
     kraker_ufw "$SSLPORT"
     kraker_msg -verd "SSL ACTIVADO EN PUERTO $SSLPORT -> $DPORT"
  else
     kraker_msg -verm "ERROR: No se pudo iniciar Stunnel. Verifique puertos."
  fi
  kraker_msg -bar
}

ssl_stunel