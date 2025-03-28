#!/bin/bash -e

[[ "$#" -ne 1 ]] && echo please specify database name && exit 1
PGDATABASE=$1

. _common.sh ${BASH_SOURCE[0]}

echo $SCRIPT_DIR

ENV_FILE=$SCRIPT_DIR/../conf/${PGDATABASE}.conf
DBURI=postgres://${PGDATABASE}_user:${PGDATABASE}_user@0.0.0.0/${PGDATABASE}
DBANON=${PGDATABASE}_user
echo PGRST_DB_URI=${DBURI}>${ENV_FILE}
echo PGRST_DB_SCHEMA=pub>>${ENV_FILE}
echo PGRST_DB_ANON_ROLE=${DBANON}>>${ENV_FILE}

#pg-stop.sh ${PGDATABASE}

set +e
[[ $(docker ps --format '{{.Names}}' -f status=running -f name=postgrest | grep -w postgrest) ]] && echo stop && docker stop postgrest
read -t 0.01 >/dev/null
[[ $(docker ps --format '{{.Names}}' -f status=exited -f name=postgrest | grep -w postgrest) ]] && echo rm && docker rm postgrest
read -t 0.01 >/dev/null
docker run --rm -d --net=host --name postgrest --env-file ${ENV_FILE} postgrest/postgrest
