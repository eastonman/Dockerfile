#!/bin/ash

set -o errexit
set -o pipefail


# == Vars
#
DB_MIGRATION_DIR='/app/migrations'
WORK_DIR='/app'
if [[ -z ${PDNS_PROTO} ]];
 then PDNS_PROTO="http"
fi

if [[ -z ${PDNS_PORT} ]];
 then PDNS_PORT=8081
fi

#Retrieve DB host from environment variable
if [[ -z ${PDA_DB_HOST} ]];
  then PDA_DB_HOST=pdadbhost
fi
sed -i "s/pdadbhost/${PDA_DB_HOST}/g" ${WORK_DIR}/config.py

#Retrieve DB port from environment variable
if [[ -z ${PDA_DB_PORT} ]];
  then PDA_DB_PORT=3306
fi
sed -i "s/3306/${PDA_DB_PORT}/g" ${WORK_DIR}/config.py

#Retrieve DB user from environment variable
if [[ -z ${PDA_DB_USER} ]];
  then PDA_DB_USER=pdauser
fi
sed -i "s/pdauser/${PDA_DB_USER}/g" ${WORK_DIR}/config.py

#Retrieve DB password from environment variable
if [[ -z ${PDA_DB_PASSWORD} ]];
  then PDA_DB_PASSWORD=pdapassword
fi
sed -i "s/pdapassword/${PDA_DB_PASSWORD}/g" ${WORK_DIR}/config.py

#Retrieve DB database name from environment variable
if [[ -z ${PDA_DB_NAME} ]];
  then PDA_DB_NAME=pdadbname
fi
sed -i "s/pdadbname/${PDA_DB_NAME}/g" ${WORK_DIR}/config.py

#Retrieve Gunicorn listening port from environment variable
if [[ -z ${PDA_PORT} ]];
  then PDA_PORT=8080
fi
sed -i "s/8080/${PDA_PORT}/g" /etc/supervisord.conf


# Wait for us to be able to connect to MySQL before proceeding
echo "===> Waiting for $PDA_DB_HOST MySQL service"
until nc -zv \
  $PDA_DB_HOST \
  $PDA_DB_PORT;
do
  echo "MySQL ($PDA_DB_HOST) is unavailable - sleeping"
  sleep 1
done


echo "===> DB management"
# Go in Workdir
cd /app

if [ ! -d "${DB_MIGRATION_DIR}" ]; then
  echo "---> Running DB Init"
  flask db init --directory ${DB_MIGRATION_DIR}
  flask db migrate -m "Init DB" --directory ${DB_MIGRATION_DIR}
  flask db upgrade --directory ${DB_MIGRATION_DIR}
  ./init_data.py

else
  echo "---> Running DB Migration"
  set +e
  flask db migrate -m "Upgrade DB Schema" --directory ${DB_MIGRATION_DIR}
  flask db upgrade --directory ${DB_MIGRATION_DIR}
  set -e
fi

echo "===> Update PDNS API connection info"
# initial setting if not available in the DB
mysql -h${PDA_DB_HOST} -u${PDA_DB_USER} -p${PDA_DB_PASSWORD} -P${PDA_DB_PORT} ${PDA_DB_NAME} -e "INSERT INTO setting (name, value) SELECT * FROM (SELECT 'pdns_api_url', '${PDNS_PROTO}://${PDNS_HOST}:${PDNS_PORT}') AS tmp WHERE NOT EXISTS (SELECT name FROM setting WHERE name = 'pdns_api_url') LIMIT 1;"
mysql -h${PDA_DB_HOST} -u${PDA_DB_USER} -p${PDA_DB_PASSWORD} -P${PDA_DB_PORT} ${PDA_DB_NAME} -e "INSERT INTO setting (name, value) SELECT * FROM (SELECT 'pdns_api_key', '${PDNS_API_KEY}') AS tmp WHERE NOT EXISTS (SELECT name FROM setting WHERE name = 'pdns_api_key') LIMIT 1;"

# update pdns api setting if .env is changed.
mysql -h${PDA_DB_HOST} -u${PDA_DB_USER} -p${PDA_DB_PASSWORD} -P${PDA_DB_PORT} ${PDA_DB_NAME} -e "UPDATE setting SET value='${PDNS_PROTO}://${PDNS_HOST}:${PDNS_PORT}' WHERE name='pdns_api_url';"
mysql -h${PDA_DB_HOST} -u${PDA_DB_USER} -p${PDA_DB_PASSWORD} -P${PDA_DB_PORT} ${PDA_DB_NAME} -e "UPDATE setting SET value='${PDNS_API_KEY}' WHERE name='pdns_api_key';"

echo "===> Assets management"
[ -d /app ] && chown -fhR www-data:www-data /app
echo "---> Running Yarn"
[ -d /app/app/static ] && chown -fhR www-data:www-data /app/app/static
[ -d /app/node_modules ] && chown -fhR www-data:www-data /app/node_modules
su -s /bin/bash -c 'yarn install --pure-lockfile' www-data

echo "---> Running Flask assets"
[ -d /app/logs ] && chown -fhR www-data:www-data /app/logs
su -s /bin/bash -c 'flask assets build' www-data


echo "===> Start supervisor"
/usr/bin/supervisord -c /etc/supervisord.conf
