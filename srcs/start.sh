#!/bin/bash
service nginx start
service php7.3-fpm start
chown -R mysql: /var/lib/mysql
service mysql reload
bin/bash