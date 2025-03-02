#!/bin/bash -e

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

BASH_ALIASES=$SCRIPTPATH/.bash_aliases
[[ ! -f $BASH_ALIASES ]] && echo "cant get path to parent dir - exiting!!" && return 1

. $BASH_ALIASES

eval `keychain --eval --agents ssh id_ed25519`

# . "/home/heas/.asdf/asdf.sh"
# . "/home/heas/.asdf/completions/asdf.bash"

# bun                                                                                                                                                        
# export BUN_INSTALL="$HOME/.bun"

#echo $PATH
export PATH=$PATH:$SCRIPTPATH:$HOME/proj/heas0404/cs/repos/tools/db/unix
# export PATH=$BUN_INSTALL/bin:$HOME/.asdf/shims:$HOME/.local/bin:$SCRIPTPATH:$HOME/proj/heas0404/cs/repos/tools/db/unix:$PATH
#export PYTHONPATH=$HOME/dev/haskoe/organize:$HOME/proj/heas0404/misc/repos/MISC/python

#[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
#[ -f /usr/share/bash-completion/completions/fzf ] && source /usr/share/bash-completion/completions/fzf
