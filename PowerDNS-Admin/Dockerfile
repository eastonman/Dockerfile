FROM python:3.7-alpine

RUN apk add --no-cache --virtual .build-deps \
        git \
        build-base \
        libxslt-dev \
        libffi-dev \
        libxml2-dev \
        xmlsec-dev \
        libldap \ 
        mariadb-connector-c-dev \
    && apk add --no-cache \
        mariadb-client \
        mariadb-dev \
        openldap-dev \
        yarn \
        supervisor \
        bash \
    && git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git /app \
    && cd /app \
    && pip install -U python-dotenv && pip install -r requirements.txt \
    && apk del --purge .build-deps
RUN addgroup www-data \
    && adduser \
        --disabled-password \
        --gecos "" \
        --ingroup www-data \
        --no-create-home \
        www-data
RUN ls
WORKDIR /app
VOLUME /app/app/static
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./config.py /app/config.py
ADD ./entrypoint.sh /entrypoint.sh
RUN ["chmod","+x","/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]
