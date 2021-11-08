FROM ubuntu:20.04

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y update
RUN apt-get -y install apache2
RUN apt-get install -y git
RUN apt-get install -y composer
RUN apt-get install -y php
RUN apt-get install -y php-xml

RUN rm -R /var/www/html/
RUN git clone https://github.com/n-baranov/copy-laravel-project-master.git /var/www/html
RUN chmod -R 777 /var/www/html/
RUN cd /var/www/html/ && composer install
RUN cd /var/www/html/ && composer update
RUN cp /var/www/html/.env.example /var/www/html/.env
RUN php /var/www/html/artisan key:generate 

RUN chmod 777 /etc/apache2/mods-enabled/dir.conf

RUN echo '<IfModule mod_dir.c>' > /etc/apache2/mods-enabled/dir.conf
RUN echo '       DirectoryIndex server.php index.html index.cgi index.pl index.php index.xhtml index.htm' >> /etc/apache2/mods-enabled/dir.conf
RUN echo '</IfModule>' >> /etc/apache2/mods-enabled/dir.conf

CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
EXPOSE 80