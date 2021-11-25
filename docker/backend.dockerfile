FROM ubuntu:20.04

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y update
RUN apt-get -y install apache2 \
    git \
    composer \
    php \
    php-xml

RUN rm -R /var/www/html/
RUN git clone https://github.com/n-baranov/copy-laravel-project-master.git /var/www/html
RUN chmod -R 777 /var/www/html/
WORKDIR /var/www/html/
RUN composer install
RUN composer update
RUN cp .env.example .env
RUN php artisan key:generate

RUN chmod 777 /etc/apache2/mods-enabled/dir.conf

RUN echo '<IfModule mod_dir.c>' > /etc/apache2/mods-enabled/dir.conf
RUN echo '       DirectoryIndex server.php index.html index.cgi index.pl index.php index.xhtml index.htm' >> /etc/apache2/mods-enabled/dir.conf
RUN echo '</IfModule>' >> /etc/apache2/mods-enabled/dir.conf

CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
EXPOSE 80
