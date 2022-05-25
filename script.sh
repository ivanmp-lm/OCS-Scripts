#!/bin/bash
##Este script instalará automáticamente OCSInventory y GLPI en un servidor Linux
##Se aprovisionará al servidor con una pila LAMP y Perl para la correcta funcionalidad del software
##Una vez finalizada la instalación se deberán configurar los componentes manualmente desde las siguientes URL
##https://DOMINIO/ocsreports y https://DOMINIO/glpi

##VARIABLES
DOMINIO=
PWD_BD_OCS=ivm321
PWD_ROOT_MYSQL=ivm321

#Debug
set -x

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
cd /OCSFiles
cp php.ini /etc/php/7.4/apache2/php.ini
cp cli/php.ini /etc/php/7.4/cli/php.ini
cp test.php /var/www/html/test.php
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
./setup.sh
y
localhost
3306
/usr/sbin/apache2ctl
/etc/apache2/apache2.conf
www-data
www-data
/etc/apache2/conf-available
/usr/bin/perl
y
/var/log/ocsinventory-server
/etc/ocsinventory-server/plugins
/etc/ocsinventory-server/perl
y
/usr/local/share/perl/5.30.0
y
y
y
/usr/share/ocsinventory-reports
/var/lib/ocsinventory-reports
systemctl restart apache2
#Habilitar archivos de configuración necesarios para OCS Inventory
a2enconf ocsinventory-reports.conf
a2enconf z-ocsinventory-server.conf
a2enconf zz-ocsinventory-restapi.conf
systemctl reload apache2
#Añadir permisos a la carpeta donde se almacenan los informes de OCS Inventory
chown -R www-data: /var/lib/ocsinventory-reports/
systemctl restart apache2
#Eliminar archivo php install de OCS Inventory y cambiar contraseña del usuario en la BD
rm /usr/share/ocsinventory-reports/ocsreports/install.php
mysql -u root <<< "set password for 'ocs'@'localhost'=password('$PWD_BD_OCS')"
mysql -u root <<< "FLUSH PRIVILEGES;"
#Actualizar contraseña de OCS Inventory en los archivos de configuración correspondientes
sed -i '2,/ocs/! {s/ocs/$PWD_BD_OCS/'} /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php
sed -i 's/OCS_DB_PWD ocs/OCS_DB_PWD $PWD_BD_OCS/' /etc/apache2/conf-enabled/z-ocsinventory-server.conf
systemctl restart apache2
#Instalar GLPI
cd /var/www/html
wget https://github.com/glpi-project/glpi/releases/download/10.0.0/glpi-10.0.0.tgz
tar -xzf glpi*
rm glpi*.tgz
chmod 777 -R glpi
cd ~
rm /var/www/html/glpi/install/install.php
#Instalar plugin para GLPI
cd /var/www/html/glpi/plugins
wget https://github.com/pluginsGLPI/ocsinventoryng/releases/download/2.0.0/glpi-ocsinventoryng-2.0.0.tar.bz2
tar -jxvf glpi*
rm glpi*.bz2
cd ~
systemctl reload apache2
#Instalación Certbot
snap install core; sudo snap refresh core
snap install --classic certbot
#Alias para ejecutar Certbot
ln -s /snap/bin/certbot /usr/bin/certbot
#Instalar certificado en Apache
certbot --apache -m pruebaocs@pruebaocs.com --agree-tos --no-eff-email -d $DOMINIO
#Cambiar contraseña usuario root de MariaDB
mysqladmin --user=root password "$PWD_ROOT_MYSQL"
