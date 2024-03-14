#!/bin/bash

echo $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

POSTGREST_PORT=3019
PGDATABASE=adrdb
