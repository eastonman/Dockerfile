FROM python:3.7-alpine

RUN apk add yarn \
        mariadb-connector-c-dev 
RUN git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git /app/
WORKDIR /app
RUN virtualenv -p python3 flask
RUN . ./flask/bin/activate
RUN pip install python-dotenv && pip install -r requirements.txt
ENV FLASK_APP=app/__init__.py
RUN yarn install --pure-lockfile
RUN flask assets build

ENTRYPOINT ['/app/run.py']
