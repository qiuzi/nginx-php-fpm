#! /bin/bash -eu

  echo "[INFO] Config Panel from CONFIG_BASE64 env"
  cat /etc/secrets/config.txt > config/.config.php
  echo "[INFO] Config Panel from CONFIG_BASE64 completed"

if [ "$DATABASE" = "yes" ]; then
 php xcat Migration new && \
 php xcat Tool importAllSettings && \
 php xcat Tool createAdmin <<EOF
 $ADMINEMAIL
 $ADMINPASSWD
 Y
EOF
fi
#lastlinephpconf="$(grep "." /usr/local/etc/php-fpm.conf | tail -1)"
#if [[ $lastlinephpconf == *"php_flag[display_errors]"* ]]; then
# sed -i '$ d' /usr/local/etc/php-fpm.conf
#fi

# Display PHP error's or not
#if [[ "$ERRORS" != "1" ]] ; then
# echo php_flag[display_errors] = off >> /usr/local/etc/php-fpm.d/www.conf
#else
#fi

exec /usr/bin/supervisord -n -c /etc/supervisord.conf
