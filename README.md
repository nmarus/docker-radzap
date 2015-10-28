# docker-radzap
Docker container for Radicale and caldavZAP

###Usage:

1. Get Docker Image from Docker Hub...

        docker pull nmarus/docker-radzap

2. Run...

        docker run -d -it -p 80:80 -p 5232:5232 \
            -v /srv/radzap:/etc/radicale/collections \
            --name=radzap \
            --hostname=<fqdn> \
            nmarus/docker-radzap

3. Add users/passwords/calendars...

        docker exec radzap rad-admin test test calendar1.ics
        docker exec radzap rad-admin test test calendar2.ics
        docker exec radzap rad-admin test test calendar3.ics

4. Launch Browser to <fqdn> and login with one of the users created in step 3.
