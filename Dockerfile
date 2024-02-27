FROM ubuntu:24.04


# Add Scripts
ADD scripts/start.sh /start.sh
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
