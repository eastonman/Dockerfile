FROM python:3.7-alpine as builder

WORKDIR /wheels
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
    && pip install -U pip \
    && pip wheel python-dotenv \
    && pip wheel -r /app/requirements.txt

FROM python:3.7-alpine
COPY --from=builder /app /app
COPY --from=builder /wheels /wheels
RUN apk add --no-cache \
        mariadb-dev \
        openldap-dev \
        mariadb-client \
        supervisor \
        yarn \
        bash \
    && pip install -U pip \
    && pip install -f /wheels python-dotenv \
    && pip install -r /app/requirements.txt -f /wheels \
    && rm -rf /wheels \
    && rm -rf ~/,cache/pip/*
RUN addgroup www-data \
    && adduser \
        --disabled-password \
        --gecos "" \
        --ingroup www-data \
        --no-create-home \
        www-data
WORKDIR /app
VOLUME /app/app/static
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./config.py /app/config.py
ADD ./entrypoint.sh /entrypoint.sh
RUN ["chmod","+x","/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]
