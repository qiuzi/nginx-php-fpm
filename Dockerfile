FROM ubuntu:24.04

ENV TZ=Asia/Shanghai
RUN apt update \
    && apt install -y wget git nginx supervisor \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && apt install -y php8.3-{bcmath,bz2,cli,common,curl,fpm,gd,igbinary,mbstring,mysql,opcache,readline,redis,xml,yaml,zip} \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/www/html
RUN sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' /etc/php/8.3/fpm/php.ini
RUN sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' /etc/php/8.3/cli/php.ini


# Add Scripts
ADD scripts/start.sh /start.sh
ADD scripts/nginx-site.conf /etc/nginx/sites-available/default
ADD scripts/nginx.conf /etc/nginx/nginx.conf
ADD scripts/supervisord.conf /etc/supervisord.conf
ADD conf/appprofile.example.php /appprofile.example.php
RUN chmod 755 /start.sh
EXPOSE 80/tcp
# copy in code

#USER root
WORKDIR "/var/www/html"
RUN git clone -b 2023.7 https://github.com/Anankke/SSPanel-Uim.git .
RUN wget https://getcomposer.org/installer -O composer.phar && php composer.phar && php composer.phar install --no-dev
RUN chmod 755 -R *
RUN chown www-data:www-data -R *
RUN cp /appprofile.example.php config/appprofile.php

CMD ["/start.sh"]
