#!/bin/bash -e

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

BASH_ALIASES=$SCRIPTPATH/.bash_aliases
[[ ! -f $BASH_ALIASES ]] && echo "cant get path to parent dir - exiting!!" && return 1

. $BASH_ALIASES

eval `keychain --eval --agents ssh id_ed25519`

export PATH=$PATH:$HOME/.local/bin:$HOME/.local/bin:$SCRIPTPATH:/home/${USER}/proj/heas0404/cs/repos/tools/db/unix

[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
[ -f /usr/share/bash-completion/completions/fzf ] && source /usr/share/bash-completion/completions/fzf
