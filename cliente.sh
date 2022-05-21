#!/bin/bash
##Este Script instalará y configurará un equipo basado en UNIX (testeado en Debian) como cliente para un servidor en OCS Inventory ya existente

#Actualizar repos
apt update
#Aprovisionar con los componentes necesarios
apt-get -y install libmodule-install-perl libdata-uuid-perl libcrypt-ssleay-perl libnet-snmp-perl libproc-pid-file-perl libproc-daemon-perl net-tools smartmontools read-edid nmap libnet-netmask-perl
#Descargar cliente de OCS Inventory
wget https://github.com/OCSInventory-NG/UnixAgent/releases/tag/v2.9.1
#Desempaquetar e instalar cliente
