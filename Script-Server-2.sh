#!/bin/bash
##Segunda parte del Script. Ejecutar después de instalar OCS Inventory Server
#Reiniciar Apache
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
sed -i "s/define("PSWD_BASE","ocs");/define("PSWD_BASE","$PWD_BD_OCS");/" /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php
sed -i "s/OCS_DB_PWD ocs/OCS_DB_PWD $PWD_BD_OCS/" /etc/apache2/conf-enabled/z-ocsinventory-server.conf
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
