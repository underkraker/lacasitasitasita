#!/bin/bash
#19/12/2019
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
port () {
local portas
local portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
i=0
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e ${portas}|grep -w "$var1 $var2")" ]] || {
    portas+="$var1 $var2\n"
    echo "$var1 $var2"
    let i++
    }
done <<< "$portas_var"
}
verify_port () {
local SERVICE="$1"
local PORTENTRY="$2"
[[ ! $(echo -e $(port|grep -v ${SERVICE})|grep -w "$PORTENTRY") ]] && return 0 || return 1
}
edit_squid () {
msg -azu "$(fun_trans "REDEFINIR PUERTOS SQUID")"
msg -bar
if [[ -e /etc/squid/squid.conf ]]; then
local CONF="/etc/squid/squid.conf"
elif [[ -e /etc/squid3/squid.conf ]]; then
local CONF="/etc/squid3/squid.conf"
fi
NEWCONF="$(cat ${CONF}|grep -v "http_port")"
msg -ne "$(fun_trans "Nuevos Puertos"): "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port squid "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
return 1
}
done
local TMPCONF=$(mktemp)
while read varline; do
echo -e "${varline}" >> ${TMPCONF}
 if [[ "${varline}" = "#portas" ]]; then
  for NPT in $(echo ${newports}); do
  echo -e "http_port ${NPT}" >> ${TMPCONF}
  done
 fi
done <<< "${NEWCONF}"
mv -f ${TMPCONF} ${CONF}
for PTS in `echo ${newports}`; do kraker_ufw "$PTS"; done
msg -azu "$(fun_trans "AGUARDE")"
kraker_service restart squid || kraker_service restart squid3
sleep 1s
msg -bar
msg -azu "$(fun_trans "PUERTOS REDEFINIDOS")"
msg -bar
}
edit_apache () {
msg -azu "$(fun_trans "REDEFINIR PUERTOS APACHE")"
msg -bar
local CONF="/etc/apache2/ports.conf"
local NEWCONF="$(cat ${CONF})"
msg -ne "$(fun_trans "Nuevos Puertos"): "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port apache "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
return 1
}
done
local TMPCONF=$(mktemp)
while read varline; do
if [[ $(echo ${varline}|grep -w "Listen") ]]; then
 if [[ -z ${END} ]]; then
 echo -e "Listen ${newports}" >> ${TMPCONF}
 END="True"
 else
 echo -e "${varline}" >> ${TMPCONF}
 fi
else
echo -e "${varline}" >> ${TMPCONF}
fi
done <<< "${NEWCONF}"
mv -f ${TMPCONF} ${CONF}
for PTS in `echo ${newports}`; do kraker_ufw "$PTS"; done
msg -azu "$(fun_trans "AGUARDE")"
kraker_service restart apache2
sleep 1s
msg -bar
msg -azu "$(fun_trans "PUERTOS REDEFINIDOS")"
msg -bar
}
edit_openvpn () {
msg -azu "$(fun_trans "REDEFINIR PUERTOS OPENVPN")"
msg -bar
local CONF="/etc/openvpn/server.conf"
local CONF2="/etc/openvpn/client-common.txt"
local NEWCONF="$(cat ${CONF}|grep -v [Pp]ort)"
local NEWCONF2="$(cat ${CONF2})"
msg -ne "$(fun_trans "Nuevos puertos"): "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port openvpn "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
return 1
}
done
local TMPCONF=$(mktemp)
while read varline; do
echo -e "${varline}" >> ${TMPCONF}
if [[ ${varline} = "proto tcp" ]]; then
echo -e "port ${newports}" >> ${TMPCONF}
fi
done <<< "${NEWCONF}"
mv -f ${TMPCONF} ${CONF}
local TMPCONF2=$(mktemp)
while read varline; do
if [[ $(echo ${varline}|grep -v "remote-random"|grep "remote") ]]; then
echo -e "$(echo ${varline}|cut -d' ' -f1,2) ${newports} $(echo ${varline}|cut -d' ' -f4)" >> ${TMPCONF2}
else
echo -e "${varline}" >> ${TMPCONF2}
fi
done <<< "${NEWCONF2}"
mv -f ${TMPCONF2} ${CONF2}
for PTS in `echo ${newports}`; do kraker_ufw "$PTS"; done
msg -azu "$(fun_trans "AGUARDE")"
kraker_service restart openvpn
sleep 1s
msg -bar
msg -azu "$(fun_trans "PUERTOS REDEFINIDOS")"
msg -bar
}
edit_dropbear () {
msg -azu "$(fun_trans "REDEFINIR PUERTOS DROPBEAR")"
msg -bar
local CONF="/etc/default/dropbear"
local NEWCONF="$(cat ${CONF}|grep -v "DROPBEAR_EXTRA_ARGS")"
msg -ne "$(fun_trans "Nuevos Puertos"): "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port dropbear "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
return 1
}
done
local TMPCONF=$(mktemp)
while read varline; do
echo -e "${varline}" >> ${TMPCONF}
 if [[ ${varline} = "NO_START=0" ]]; then
 echo -e 'DROPBEAR_EXTRA_ARGS="VAR"' >> ${TMPCONF}
 for NPT in $(echo ${newports}); do
 sed -i "s/VAR/-p ${NPT} VAR/g" ${TMPCONF}
 done
 sed -i "s/VAR//g" ${TMPCONF}
 fi
done <<< "${NEWCONF}"
mv -f ${TMPCONF} ${CONF}
for PTS in `echo ${newports}`; do kraker_ufw "$PTS"; done
msg -azu "$(fun_trans "AGUARDE")"
kraker_service restart dropbear
sleep 1s
msg -bar
msg -azu "$(fun_trans "PUERTOS REDEFINIDOS")"
msg -bar
}
edit_openssh () {
msg -azu "$(fun_trans "REDEFINIR PUERTOS OPENSSH")"
msg -bar
local CONF="/etc/ssh/sshd_config"
local NEWCONF="$(cat ${CONF}|grep -v [Pp]ort)"
msg -ne "$(fun_trans "Nuevos Puertos"): "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port sshd "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
return 1
}
done
local TMPCONF=$(mktemp)
for NPT in $(echo ${newports}); do
echo -e "Port ${NPT}" >> ${TMPCONF}
done
while read varline; do
echo -e "${varline}" >> ${TMPCONF}
done <<< "${NEWCONF}"
mv -f ${TMPCONF} ${CONF}
for PTS in `echo ${newports}`; do kraker_ufw "$PTS"; done
msg -azu "$(fun_trans "AGUARDE")"
kraker_service restart ssh || kraker_service restart sshd
sleep 1s
msg -bar
msg -azu "$(fun_trans "PUERTOS REDEFINIDOS")"
msg -bar
}
main_fun () {
msg -azu "$(fun_trans "Gestor de Puertos By Mod MEX")"
msg -bar
unset newports
i=0
while read line; do
let i++
          case $line in
          squid|squid3)squid=$i;; 
          apache|apache2)apache=$i;; 
          openvpn)openvpn=$i;; 
          dropbear)dropbear=$i;; 
          sshd)ssh=$i;; 
          esac
done <<< "$(port|cut -d' ' -f1|sort -u)"
for((a=1; a<=$i; a++)); do
[[ $squid = $a ]] && echo -ne "\033[1;32m [$squid] > " && msg -azu "$(fun_trans "REDEFINIR PUERTOS SQUID")"
[[ $apache = $a ]] && echo -ne "\033[1;32m [$apache] > " && msg -azu "$(fun_trans "REDEFINIR PUERTOS APACHE")"
[[ $openvpn = $a ]] && echo -ne "\033[1;32m [$openvpn] > " && msg -azu "$(fun_trans "REDEFINIR PUERTOS OPENVPN")"
[[ $dropbear = $a ]] && echo -ne "\033[1;32m [$dropbear] > " && msg -azu "$(fun_trans "REDEFINIR PUERTOS DROPBEAR")"
[[ $ssh = $a ]] && echo -ne "\033[1;32m [$ssh] > " && msg -azu "$(fun_trans "REDEFINIR PUERTOS SSH")"
done
echo -ne "\033[1;32m [0] > " && msg -azu "$(fun_trans "VOLVER")"
msg -bar
while true; do
echo -ne "\033[1;37m$(fun_trans "Seleccione"): " && read selection
tput cuu1 && tput dl1
[[ ! -z $squid ]] && [[ $squid = $selection ]] && edit_squid && break
[[ ! -z $apache ]] && [[ $apache = $selection ]] && edit_apache && break
[[ ! -z $openvpn ]] && [[ $openvpn = $selection ]] && edit_openvpn && break
[[ ! -z $dropbear ]] && [[ $dropbear = $selection ]] && edit_dropbear && break
[[ ! -z $ssh ]] && [[ $ssh = $selection ]] && edit_openssh && break
[[ "0" = $selection ]] && break
done
#exit 0
}
main_fun