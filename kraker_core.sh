#!/bin/bash
# ==============================================================================
# KRAKER ELITE CORE - LIBRERÍA DE SISTEMA (v2.0)
# Diseño Minimalista | Rendimiento Optimizado | Ubuntu 24.04 Ready
# ==============================================================================

# 1. Definicion de Colores Elite (HSL Tailored)
export RED='\e[38;5;196m'
export GREEN='\e[38;5;46m'
export YELLOW='\e[38;5;226m'
export BLUE='\e[38;5;33m'
export MAGENTA='\e[38;5;201m'
export CYAN='\e[38;5;51m'
export WHITE='\e[37m'
export GRAY='\e[90m'
export BOLD='\e[1m'
export NC='\e[0m'

# 2. Rutas del Sistema Elite
export K_DIR="/etc/kraker"
export K_PRT="${K_DIR}/protocols"
export K_USR="${K_DIR}/users"
export K_LOG="${K_DIR}/logs"
export K_CONF="${K_DIR}/kraker.conf"

# Asegurar Estructura
mkdir -p "${K_PRT}" "${K_USR}" "${K_LOG}"

# 3. Mensajería Estilizada
k_msg() {
  local type="$1"
  local text="$2"
  case "$type" in
    "-bar")  echo -e "${GRAY}————————————————————————————————————————————————————${NC}" ;;
    "-info") echo -e "${CYAN}ℹ ${WHITE}${text}${NC}" ;;
    "-ok")   echo -e "${GREEN}✔ ${WHITE}${text}${NC}" ;;
    "-warn") echo -e "${YELLOW}⚠ ${WHITE}${text}${NC}" ;;
    "-err")  echo -e "${RED}✖ ${BOLD}${text}${NC}" ;;
    "-title")
      echo -e "${GRAY}————————————————————————————————————————————————————${NC}"
      echo -e "${BLUE}${BOLD}  $text  ${NC}"
      echo -e "${GRAY}————————————————————————————————————————————————————${NC}"
      ;;
  esac
}

# 4. Gestión de Servicios (Elite Edition)
k_service() {
  local action="$1"
  local service="$2"
  service=$(echo "$service" | sed 's/\.service$//')
  
  case "$action" in
    "start"|"restart"|"stop")
      systemctl "$action" "$service" >/dev/null 2>&1 || service "$service" "$action" >/dev/null 2>&1
      ;;
    "status")
      systemctl is-active --quiet "$service" && echo -e "${GREEN}[ON]${NC}" || echo -e "${RED}[OFF]${NC}"
      ;;
  esac
}

# 5. Cortafuegos Inteligente
k_ufw() {
  local port="$1"
  local proto="${2:-tcp}"
  if command -v ufw >/dev/null; then
    # Garantizar que UFW esté activo sin bloqueo accidental
    if ! ufw status | grep -q "Status: active"; then
      ufw allow 22/tcp >/dev/null 2>&1
      echo "y" | ufw enable >/dev/null 2>&1
    fi
    ufw allow "${port}/${proto}" >/dev/null 2>&1
  fi
}

k_ufw_rm() {
  ufw delete allow "$1" >/dev/null 2>&1
}

# 6. Monitoreo de Red (Journal-Based)
k_net_monitor() {
  local user="$1"
  # Detección real mediante journalctl para Ubuntu Moderno
  journalctl --since today | grep -iE "sshd.*Accepted|dropbear.*Password" | grep -w "$user" | wc -l
}

export -f k_msg k_service k_ufw k_ufw_rm k_net_monitor
