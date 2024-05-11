#!/bin/bash -e

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

BASH_ALIASES=$SCRIPTPATH/.bash_aliases
[[ ! -f $BASH_ALIASES ]] && echo "cant get path to parent dir - exiting!!" && return 1

. $BASH_ALIASES

eval `keychain --eval --agents ssh id_${HOSTNAME}`

PATH=$PATH:$SCRIPTPATH:/home/${USER}/proj/heas0404/cs/repos/tools/db/unix
