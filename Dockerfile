FROM debian:jessie
MAINTAINER Nick Marus <nmarus@gmail.com>

EXPOSE 80 5232
VOLUME ["/etc/radicale/collections"]

#setup apt
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

#install packages
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
    apt-get install -y curl ed bsdtar nginx apache2-utils python3.4 python-pip && \
    apt-get clean

#configure nginx
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /var/www/html && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

#install/setup caldavzap
RUN curl -Ls https://www.inf-it.com/CalDavZAP_0.13.1.zip | bsdtar -xf- --strip 1 -C /var/www/html
COPY config.js /var/www/html/config.js
RUN chown -R www-data:www-data /var/www/html && \
    chmod +x /var/www/html/cache_update.sh

#install radicale
RUN pip install passlib
RUN pip install python-pam
RUN pip install radicale
RUN ln -sf /dev/stdout /var/log/radicale

#setup radicale
RUN mkdir -p /etc/radicale
COPY config /etc/radicale/config
COPY rights /etc/radicale/rights
COPY logging /etc/radicale/logging
COPY rad-admin.sh /usr/local/bin/rad-admin
RUN chmod +x /usr/local/bin/rad-admin

#copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

#start Radicale
CMD ["/start.sh"]
