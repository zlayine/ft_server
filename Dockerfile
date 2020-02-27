FROM debian

ADD srcs/ssl-q.sh .
ADD srcs/sign-ssl.sh .

RUN apt-get update && \
    apt-get upgrade && \
    apt-get install -y wget net-tools lsb-release gnupg expect nginx openssl && \
    apt-get update && \
    wget http://repo.mysql.com/mysql-apt-config_0.8.13-1_all.deb && \
    DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.13-1_all.deb
ADD srcs/mysql.list ./etc/apt/sources.list.d/
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt install -y mysql-server && \
    apt-get install -y php-mbstring php-zip  php-gd php-xml php-pear php-gettext php-cgi && \
    wget https://files.phpmyadmin.net/phpMyAdmin/4.9.2/phpMyAdmin-4.9.2-english.tar.gz && \
    mkdir /var/www/html/phpmyadmin && \
    tar xzf phpMyAdmin-4.9.2-english.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin && \
    cp /var/www/html/phpmyadmin/config.sample.inc.php /var/www/html/phpmyadmin/config.inc.php && \
    chmod 660 /var/www/html/phpmyadmin/config.inc.php && \
    chown -R www-data:www-data /var/www/html/phpmyadmin && \
    chown -R mysql: /var/lib/mysql && \
    service mysql reload && \
    mysql -u root -e "CREATE USER 'pmauser'@'%' IDENTIFIED BY 'pass';GRANT ALL PRIVILEGES ON *.* TO 'pmauser'@'%' WITH GRANT OPTION;CREATE DATABASE wordpress_db;GRANT ALL ON wordpress_db.* TO 'wordpress_user'@'localhost' IDENTIFIED BY 'password';FLUSH PRIVILEGES;" && \
    sed -i.bak '29s/cookie/config/g' /var/www/html/phpmyadmin/config.inc.php && \
    echo "\$cfg['Servers'][\$i]['user'] = 'pmauser';" >> /var/www/html/phpmyadmin/config.inc.php && \
    echo "\$cfg['Servers'][\$i]['password'] = 'pass';" >> /var/www/html/phpmyadmin/config.inc.php && \
    apt update && \
    apt install -y php php-mysql php-fpm php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip && \
    cd /var/www/html/ && \
    wget https://wordpress.org/latest.tar.gz && \
    tar -xvf latest.tar.gz && rm latest.tar.gz && \
    chown -R www-data:www-data /var/www/html/wordpress && \
    find /var/www/html/wordpress/ -type d -exec chmod 750 {} \; && \
    find /var/www/html/wordpress/ -type f -exec chmod 640 {} \; && \
    mv wordpress/wp-config-sample.php wordpress/wp-config.php && \
    sed -i.bak '23s/database_name_here/wordpress_db/g' /var/www/html/wordpress/wp-config.php && \
    sed -i.bak '26s/username_here/wordpress_user/g' /var/www/html/wordpress/wp-config.php && \
    sed -i.bak '29s/password_here/password/g' /var/www/html/wordpress/wp-config.php

RUN chmod 700 ssl-q.sh && chmod 700 sign-ssl.sh && ./sign-ssl.sh && \
    openssl dhparam -out /etc/nginx/dhparam.pem 4096
COPY srcs/self-signed.conf /etc/nginx/snippets/
COPY srcs/ssl-params.conf /etc/nginx/snippets/
COPY srcs/default etc/nginx/sites-available/
RUN rm /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/ && \
    nginx -t

ADD srcs/start.sh .
RUN chmod 770 start.sh && \
    chown -R www-data:www-data start.sh
RUN rm -f mysql-* && rm -f *ssl* && rm -f phpMyAdmin*

EXPOSE 80
EXPOSE 443

CMD "./start.sh"
