#!/bin/bash
# ==============================================================================
# KRAKER MASTER CORE - LIBRERIA MAESTRA (v1.0)
# Autor: Antigravity Expert (20+ Years Exp)
# ==============================================================================

# 1. Definicion de Colores Globales (Paleta Curada)
export RED='\e[31m'
export GREEN='\e[32m'
export YELLOW='\e[33m'
export BLUE='\e[34m'
export MAGENTA='\e[35m'
export CYAN='\e[36m'
export WHITE='\e[37m'
export BOLD='\e[1m'
export NC='\e[0m'

# 2. Rutas del Sistema
export SCP_DIR="/etc/newadm"
export SCP_INST="/etc/ger-inst"
export SCP_FRM="/etc/ger-frm"
export SCP_USER="/etc/newadm/ger-user"
export TG_TOKEN_FILE="/etc/newadm/token.conf"

# 3. Configuraciones Externas
if [[ -f "$TG_TOKEN_FILE" ]]; then
    export TG_TOKEN=$(cat "$TG_TOKEN_FILE")
else
    export TG_TOKEN="862633455:AAGJ9BBJanzV6yYwLSemNAZAVwn7EyjrtcY"
fi

# 3. Funcion de Mensajeria (UI Consistente)
kraker_trans() {
  local texto="$1"
  # Por ahora devolvemos el texto original, pero la estructura está lista para trans
  echo "$texto"
}

kraker_msg() {
  local type="$1"
  local text="$2"
  local translated=$(kraker_trans "$text")
  case "$type" in
    "-bar") echo -e "${CYAN}————————————————————————————————————————————————————${NC}" ;;
    "-bar2") echo -e "${MAGENTA}====================================================${NC}" ;;
    "-ama") echo -e "${YELLOW}${BOLD}${translated}${NC}" ;;
    "-azu") echo -e "${BLUE}${BOLD}${translated}${NC}" ;;
    "-verd") echo -e "${GREEN}${BOLD}${translated}${NC}" ;;
    "-verm") echo -e "${RED}${BOLD}[!] ${translated}${NC}" ;;
    "-bra") echo -e "${WHITE}${translated}${NC}" ;;
    "-info") echo -e "${WHITE}${translated}${NC}" ;;
    *) echo -e "${translated}" ;;
  esac
}


# 4. Detección Profesional de IP (Multi-Fallback)
kraker_get_ip() {
  if [[ -f "/etc/KRAKER_IP" ]]; then
    cat "/etc/KRAKER_IP"
  else
    local IP_PUB
    IP_PUB=$(curl -s -4 icanhazip.com || curl -s -4 ifconfig.me || curl -s -4 api.ipify.org)
    [[ -z "$IP_PUB" ]] && IP_PUB=$(ip addr show | grep -Po 'inet \K[\d.]+' | grep -v '127.0.0.1' | head -n1)
    echo "$IP_PUB" > "/etc/KRAKER_IP"
    echo "$IP_PUB"
  fi
}

# 5. Detección Robusta de Sistema Operativo
kraker_get_os() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "$NAME $VERSION_ID"
  else
    echo "Unknown OS"
  fi
}

# 6. validador de Puertos (Filtro de Ruido)
kraker_port_status() {
  local port="$1"
  if ss -tunlp | grep -q ":${port} "; then
    echo -e "${GREEN}[ON]${NC}"
  else
    echo -e "${RED}[OFF]${NC}"
  fi
}

kraker_list_ports() {
  ss -tunlp | grep LISTEN | grep -v 127.0.0.1 | awk '{split($5,a,":"); split($7,b,"\""); print b[2], a[length(a)]}' | sort -u
}


# 7. Gestor de Servicios Universal
kraker_service() {
  local action="$1" # start, stop, restart, status
  local service="$2"
  
  # Limpiar nombre del servicio
  service=$(echo "$service" | sed 's/\.service$//')
  
  case "$action" in
    "start"|"restart"|"stop")
      systemctl "$action" "$service" >/dev/null 2>&1 || service "$service" "$action" >/dev/null 2>&1
      ;;
    "status")
      systemctl is-active --quiet "$service" || service "$service" status >/dev/null 2>&1
      ;;
  esac
  return $?
}

# 8. Barra de Progreso Visual
kraker_bar() {
  local cmd="$1"
  $cmd >/dev/null 2>&1 &
  local pid=$!
  echo -ne " ${YELLOW}[ "
  while kill -0 $pid 2>/dev/null; do
    echo -ne "${RED}##"
    sleep 0.5
  done
  echo -e "${YELLOW} ] - ${GREEN}100%${NC}"
}

# 9. Seguridad en Firewall (UFW Safe Allow)
kraker_ufw() {
  local port="$1"
  if command -v ufw >/dev/null; then
    # Asegurar que el firewall esté activo (pero no bloquear SSH)
    ufw status | grep -q "Status: active" || {
      ufw allow 22/tcp >/dev/null 2>&1
      echo "y" | ufw enable >/dev/null 2>&1
    }
    ufw allow "$port" >/dev/null 2>&1
  fi
}

export -f kraker_msg kraker_get_ip kraker_get_os kraker_port_status kraker_service kraker_bar kraker_ufw
