#!/bin/bash
#nmarus@gmail.com

set -e

#start services function
startc() {
    /etc/init.d/nginx start > /dev/null
    radicale > /dev/null
}

#stop services function
stopc() {
    /etc/init.d/nginx stop > /dev/null
    kill $(cat /etc/radicale/pid) > /dev/null
    rm -f /etc/radicale/pid > /dev/null
}

#trap "docker stop <container>" and shuts services down cleanly
trap "(stopc)" TERM

#test for ENV varibale $FQDN
if [ ! -z ${FQDN+x} ]; then
    echo "FQDN is set to ${FQDN}"
else
    export FQDN="$(hostname)"
    echo "FQDN is set to $(hostname)"
fi

#modify config files with fqdn
sed -i "s,MYSERVER,${FQDN},g" /etc/nginx/nginx.conf &> /dev/null
sed -i "s,MYSERVER,${FQDN},g" /var/www/html/config.js &> /dev/null

#start init.d services
startc

#setup permissions
chown -R root:root /etc/radicale/collections

#pause script to keep container running...
echo "Services for container successfully started."
stop="no"
while [ "$stop" == "no" ]
do
echo "Type [stop] to shutdown container..."
read input
if [ "$input" == "stop" ]; then stop="yes"; fi
done

#stop init.d services
stopc
