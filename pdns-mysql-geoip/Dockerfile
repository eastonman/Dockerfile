FROM alpine:latest
MAINTAINER "PolyQY" <my@kucloud.win>

RUN apk add --no-cache \
    pdns \
    pdns-backend-mysql \
    pdns-backend-geoip \
    pdns-doc \
    python3 \
    mariadb-client

RUN pip3 install --no-cache-dir envtpl

ENV VERSION=4.1 \
  PDNS_guardian=yes \
  PDNS_setuid=pdns \
  PDNS_setgid=pdns \
  PDNS_launch=gmysql,geoip

EXPOSE 53 53/udp

COPY pdns.conf.tpl /
COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "/usr/sbin/pdns_server" ]
