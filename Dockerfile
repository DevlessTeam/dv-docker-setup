FROM eddymens/devless-base
MAINTAINER Eddymens <edmond@devless.io>

##pull in DevLess source
RUN git clone https://github.com/DevlessTeam/DV-PHP-CORE.git html; cd html;git checkout v1.3 ;composer install
ADD .env /var/www/html
RUN service mysql start;cd html;php artisan migrate; chmod -R 777 /var/www/html

EXPOSE 80 3306

CMD ["supervisord"]
