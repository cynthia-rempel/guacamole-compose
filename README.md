# guacamole-compose
Docker compose project with keycloak and guacamole

To get started, run 

```
./setup.sh

docker-compose up
```

To uninstall

```
docker-compose down
./teardown.sh
```

To make a new 0.enable-tomcat-ssl.patch

diff -Naur init/server.xml.orig init/server.xml > config/guacamole/0.enable-tomcat-ssl.patch

# Reference:
https://github.com/airaketa/guacamole-docker-compose/tree/5aac1dccbd7b89b54330155270a4684829de1442
