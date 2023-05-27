FROM nginx

COPY ./default.conf /etc/nginx/conf.d/

RUN set -x \
&&  mkdir -p /etc/nginx/letsencrypt \
&&  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "/etc/nginx/letsencrypt/options-ssl-nginx.conf" \
&&  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "/etc/nginx/letsencrypt/ssl-dhparams.pem" \
&&  chown -R root /etc/nginx/letsencrypt \
&&  rm -rf /var/cache/apk/* \
           /tmp/* \
           /var/tmp/*

CMD ["nginx", "-g", "daemon off;"]