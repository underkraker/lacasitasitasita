#!/bin/bash
# OPTIMIZADOR ELITE - RED Y KERNEL (BBR + TCP)
# Autor: Antigravity AI Expert
# Versión: 1.0 (Elite Edition)

# 1. Habilitar Google BBR para baja latencia en redes móviles
if ! grep -q "net.core.default_qdisc=fq" /etc/sysctl.conf; then
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
fi

# 2. Optimizaciones de Red (TCP Fast Open, Buffers, etc.)
cat <<EOF > /etc/sysctl.d/99-elite-vps.conf
# Optimizaciones para Proxies y VPNs
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.core.somaxconn = 4096
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.ip_local_port_range = 10000 65000
net.core.netdev_max_backlog = 10000
EOF

# Aplicar cambios
sysctl -p /etc/sysctl.conf > /dev/null 2>&1
sysctl --system > /dev/null 2>&1

echo "Optimización de Kernel (BBR + TCP) aplicada con éxito."
