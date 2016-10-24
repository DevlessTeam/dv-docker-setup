FROM linuxconfig/nginx
MAINTAINER Lubos Rendek <web@linuxconfig.org>

ENV DEBIAN_FRONTEND noninteractive

# Main package installation
RUN apt-get update
RUN apt-get -y install supervisor php5-cgi mysql-server php5-mysql 

# Extra package installation
RUN apt-get -y install php5-gd php-apc php5-mcrypt

# Nginx configuration
ADD default /etc/nginx/sites-available/

# PHP FastCGI script
ADD php-fcgi /usr/local/sbin/
RUN chmod o+x /usr/local/sbin/php-fcgi

# Supervisor configuration files
ADD supervisord.conf /etc/supervisor/
ADD supervisor-lemp.conf /etc/supervisor/conf.d/

# Create new MySQL admin user
RUN service mysql start; mysql -u root -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'pass';";mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;";mysql -u root -e "CREATE DATABASE 'devless_production';" 

# MySQL configuration
RUN sed -i 's/bind-address/#bind-address/' /etc/mysql/my.cnf

WORKDIR /var/www

# Install software
RUN apt-get install -y git
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Pull in DevLess
RUN unlink /var/www/html
RUN git clone https://github.com/DevlessTeam/DV-PHP-CORE.git html
RUN composer install
ADD .env /var/www/html
RUN php artisan migrate
RUN chmod -R 777 /var/www/html

EXPOSE 80 3306

CMD ["supervisord"]
