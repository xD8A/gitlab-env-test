#!/bin/sh

sed -iE "s/gitlab.example.com/$GITLAB_HOST/g" /etc/nginx/conf.d/gitlab.conf
sed -iE "s/keycloak.example.com/$KEYCLOAK_HOST/g" /etc/nginx/conf.d/keycloak.conf

mkdir -p /etc/nginx/ssl
export IP1=$(hostname -I)
echo "IP Address: $IP1"
cat << EOF > /etc/nginx/ssl/nginx.cnf
[req]
default_bits  = 2048
distinguished_name = req_distinguished_name
req_extensions = req_ext
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
countryName = XX
stateOrProvinceName = N/A
localityName = N/A
organizationName = N/A
commonName = *.${DOMAIN}
[req_ext]
subjectAltName = @alt_names
[v3_req]
subjectAltName = @alt_names
[alt_names]
IP.1 = $IP1
EOF
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
	-config /etc/nginx/ssl/nginx.cnf \
	-keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt

$exec "$@"
