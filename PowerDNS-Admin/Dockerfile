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
        supervisor
RUN git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git /app
WORKDIR /app
RUN pip install -r requirements.txt
RUN apk del --purge .build-deps
RUN cp ./supervisord.conf /etc/supervisord.conf && cp ./config_template.py /app/config.py && cp ./docker/PowerDNS-Admin/entrypoint.sh /entrypoint.sh

ENTRYPOINT ['/entrypoint.sh']
