FROM ubuntu:22.04

ENV TZ=Asia/Shanghai
RUN apt update
RUN apt install -y wget nginx supervisor git
RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime
RUN echo ${TZ} > /etc/timezone
RUN apt install -y php8.1-bcmath php8.1-bz2 php8.1-cli php8.1-common php8.1-curl php8.1-fpm php8.1-gd php8.1-igbinary php8.1-mbstring php8.1-mysql php8.1-opcache php8.1-readline php8.1-redis php8.1-xml php8.1-yaml php8.1-zip
RUN rm -rf /var/lib/apt/lists/* /var/www/html/*
    
RUN sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' /etc/php/8.1/fpm/php.ini
RUN sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' /etc/php/8.1/cli/php.ini
RUN echo php_flag[display_errors] = on >> /etc/php/8.1/fpm/php-fpm.conf

# Add Scripts
ADD scripts/start.sh /start.sh
ADD conf/10-opcache.ini /etc/php/8.3/fpm/conf.d/10-opcache.ini
ADD conf/nginx-site.conf /etc/nginx/sites-available/default
ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/supervisord.conf /etc/supervisord.conf
ADD conf/appprofile.example.php /appprofile.example.php
RUN chmod 755 /start.sh
EXPOSE 80/tcp
# copy in code

#USER root
WORKDIR "/var/www/html"
RUN git clone -b 2023.4 https://github.com/Anankke/SSPanel-Uim.git .
RUN wget https://getcomposer.org/installer -O composer.phar && php composer.phar && php composer.phar install --no-dev
RUN chmod 755 -R *
#RUN chown nginx:nginx -R *
RUN chown www-data:www-data -R *
RUN cp /appprofile.example.php config/appprofile.php

CMD ["/start.sh"]
