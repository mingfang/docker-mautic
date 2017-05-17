FROM ubuntu:16.04 as base

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN echo "export > /etc/envvars" >> /root/.bashrc && \
    echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" | tee -a /root/.bashrc /etc/bash.bashrc && \
    echo "alias tcurrent='tail /var/log/*/current -f'" | tee -a /root/.bashrc /etc/bash.bashrc

RUN apt-get update
RUN apt-get install -y locales && locale-gen en_US en_US.UTF-8

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD export > /etc/envvars && /usr/sbin/runsvdir-start

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh rsync gettext-base

#Required
RUN apt-get install -y cron nginx php-fpm php-xml php-mbstring php-mysql php-mcrypt php-intl php-zip php-imap php-curl php-gd composer

#Mautic
RUN wget -O - https://github.com/mautic/mautic/archive/2.8.1.tar.gz | tar zx -C /var/www/html --strip-components=1 && \
    cd /var/www/html && \
    mkdir -p .git/hooks && \
    composer install && \
    chown -R www-data:www-data /var/www/html

#Put all Mautic instance config files into one directory    
RUN cd /var/www/html/app  && \
    mkdir -p local/cache/prod local/config local/themes local/idp local/media/files local/media/images local/plugins
COPY paths_local.php /var/www/html/app/config/
COPY parameters_local.php /var/www/html/app/config/
RUN  chown -R www-data:www-data /var/www/html

RUN mkdir -p /var/log/mautic && \
    chown www-data:www-data /var/log/mautic

COPY default /etc/nginx/sites-enabled/
COPY crontab /
COPY php.ini /etc/php/7.0/fpm/

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO
