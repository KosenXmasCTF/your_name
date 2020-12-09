FROM nginx:alpine

ARG FLAG

COPY ./nginx.conf /etc/nginx/nginx.conf

RUN apk --no-cache add openssl

RUN mkdir -p /etc/certs/noname.xm4s.net \
 && mkdir -p /etc/certs/noname.xm4s.net.local \
 && mkdir -p /var/www/noname.xm4s.net \
 && mkdir -p /var/www/noname.xm4s.net.local \
 && openssl genrsa 4096 > /etc/certs/noname.xm4s.net/privkey.pem \
 && openssl genrsa 4096 > /etc/certs/noname.xm4s.net.local/privkey.pem \
 && openssl req -new -x509 -days 365 -key /etc/certs/noname.xm4s.net/privkey.pem -out /etc/certs/noname.xm4s.net/cert.pem -subj "/CN=noname.xm4s.net/" \
 && openssl req -new -x509 -days 365 -key /etc/certs/noname.xm4s.net.local/privkey.pem -out /etc/certs/noname.xm4s.net.local/cert.pem -subj "/CN=noname.xm4s.net.local/" \
 && echo "${FLAG}" > /var/www/noname.xm4s.net.local/flag.txt
