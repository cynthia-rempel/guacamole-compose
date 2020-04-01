#!/bin/bash

## Create the guacadmin user in keycloak

#### Add the guacadmin user to keycloak with an email
/opt/jboss/keycloak/bin/kcadm.sh \
  create users \
  -s username=guacadmin@guacadmin \
  -s enabled=true \
  -s email=guacadmin@guacadmin \
  -r master \
  --server https://keycloak.rfa.net:8443/auth \
  --realm master \
  --user admin \
  --password admin

# Set the password
/opt/jboss/keycloak/bin/kcadm.sh \
  set-password \
  --username guacadmin@guacadmin \
  --new-password guacadmin \
  -r master \
  --server https://keycloak.rfa.net:8443/auth \
  --realm master \
  --user admin \
  --password admin

# Make guacadmin an admin
/opt/jboss/keycloak/bin/kcadm.sh \
  add-roles \
  --uusername guacadmin@guacadmin \
  --rolename admin \
  -r master \
  --server https://keycloak.rfa.net:8443/auth \
  --realm master \
  --user admin \
  --password admin

### Add the guacamole-client
/opt/jboss/keycloak/bin/kcadm.sh \
  create clients \
  --file guacamole-client.json \
  -r master \
  --server https://keycloak.rfa.net:8443/auth \
  --realm master \
  --user admin \
  --password admin

