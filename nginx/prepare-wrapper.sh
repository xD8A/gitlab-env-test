#!/bin/sh

# CA
sed -iE "s/(server_name\s+).*;/\1${CA_HOST:-ca.example.com};/g" /etc/nginx/conf.d/ca.conf
sed -iE "s|(ssl_certificate\s+/etc/nginx/certs/).*|\1${CA_HOST:-ca.example.com}.crt|g" /etc/nginx/conf.d/ca.conf
sed -iE "s|(ssl_certificate_key\s+/etc/nginx/secrets/).*|\1${CA_HOST:-ca.example.com}.key|g" /etc/nginx/conf.d/ca.conf
# Keycloak
sed -iE "s/(server_name\s+).*;/\1${KEYCLOAK_HOST:-keycloak.example.com};/g" /etc/nginx/conf.d/keycloak.conf
sed -iE "s|(ssl_certificate\s+/etc/nginx/certs/).*|\1${KEYCLOAK_HOST:-keycloak.example.com}.crt|g" /etc/nginx/conf.d/keycloak.conf
sed -iE "s|(ssl_certificate_key\s+/etc/nginx/secrets/).*|\1${KEYCLOAK_HOST:-keycloak.example.com}.key|g" /etc/nginx/conf.d/keycloak.conf
# Gitlab
sed -iE "s/(server_name\s+).*;/\1${GITLAB_HOST:-gitlab.example.com};/g" /etc/nginx/conf.d/gitlab.conf
sed -iE "s|(ssl_certificate\s+/etc/nginx/certs/).*|\1${GITLAB_HOST:-gitlab.example.com}.crt|g" /etc/nginx/conf.d/gitlab.conf
sed -iE "s|(ssl_certificate_key\s+/etc/nginx/secrets/).*|\1${GITLAB_HOST:-gitlab.example.com}.key|g" /etc/nginx/conf.d/gitlab.conf


$exec "$@"
