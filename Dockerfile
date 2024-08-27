FROM ubuntu:22.04

ENV TZ=Asia/Shanghai
RUN apt update
RUN apt install -y wget nginx supervisor git
RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime
RUN echo ${TZ} > /etc/timezone
RUN apt install -y php8.2-bcmath php8.2-bz2 php8.2-cli php8.2-common php8.2-curl php8.2-fpm php8.2-gd php8.2-igbinary php8.2-mbstring php8.2-mysql php8.2-opcache php8.2-readline php8.2-redis php8.2-xml php8.2-yaml php8.2-zip
RUN rm -rf /var/lib/apt/lists/* /var/www/html/*
    
RUN sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' /etc/php/8.2/fpm/php.ini
RUN sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' /etc/php/8.2/cli/php.ini
RUN echo php_flag[display_errors] = on >> /etc/php/8.3/fpm/php-fpm.conf

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
