FROM ubuntu:16.04
MAINTAINER Denis Golius <denaspireone@gmail.com>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
#ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

# PHP and nginx
RUN apt-get install htop iotop nano -y
RUN apt-get install software-properties-common python-software-properties nginx -y 
RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main" > /etc/apt/sources.list.d/ondrej-php.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
    apt-get update && \
	apt-get install php7.1 php7.1-cgi php7.1-cli php7.1-common php7.1-json php7.1-opcache php7.1-mysql php7.1-mbstring php7.1-mcrypt php7.1-zip php7.1-fpm php7.1-xml php7.1-odbc php7.1-intl php7.1-imap php7.1-gd php7.1-bz2 php7.1-bcmath -y

# Some essential tools
RUN apt-get install curl git wget net-tools vim -y

# nginx config
# Reduce keepalive timeout to 2 seconds
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.1/fpm/php.ini
# Set maximum upload size to 100M
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php/7.1/fpm/php.ini
# Set maximum post size to 100M
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php/7.1/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.1/fpm/php-fpm.conf
# Set the pid to /var/run/php/php7.0-fpm.pid
RUN sed -i -e "s|/run/php/php7.1-fpm.pid|/var/run/php/php7.1-fpm.pid|g" /etc/php/7.1/fpm/php-fpm.conf
# Set the fpm socket to /var/run/php/php7.0-fpm.sock
RUN sed -i -e "s|/run/php/php7.1-fpm.sock|/var/run/php/php7.1-fpm.sock|g" /etc/php/7.1/fpm/pool.d/www.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.1/fpm/pool.d/www.conf

RUN find /etc/php/7.1/fpm/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

RUN mkdir -p /var/run/php
RUN mkdir -p /var/log/php-fpm

# nginx site conf
ADD ./site.conf /etc/nginx/sites-available/default

RUN apt-get install python-pip -y
# Supervisor Config
RUN /usr/bin/pip install supervisor
RUN /usr/bin/pip install supervisor-stdout
ADD ./supervisord.conf /etc/supervisord.conf

# Install Wordpress
ADD https://wordpress.org/latest.tar.gz /var/www/latest.tar.gz
RUN cd /var/www && tar zxf latest.tar.gz && rm latest.tar.gz
RUN rm -rf /var/www/html
RUN mv /var/www/wordpress /var/www/html
RUN chown -R www-data:www-data /var/www/html

# Wordpress Initialization and Startup Script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# private expose
EXPOSE 80

# volume for wordpress install
VOLUME ["/var/www/html"]

CMD ["/bin/bash", "/start.sh"]
