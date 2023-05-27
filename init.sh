#!/bin/bash

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

domains=('dns.oz.digital')
rsa_key_size=4096
data_path="./certbot"
email="hello@oz.digital" # Adding a valid address is strongly recommended
staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

if [ -d "$data_path" ]; then
  read -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi


if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

cert_path="/etc/letsencrypt/live"

for domain in "${domains[@]}"
do
  echo "### Creating dummy certificate for $domain ..."

  # Create the necessary directories for the certificate
  mkdir -p "$cert_path/$domain"
  mkdir -p "$data_path/conf/live/$domain"

  # Generate the SSL certificate using OpenSSL
  docker-compose run --rm --entrypoint "\
    openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
      -keyout '$cert_path/$domain/privkey.pem' \
      -out '$cert_path/$domain/fullchain.pem' \
      -subj '/CN=$domain'" certbot <<< y

  echo
done

echo "### Starting nginx ..."
docker-compose up --force-recreate -d nginx
echo

for domain in "${domains[@]}"
do
  echo "### Deleting dummy certificate for $domain ..."

  # Delete the SSL certificate using OpenSSL
  docker-compose run --rm --entrypoint "\
    rm -Rf $cert_path/$domain && \
    rm -Rf $cert_path/$domain && \
    rm -Rf $cert_path/$domain.conf" certbot

  echo
done


echo "### Requesting Let's Encrypt certificate for $domains ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
    
echo

echo "### Reloading nginx ..."
docker-compose exec nginx -s reload