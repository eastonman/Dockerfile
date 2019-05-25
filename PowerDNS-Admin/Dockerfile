FROM python:3.7-alpine

RUN apk add --no-cache --virtual .build-deps \
        git \
        build-base \
        libxslt-dev \
        libffi-dev \
        libxml2-dev \
        xmlsec-dev \
        openldap-dev \
        libldap \ 
    && apk add --no-cache \
        mariadb-connector-c-dev \
        yarn \
        supervisor \
    && git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git /app \
    && cd /app \
    && pip install -r requirements.txt \
    && apk del --purge .build-deps
WORKDIR /app
RUN cp ./supervisord.conf /etc/supervisord.conf && cp ./config_template.py /app/config.py
ADD ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
