#!/bin/bash -x

echo "checking for patch"
patch -v
echo "checking for wget"
wget -v
echo "checking for docker-compose"
docker-compose -v
echo "checking for docker"
docker -v
echo "checking for keytool"
keytool -v

# create directories
mkdir -p {init,openid} 

cd openid

wget -nc https://mirrors.ocf.berkeley.edu/apache/guacamole/1.1.0/binary/guacamole-auth-openid-1.1.0.tar.gz
tar -xf guacamole-auth-openid-1.1.0.tar.gz
mv guacamole-auth-openid-1.1.0/* .
cd ..

# create the database initialization script for the guacamole database
docker run --rm \
  docker.io/guacamole/guacamole:1.1.0 \
    /opt/guacamole/bin/initdb.sh --postgres > init/initdb.sql

# get the original server.xml
docker run --rm \
  docker.io/guacamole/guacamole:1.1.0 \
    cat /usr/local/tomcat/conf/server.xml > init/server.xml.orig

sudo docker run --rm \
  -e KEYCLOAK_USER=admin \
  -e KEYCLOAK_PASSWORD=admin \
  --entrypoint="cat" \
  docker.io/jboss/keycloak:latest \
    /opt/jboss/keycloak/standalone/configuration/keycloak-add-user.json

# enable ssl, and such
patch init/server.xml.orig < config/guacamole/0.enable-tomcat-ssl.patch

cd init
wget -nc https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar
cd ..

# TODO: script creating keys

# Need self-signed cert for ca

# Create private keys for:
#   Guacamole
#   Keycloak

openssl req \
  -newkey rsa:2048 \
  -nodes \
  -keyout init/guacamole.key \
  -x509 \
  -days 365 \
  -out init/guacamole.crt \
  -subj "/C=US/ST=CA/L=Anytown/O=Ridgecrest First Aid/OU=AED Instructors/CN=guacamole.rfa.net"

keytool -genkey \
  -alias keycloak.rfa.net.key \
  -keyalg RSA \
  -keystore init/keycloak.jks \
  -keysize 2048 \
  -storepass somepass \
  -dname "cn=keycloak.rfa.net, ou=AED Instructors, o=Ridgecrest, c=US" \
  -keypass somepass \
  -trustcacerts \
  -validity 365

# TODO: add the created keys in .gitignore
