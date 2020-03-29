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
mkdir -p {data/guacamole,data/keycloak,init,openid} 

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
#   docker run --rm \
#     docker.io/guacamole/guacamole:1.1.0 \
#     cat /usr/local/tomcat/conf/server.xml > config/keycloak/server.xml.orig

# make a copy to patch
cp config/keycloak/server.xml.orig init/server.xml

# enable ssl, and such
patch init/server.xml < config/guacamole/0.enable-tomcat-ssl.patch

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

# values pulled from server.xml within the image, and errors from the docker log
keytool -genkey \
  -alias server \
  -keyalg RSA \
  -keystore init/application.keystore \
  -keysize 2048 \
  -storepass password \
  -dname "cn=keycloak.rfa.net, ou=AED Instructors, o=Ridgecrest, c=US" \
  -keypass password \
  -trustcacerts \
  -validity 365

# make the certificate available to guacamole
keytool -exportcert \
  -keystore init/application.keystore \
  -alias server \
  -file init/keycloak.crt \
  -storepass password \
  -keypass password | \
  openssl x509 -inform der -text > init/keycloak.crt

# docker cp guacamole-compose_guacamole_1:/etc/ssl/certs/java/cacerts init/cacerts

# keytool -importcert -alias keycloak -keystore init/cacerts -storepass changeit -file init/keycloak.crt -trustcacerts -noprompt 
# keytool -importcert -alias guacamole -keystore init/cacerts -storepass changeit -file init/guacamole.crt -trustcacerts -noprompt


# keytool -importcert -keystore /docker-java-home/jre/lib/security/cacerts -storepass changeit -file /keycloak.crt -trustcacerts -noprompt
# TODO: add the created keys in .gitignore
