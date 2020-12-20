FROM nginx:alpine

ARG FLAG

ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./cert.pem /etc/nginx/cert.pem
ADD ./privkey.pem /etc/nginx/privkey.pem

RUN mkdir -p /var/www/html \
 && echo "${FLAG}" > /var/www/html/flag.txt
