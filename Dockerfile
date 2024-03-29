# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: schaya <schaya@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/02/02 17:15:22 by schaya            #+#    #+#              #
#    Updated: 2021/02/03 15:23:46 by schaya           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

RUN apt update && apt upgrade -y
RUN apt -y install wget
RUN apt-get -y install vim
RUN apt-get -y install nginx

RUN apt-get -y install mariadb-server
RUN apt-get -y install php7.3 php-mysql php-fpm php-mbstring

COPY ./srcs/default /etc/nginx/sites-available

WORKDIR /var/www/html/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-english.tar.gz
RUN tar -xf phpMyAdmin-5.0.1-english.tar.gz && rm -rf phpMyAdmin-5.0.1-english.tar.gz
RUN mv phpMyAdmin-5.0.1-english phpmyadmin

COPY ./srcs/config.sample.inc.php phpmyadmin

RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xvzf latest.tar.gz && rm -rf latest.tar.gz

COPY ./srcs/wp-config.php wordpress

RUN openssl req -x509 -nodes -days 365 -subj "/C=RU/ST=Russia/L=Moscow/O=ft_server/OU=21school/CN=localhost" -newkey rsa:2048 -keyout /etc/ssl/nginx-selfsigned.key -out /etc/ssl/nginx-selfsigned.crt;

RUN chown -R www-data:www-data *
RUN chmod -R 755 /var/www/*

COPY ./srcs/init.sh /tmp/
COPY ./srcs/autoindex.sh /tmp/

COPY ./srcs/create_bases.sh /tmp/
RUN bash /tmp/create_bases.sh

EXPOSE 80 443

CMD bash /tmp/init.sh && bash
