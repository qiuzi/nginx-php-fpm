#! /bin/bash -eu

if [ "$CONFIG_FILE" != "" ]; then
  echo "[INFO] Config Panel from CONFIG_BASE64 env"
  echo $CONFIG_FILE | base64 -d > config/.config.php
  echo "[INFO] Config Panel from CONFIG_BASE64 completed"
fi
php xcat Tool importAllSettings
if [ "$DATABASE" = "yes" ]; then
 php xcat Migration new && \
 php xcat Tool importAllSettings && \
 php xcat Tool createAdmin <<EOF
 $ADMINEMAIL
 $ADMINPASSWD
 Y
EOF
fi
# php xcat ClientDownload
# if [ "$PORT" = "" ]; then
#  PORT=80
# fi
# envsubst '$PORT' < /nginx.conf.template > /etc/nginx/nginx.conf

exec /usr/bin/supervisord -n -c /etc/supervisord.conf
