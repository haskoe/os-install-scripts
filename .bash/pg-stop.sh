#!/bin/bash -e

[[ "$#" -ne 1 ]] && echo please specify database name && exit 1
PGDATABASE=$1

[[ $(docker ps --format '{{.Names}}' --filter status=running --filter name=pg${PGDATABASE}) ]] && docker stop pg${PGDATABASE}
[[ $(docker ps --format '{{.Names}}' --filter status=exited --filter name=pg${PGDATABASE}) ]] && docker rm pg${PGDATABASE}
