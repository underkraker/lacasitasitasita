#!/bin/bash
# ==============================================================================
# DROPBEAR MANAGER - KRAKER REFACTORED
# ==============================================================================
[[ -f /etc/newadm/kraker_core.sh ]] && source /etc/newadm/kraker_core.sh || source ./kraker_core.sh

# Aliases para compatibilidad
alias msg=kraker_msg
alias fun_trans=kraker_trans
alias mportas=kraker_list_ports
alias fun_bar=kraker_bar

fun_dropbear() {
  # Desinstalar si existe
  if [[ -f "/etc/default/dropbear" ]]; then
    kraker_msg -ama "Removiendo Dropbear..."
    local p_off=$(grep "DROPBEAR_EXTRA_ARGS" /etc/default/dropbear | grep -oE "[0-9]+")
    for p in $p_off; do ufw delete allow "$p" > /dev/null 2>&1; done
    kraker_service stop dropbear
    pkill -9 dropbear > /dev/null 2>&1
    kraker_bar "apt-get remove dropbear -y"
    rm -f /etc/default/dropbear
    kraker_msg -verd "Dropbear removido con éxito!"
    return 0
  fi

  kraker_msg -bar
  kraker_msg -azu "INSTALADOR DROPBEAR - KRAKER CORE"
  kraker_msg -bar
  
  # Selección de Puertos
  kraker_msg -info "Ejemplos de puertos: 22, 80, 443 (separados por espacios)"
  read -p " Digite los puertos para Dropbear: " ports_raw
  
  local valid_ports=""
  for p in $ports_raw; do
    if [[ ! $(mportas | grep -w "$p") ]]; then
      kraker_msg -info "Puerto $p: ${GREEN}OK${NC}"
      valid_ports="$valid_ports $p"
    else
      kraker_msg -info "Puerto $p: ${RED}FALLO (En uso)${NC}"
    fi
  done

  [[ -z $valid_ports ]] && { kraker_msg -verm "No se seleccionó ningún puerto válido."; return 1; }

  kraker_msg -ama "Instalando Dropbear..."
  kraker_bar "apt-get install dropbear -y"

  # Configuración Quirúrgica de SSH (NO SOBREESCRIBIR)
  kraker_msg -ama "Optimizando configuración de SSH..."
  sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
  sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
  sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

  # Configuración de Dropbear
  cat <<EOF > /etc/default/dropbear
NO_START=0
DROPBEAR_EXTRA_ARGS="$(for p in $valid_ports; do echo -n "-p $p "; done)"
DROPBEAR_BANNER="/etc/dropbear/banner"
DROPBEAR_RECEIVE_WINDOW=65536
EOF

  touch /etc/dropbear/banner
  kraker_service restart ssh
  kraker_service restart dropbear

  for p in $valid_ports; do kraker_ufw "$p"; done

  kraker_msg -bar
  kraker_msg -verd "DROPBEAR INSTALADO EN: $valid_ports"
  kraker_msg -bar
}

fun_dropbear