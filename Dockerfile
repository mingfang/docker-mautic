FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN locale-gen en_US en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /etc/bash.bashrc
RUN apt-get update

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh

#Required
RUN apt-get install -y cron nginx php-fpm php-xml php-mbstring php-mysql php-mcrypt php-intl php-zip php-imap php-curl composer

#Mautic
RUN wget -O - https://github.com/mautic/mautic/archive/2.5.1.tar.gz | tar zx -C /var/www/html --strip-components=1 && \
    cd /var/www/html && \
    mkdir -p .git/hooks && \
    composer install && \
    chown -R www-data:www-data /var/www/html
    
COPY local.php /var/www/html/app/config/
RUN  chown -R www-data:www-data /var/www/html
COPY default /etc/nginx/sites-enabled/

ENV DB_HOST=localhost DB_PORT=3306 DB_USER=root DB_PASS= DB_NAME=mautic MAILER_FROM_NAME='mautic'

COPY crontab /

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO
