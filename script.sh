#!/bin/bash
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
perl -MCPAN -e 'install Mojolicious'
perl -MCPAN -e 'install Switch'
perl -MCPAN -e 'install Plack::Handler'
#Asegurar que el módulo perl funcione en Apache
a2enmod perl
#Copiar archivos php previamente modificados y guardar cambios en apache.
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
#Eliminar archivo php install de OCS Inventory y cambiar contraseña de acceso al panel
rm /usr/share/ocsinventory-reports/ocsreports/install.php
mysql -u root <<< "set password for 'ocs'@'localhost'=password('ivm321')"
mysql -u root <<< "FLUSH PRIVILEGES;"
#Cambiar contraseña usuario root de MariaDB
mysqladmin --user=root password "ivm321"
#Actualizar contraseña de OCS Inventory en los archivos de configuración correspondientes
sed -i '2,/ocs/! {s/ocs/ivm321/'} /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php
sed -i 's/OCS_DB_PWD ocs/OCS_DB_PWD ivm321/' /etc/apache2/conf-enabled/z-ocsinventory-server.conf
systemctl restart apache2
#Instalar GLPI
cd /var/www/html
wget https://github.com/glpi-project/glpi/releases/download/10.0.0/glpi-10.0.0.tgz
tar -xzf glpi*
chmod 777 -R glpi
