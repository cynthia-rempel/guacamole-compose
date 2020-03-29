# guacamole-compose
Docker compose project with keycloak and guacamole

To get started, run 

```
./setup.sh

docker-compose up
```

Requires name resolution to work so I added the following entry to my /etc/hosts:

127.0.1.1 guacamole.rfa.net keycloak.rfa.net

Then browsed to:
https://guacamole.rfa.net:8443/guacamole
https://keycloak.rfa.net:8443

Please note:
haproxy sni requires uniq certs for each backend so you'll need separate certs
for guacamole and keycloak

In the client make:

Implicit Flow Enabled

Change the redirect URI to *
Advanced Properties
ID Token Signature Algorithm : RS512
Enable compatibility mode

To uninstall

```
docker-compose down
./teardown.sh
```

To make a new 0.enable-tomcat-ssl.patch

diff -Naur init/server.xml.orig init/server.xml > config/guacamole/0.enable-tomcat-ssl.patch

# Reference:
https://github.com/airaketa/guacamole-docker-compose/tree/5aac1dccbd7b89b54330155270a4684829de1442
https://lemonldap-ng.org/documentation/latest/applications/guacamole
