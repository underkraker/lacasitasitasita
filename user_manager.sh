#!/bin/bash
# ==============================================================================
# KRAKER ELITE USER MANAGER (v2.0)
# ==============================================================================
[[ -f /etc/kraker/core.sh ]] && source /etc/kraker/core.sh || source ./kraker_core.sh

clear
k_msg -title "ADMINISTRACIÓN DE USUARIOS ELITE"

# -- Función: Crear Usuario --
add_user() {
  read -p " Nombre de Usuario: " user
  read -p " Contraseña: " pass
  read -p " Días de validez: " days
  
  exp_date=$(date '+%C%y-%m-%d' -d " + $days days")
  useradd -M -s /bin/false "$user" -e "$exp_date" > /dev/null 2>&1
  (echo "$pass"; echo "$pass") | passwd "$user" > /dev/null 2>&1
  
  if id "$user" &>/dev/null; then
     k_msg -ok "Usuario $user creado por $days días."
  else
     k_msg -err "Fallo al crear usuario $user."
  fi
}

# -- Función: Monitoreo Real-Time --
monitor_users() {
  k_msg -info "Conectados (Journal-Based):"
  k_msg -bar
  # Escaneo real de Journalctl para mayor precisión en Ubuntu modernio
  journalctl --since "1 hour ago" | grep -iE "sshd.*Accepted|dropbear.*Password" | awk '{print $1,$2,$3, "→", $NF}' | tail -n 10
  k_msg -bar
}

# --- MENÚ DE USUARIOS ---
echo -e " [01] ${CYAN}Añadir Nuevo Usuario${NC}"
echo -e " [02] ${CYAN}Remover Usuario${NC}"
echo -e " [03] ${CYAN}Monitor de Conexiones${NC}"
echo -e " [04] ${CYAN}Ver Usuarios Registrados${NC}"
k_msg -bar
echo -e " [00] ${RED}VOLVER AL MENU PRINCIPAL${NC}"
k_msg -bar

read -p " Seleccione: " sel

case "$sel" in
  01) add_user ;;
  03) monitor_users ;;
  00) exec ./menu ;;
  *) exec "$0" ;;
esac

read -p " Presione ENTER para continuar..."
exec "$0"
