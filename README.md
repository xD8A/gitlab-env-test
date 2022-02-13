# Setup

Add records to hosts (in case there are no records in DNS):
```bash
source .env
export DOCK0_IP=$(ip -4 addr show docker0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
echo "DOCK0_IP=${DOCK0_IP}" >> .env
cat << EOF | sudo tee -a /etc/hosts
${DOCK0_IP} ${CA_HOST}
${DOCK0_IP} ${KEYCLOAK_HOST}
${DOCK0_IP} ${GITLAB_HOST}
EOF
```

Create volumes:
```bash
mkdir -v ./postgres/data
#chown -Rv 999:999 ./postgres
sudo chown -Rv 1000:1000 ./keycloak
#chown -Rv 101:101 ./nginx
mkdir -v ./ca/{db,certs,config,secrets}
sudo chown -Rv 1000:1000 ./ca
sudo chmod -v +x */*.sh
```

Start containers:
```bash
docker-compose up -d
```

## Setup step-ca

Increase cert durations (./ca/config/ca.json):
```json
  	// ...
	"authority": {
		"claims": {
	      	"minTLSCertDuration": "5m",
	      	"maxTLSCertDuration": "10000h",
	      	"defaultTLSCertDuration": "720h",
	      	"disableRenewal": false,
	      	"minHostSSHCertDuration": "5m",
	      	"maxHostSSHCertDuration": "10000h",
	      	"defaultHostSSHCertDuration": "720h",
	      	"minUserSSHCertDuration": "5m",
	      	"maxUserSSHCertDuration": "24h",
	      	"defaultUserSSHCertDuration": "16h"
	    },
    	// ...
  	}
  	// ...
```


Reload config:
```bash
docker-compose exec ca kill -HUP 1
```

[Optional] Install intermediate CA certificate to host system (Manjaro):
```bash
sudo cp -v ./ca/certs/*.crt /etc/ca-certificates/trust-source/anchors/
ls -la /etc/ssl/certs/ | wc -l
sudo update-ca-trust
ls -la /etc/ssl/certs/ | wc -l
```

Generate certificates:
```bash
source .env
docker-compose exec ca step ca certificate ${CA_HOST} certs/${CA_HOST}.crt secrets/${CA_HOST}.key --provisioner-password-file secrets/password
docker-compose exec ca step certificate inspect certs/${CA_HOST}.crt
docker-compose exec ca step ca certificate ${KEYCLOAK_HOST} certs/${KEYCLOAK_HOST}.crt secrets/${KEYCLOAK_HOST}.key --provisioner-password-file secrets/password
docker-compose exec ca step certificate inspect certs/${KEYCLOAK_HOST}.crt
docker-compose exec ca step ca certificate ${GITLAB_HOST} certs/${GITLAB_HOST}.crt secrets/${GITLAB_HOST}.key --provisioner-password-file secrets/password
docker-compose exec ca step certificate inspect certs/${GITLAB_HOST}.crt
```

Copy certs and keys to nginx:
```bash
source .env
mkdir -v ./nginx/{certs,secrets}
sudo cp -v ./ca/certs/*.crt ./nginx/certs/
sudo cp -v ./ca/secrets/{${CA_HOST},${KEYCLOAK_HOST},${GITLAB_HOST}}.key ./nginx/secrets/
#sudo chown -v 101:101 ./nginx/{certs,secrets}/*
docker-compose exec nginx nginx -s reload
```

Copy certs to gitlab:
```bash
sudo cp -v ./ca/certs/*.crt ./gitlab/config/trusted-certs/
```

## Setup keycloak

Following [this](https://www.keycloak.org/getting-started/getting-started-docker) instruction:
* Create realm (svc);
* Create user and set the password (user);
* Test user account ([svc](https://keycloak.example.com/auth/realms/svc/account));
* Add openid-connect client (gitlab);
* Change settings (gitlab):
    * Access Type: confidential
    * Root URL: https://gitlab.example.com
    * Valid Redirect URIs: https://gitlab.example.com/users/auth/openid_connect/callback
    * Admin URL: https://gitlab.example.com
    * Web Origins: https://gitlab.example.com
* Save secret.

## Setup gitlab

Following [this](https://docs.gitlab.com/ee/administration/auth/oidc.html) instruction:
* Setup ./gitlab/config/gitlab.rb:
```ruby
# ...
gitlab_rails['omniauth_enabled'] = true
gitlab_rails['omniauth_allow_single_sign_on'] = ['openid_connect']
gitlab_rails['omniauth_sync_email_from_provider'] = 'openid_connect'
gitlab_rails['omniauth_sync_profile_from_provider'] = ['openid_connect']
gitlab_rails['omniauth_sync_profile_attributes'] = ['name', 'email']
gitlab_rails['omniauth_auto_sign_in_with_provider'] = 'openid_connect'
gitlab_rails['omniauth_block_auto_created_users'] = false
gitlab_rails['omniauth_auto_link_ldap_user'] = true
gitlab_rails['omniauth_auto_link_saml_user'] = false
gitlab_rails['omniauth_providers'] = [
  {
    name: "openid_connect",
    # label: "Provider name", # optional label for login button, defaults to "Openid Connect"
    # icon: "<custom_provider_icon>",
    args: {
      name: "openid_connect",
      scope: ["openid","profile","email"],
      response_type: "code",
      issuer: "https://keycloak.example.com/auth/realms/svc", 
      discovery: true,
      client_auth_method: "query",
      uid_field: "preferred_username",
      send_scope_to_token_endpoint: "false",
      client_options: {
        identifier: "gitlab",
        secret: "TODO: secret",
        redirect_uri: "https://gitlab.example.com/users/auth/openid_connect/callback"
      }
    }
  }
]
# ...
```
Reconfigure gitlab:
```bash
docker-compose exec gitlab gitlab-ctl reconfigure 
```

# Cleanup

```bash
docker-compose down
sudo rm -rfv ./ca/{db,certs,config,secrets}
sudo rm -rfv ./gitlab/{config,data,logs}
sudo rm -rfv ./postgres/data
sudo rm -rfv ./nginx/{certs,secrets}
```
