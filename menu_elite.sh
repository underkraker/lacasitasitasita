#!/bin/bash
# DASHBOARD ELITE - VPS-MX MOD
# Autor: Antigravity AI Expert
# Versión: 1.0 (Beta Elite)

# Colores Profesionales
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Función para obtener datos del sistema
get_stats() {
    OS_NAME=$(grep -oP '(?<=^PRETTY_NAME=").*(?=")' /etc/os-release || echo "Linux")
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    RAM_TOTAL=$(free -m | awk '/Mem:/ { print $2 }')
    RAM_USED=$(free -m | awk '/Mem:/ { print $3 }')
    RAM_PERC=$(awk "BEGIN {printf \"%.1f\", ($RAM_USED/$RAM_TOTAL)*100}")
    DISK_PERC=$(df -h / | awk '/\// {print $5}')
    UPTIME=$(uptime -p | sed 's/up //')
    IP_PUB=$(curl -s --connect-timeout 2 https://v4.ident.me || echo "Error IP")
}

# Función para verificar servicios
check_service() {
    if netstat -tulnp | grep -q ":$1 "; then
        echo -e "${GREEN}ACTIVO${NC}"
    else
        echo -e "${RED}APAGADO${NC}"
    fi
}

# Función contador de usuarios (SSH, SSL, Proxy)
count_users() {
    SSH_USERS=$(who | wc -l)
    DROP_USERS=$(netstat -tnpa | grep 'dropbear' | grep 'ESTABLISHED' | wc -l)
    SSL_USERS=$(netstat -tnpa | grep 'stunnel' | grep 'ESTABLISHED' | wc -l)
    PROXY_USERS=$(netstat -tnpa | grep 'python' | grep 'ESTABLISHED' | wc -l)
    TOTAL_USERS=$((SSH_USERS + DROP_USERS + SSL_USERS + PROXY_USERS))
}

# Pantalla Principal
show_dashboard() {
    clear
    get_stats
    count_users
    echo -e "${RED}————————————————————————————————————————————————————${NC}"
    echo -e "${CYAN}        👑  DASHBOARD ELITE - VPS-MX  👑${NC}"
    echo -e "${RED}————————————————————————————————————————————————————${NC}"
    echo -e "${WHITE}  SISTEMA:   ${YELLOW}$OS_NAME${NC}"
    echo -e "${WHITE}  IP PÚBLICA:${YELLOW} $IP_PUB${NC}"
    echo -e "${WHITE}  UPTIME:    ${YELLOW} $UPTIME${NC}"
    echo -e "${RED}————————————————————————————————————————————————————${NC}"
    echo -e "${CYAN}  RECURSOS EN TIEMPO REAL:${NC}"
    echo -e "  [${RED}CPU${NC}]: $CPU_USAGE%  | [${GREEN}RAM${NC}]: $RAM_PERC% ($RAM_USED MB) | [${BLUE}DISK${NC}]: $DISK_PERC"
    echo -e "${RED}————————————————————————————————————————————————————${NC}"
    echo -e "${CYAN}  ESTADO DE SERVICIOS:${NC}"
    echo -e "  SSH (22):    $(check_service 22)  |  DROPBEAR:   $(check_service 80)"
    echo -e "  SSL (443):   $(check_service 443)  |  SQUID PROXY:$(check_service 3128)"
    echo -e "  V2RAY:       $(check_service 10086) |  PYTHON PROXY:$(check_service 8799)"
    echo -e "${RED}————————————————————————————————————————————————————${NC}"
    echo -e "${CYAN}  USUARIOS CONECTADOS:${NC} ${WHITE}$TOTAL_USERS${NC}"
    echo -e "  SSH: $SSH_USERS | SSL: $SSL_USERS | PROXY: $PROXY_USERS | DROPBEAR: $DROP_USERS"
    echo -e "${RED}————————————————————————————————————————————————————${NC}"
    echo -e "${YELLOW}  Presiona [CTRL+C] para salir del monitor...${NC}"
}

# Bucle de refresco
if [[ "$1" == "--loop" ]]; then
    while true; do
        show_dashboard
        sleep 5
    done
else
    show_dashboard
fi
