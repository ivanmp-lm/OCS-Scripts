#!/bin/bash
##Primera parte del script. Deberá ejecutarse la segunda tras instalar el servidor OCS que será descargado al final de su ejecución
##Este script instalará automáticamente OCSInventory y GLPI en un servidor Linux
##Se aprovisionará al servidor con una pila LAMP y Perl para la correcta funcionalidad del software
##Una vez finalizada la instalación se deberán configurar los componentes manualmente desde las siguientes URL
##https://DOMINIO/ocsreports y https://DOMINIO/glpi

##VARIABLES
DOMINIO=
PWD_BD_OCS=
PWD_ROOT_MYSQL=

#Actualizar repos
apt update
#Instalar MariaDB
apt -y install mariadb-server mariadb-client
#Instalar Make y GCC (necesarios para los módulos de Perl)
apt -y install git curl wget make cmake gcc make
#Instalar Apache y módulos
apt -y install libapache2-mod-perl2 libapache-dbi-perl libapache-db-perl libapache2-mod-php libarchive-zip-perl
#Instalar PHP
apt-get -y install php php-pclzip php-mysql php-zip php-gd php-mbstring php-curl php-xml php-soap php-intl
#Instalar Perl
apt -y install perl libxml-simple-perl libcompress-zlib-perl libdbi-perl libdbd-mysql-perl libnet-ip-perl libsoap-lite-perl libio-compress-perl libapache-dbi-perl  libapache2-mod-perl2 libapache2-mod-perl2-dev
#Instalar módulos Perl
cpan install XML::Entities
yes
perl -MCPAN -e 'install Mojolicious'
perl -MCPAN -e 'install Switch'
perl -MCPAN -e 'install Plack::Handler'
#Asegurar que el módulo perl funcione en Apache
a2enmod perl
#Copiar archivos php previamente modificados y guardar cambios en apache.
git clone https://github.com/ivanmp-lm/OCSFiles.git
cd OCSFiles
cp php.ini etc/php/7.4/apache2/php.ini
cp cli/php.ini etc/php/7.4/cli/php.ini
cp test.php var/www/html/test.php
cd ~
systemctl restart apache2
#Inicializar MariaDB
systemctl start mariadb
#Crear DB y USERS para OCSInventory
mysql -u root <<< "CREATE DATABASE ocsweb;"
mysql -u root <<< "CREATE USER 'ocs'@'localhost' IDENTIFIED BY 'ocs';"
mysql -u root <<< "GRANT ALL PRIVILEGES ON ocsweb.* TO 'ocs'@'localhost' WITH GRANT OPTION;"
mysql -u root <<< "FLUSH PRIVILEGES;"
#Instalar OCSInventory Server
mkdir OCS
cd OCS
wget https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/2.9.2/OCSNG_UNIX_SERVER-2.9.2.tar.gz
tar -xzf *
rm OCS*.gz
cd OCSNG_UNIX_SERVER-2.9.2
echo Primera parte de la instalación terminada. Instala el script descargado en esta misma ruta para instalar el servidor OCS
