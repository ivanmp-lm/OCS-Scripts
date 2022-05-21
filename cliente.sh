#!/bin/bash
##Este Script instalará y configurará un equipo basado en UNIX (testeado en Debian) como cliente para un servidor en OCS Inventory ya existente

#Variables
SERVIDOR=

#Actualizar repos
apt update
#Aprovisionar con los componentes necesarios
apt-get -y install libmodule-install-perl libdata-uuid-perl libcrypt-ssleay-perl libnet-snmp-perl libproc-pid-file-perl libproc-daemon-perl net-tools smartmontools read-edid nmap libnet-netmask-perl libxml-simple-perl libnet-ip-perl make
#Descargar cliente de OCS Inventory
wget https://github.com/OCSInventory-NG/UnixAgent/releases/tag/v2.9.1
#Desempaquetar e instalar cliente
https://github.com/OCSInventory-NG/UnixAgent/releases/download/v2.9.1/Ocsinventory-Unix-Agent-2.9.1.tar.gz
tar -zxf Ocs*
cd Ocsinventory-Unix-Agent-2.9.1
perl Makefile.PL
make
make install
y
2
y
y
$SERVIDOR
n
n
y
/var/lib/ocsinventory-agent
y
y
y
n
n
n
n
y
y
y
#Instalación completada
#Adicionalmente en la instalación se configuró una tarea en Cron para actualizar la máquina en OCS regularmente
#Eliminar archivos sobrantes
cd ..
rm -rf Ocs*
