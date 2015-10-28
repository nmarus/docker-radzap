#!/bin/bash
#nmarus@gmail.com

set -e

QUIET=false
#SFLOG="/start.log"

#print timestamp
timestamp() {
    date +"%Y-%m-%d %T"
}

#screen/file logger
sflog() {
    #if $1 is not null
    if [ ! -z ${1+x} ]; then
        message=$1
    else
        #exit function
        return 1;
    fi
    #if $QUIET is not true
    if ! $($QUIET); then
        echo "${message}"
    fi
    #if $SFLOG is not null
    if [ ! -z ${SFLOG+x} ]; then
        #if $2 is regular file or does not exist
        if [ -f ${SFLOG} ] || [ ! -e ${SFLOG} ]; then
            echo "$(timestamp) ${message}" >> ${SFLOG}
        fi
    fi
}

#start services function
startc() {
    sflog "Services are being started..."
    /etc/init.d/nginx start > /dev/null
    radicale > /dev/null
    sflog "All services have started..."
}

#stop services function
stopc() {
    sflog "Services are being stopped..."
    /etc/init.d/nginx stop > /dev/null
    kill $(cat /etc/radicale/pid) > /dev/null
    rm -f /etc/radicale/pid > /dev/null
    sflog "Services have successfully stopped. Exiting."
}

#trap "docker stop <container>" and shuts services down cleanly
trap "(stopc)" TERM

#startup
sflog  "Container is starting..."

#test for ENV varibale $FQDN
if [ ! -z ${FQDN+x} ]; then
    sflog "FQDN is set to ${FQDN}"
else
    export FQDN="$(hostname)"
    sflog "FQDN is set to $(hostname)"
fi

#modify config files with fqdn
sed -i "s,MYSERVER,${FQDN},g" /etc/nginx/nginx.conf &> /dev/null
sed -i "s,MYSERVER,${FQDN},g" /var/www/html/config.js &> /dev/null

#start init.d services
startc

#setup permissions
chown -R root:root /etc/radicale/collections

#init calendars
sflog "Initializing RadZap..."
source /etc/radicale/calendars

#pause script to keep container running...
sflog "Services for container successfully started."
stop="no"
while [ "$stop" == "no" ]
do
sflog "Type [stop] or run 'docker stop <container_name>' from host."
read input
if [ "$input" == "stop" ]; then stop="yes"; fi
done

#stop init.d services
stopc
