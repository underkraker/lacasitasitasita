#!/bin/bash
# ==============================================================================
# KRAKER ELITE INSTALLER (v2.1) - FIX FORMAT & PURGE
# ==============================================================================
K_DIR="/etc/kraker"
RED='\e[31m' && GREEN='\e[32m' && NC='\e[0m'

# 1. Limpieza y Preparación
clear
echo -e "${RED}————————————————————————————————————————————————————"
echo -e " | 🛠️  REPARANDO KRAKER ELITE (v2.1) | "
echo -e "————————————————————————————————————————————————————${NC}"

# ROOT CHECK
[[ $UID -ne 0 ]] && echo -e "${RED}[!] Error: Ejecuta como root (sudo su)${NC}" && exit 1

# 2. Purga de Restos
rm -rf /etc/newadm /etc/ger-inst /etc/ger-frm /etc/kraker /usr/bin/menu /usr/bin/kraker /usr/bin/vps-mx
mkdir -p "$K_DIR/protocols" "$K_DIR/users" "$K_DIR/logs"

# 3. Descarga Directa y Limpia
echo -ne " Sincronizando repositorio Maestro... "
if [[ -d "elite_v2" ]]; then
  cd elite_v2
elif [[ -d "lacasitasitasita" ]]; then
  cd lacasitasitasita
elif [[ -f "Install.sh" ]]; then
  echo -ne " (Usando archivos locales)... "
else
  cd $HOME; rm -rf lacasitasitasita
  git clone https://github.com/underkraker/lacasitasitasita &>/dev/null
  cd lacasitasitasita
fi

# 4. PARCHE CRÍTICO: Eliminar retornos de carro (CRLF -> LF)
echo -ne " Corrigiendo formato de archivos (Linux Native)... "
for f in menu kraker_core.sh protocols.sh user_manager.sh Install.sh; do
  [[ -f "$f" ]] && sed -i 's/\r$//' "$f"
done
echo -e "${GREEN}OK${NC}"

# 5. Copia de Archivos con Validación
echo -ne " Instalando módulos Elite... "
cp kraker_core.sh "$K_DIR/core.sh" && \
cp menu "$K_DIR/menu" && \
cp protocols.sh "$K_DIR/protocols.sh" && \
cp user_manager.sh "$K_DIR/user_manager.sh" && \
chmod +x "$K_DIR"/*
echo -e "${GREEN}OK${NC}"

# 6. Alias y Enlaces
ln -sf "$K_DIR/menu" /usr/bin/menu
ln -sf "$K_DIR/menu" /usr/bin/kraker
ln -sf "$K_DIR/menu" /usr/bin/vps-mx

echo -e "${GREEN}————————————————————————————————————————————————————"
echo -e "      KRAKER ELITE v2.1 REINSTALADO Y CORREGIDO"
echo -e "————————————————————————————————————————————————————${NC}"
echo -e " Escribe ${RED}'kraker'${NC} para entrar."
echo -e "————————————————————————————————————————————————————"
