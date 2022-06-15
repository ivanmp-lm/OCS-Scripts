#!/bin/bash
##Este Script instalará y configurará un equipo basado en UNIX (testeado en Debian) como cliente para un servidor en OCS Inventory ya existente

#Actualizar repos
apt update
#Aprovisionar con los componentes necesarios
apt-get -y install libmodule-install-perl libdata-uuid-perl libcrypt-ssleay-perl libnet-snmp-perl libproc-pid-file-perl libproc-daemon-perl net-tools smartmontools read-edid nmap libnet-netmask-perl libxml-simple-perl libnet-ip-perl make
#Descargar cliente de OCS Inventory
wget https://github.com/OCSInventory-NG/UnixAgent/releases/download/v2.9.1/Ocsinventory-Unix-Agent-2.9.1.tar.gz
#Desempaquetar e instalar cliente
https://github.com/OCSInventory-NG/UnixAgent/releases/download/v2.9.1/Ocsinventory-Unix-Agent-2.9.1.tar.gz
tar -zxf Ocs*
cd Ocsinventory-Unix-Agent-2.9.1
perl Makefile.PL
make
echo Utiliza el comando "make install" para terminar con la instalación del cliente
