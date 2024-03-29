alias q='docker run --rm --volume $(pwd):/data jdutant/quarto-latex'

# put this in ~/.bashrc
alias sshn='ssh -o PreferredAuthentications=keyboard-interactive,password -o PubkeyAuthentication=no'
#alias vs='. ~/dev/azure-repos/cs/tools/bat/start_vscode.sh'

alias cn='cargo new'
alias cnb='cargo new --bin'
alias cbl='cargo build'
alias ccl='cargo clean'
alias cli='cargo clippy'
alias cex='cargo expand'
alias cex='cargo expand'
alias cru='cargo run'
alias cre='cargo run --example'
alias rup='rustup update'
alias rds='rustup default stable'
alias rdb='rustup default beta'
alias rdn='rustup default nightly'

alias gpl='git pull'
alias gpu='git push'
alias gs='git status'
alias ga='gitk --all'
alias gb='git branch'
alias gr='git checkout --'
alias gco='git checkout'
alias gcl='git clone'
alias grh='git reset HEAD'

alias hgpl='hg pull'
alias hgpu='hg push'
alias hgco='hg checkout'
alias hgb='hg branch'
alias hgbs='hg branches'

alias agil='ag -i -l'
alias agl='ag -l'
alias agi='ag -i'

alias rgil='rg -ilH'
alias rgi='rg -iH'
alias rg='rg -H'

alias y='yarn'
alias yd='yarn dev'
alias yl='yarn link'
alias yu='yarn unlink'

alias ni='npm install'
alias nid='npm install --save-dev'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'

alias dnn='dotnet new'
alias dnb='dotnet build'
alias dnr='dotnew run'

alias tl='tmux list-session'
alias ta='tmux attach -t'
alias tk='tmux kill-session -t'

alias dsac='docker stop $(docker ps -aq)'
alias drmac='docker rm $(docker ps -aq)'
alias drmai='docker rmi $(docker images -a -q)'
alias dlsi='docker image ls'
alias dpsa='docker ps -a'
alias dsta='docker start'
alias dsto='docker stop'
alias dsta='docker container stop $(docker container ls -aq)'
alias dvolls='docker volume ls'
alias dspr='docker system prune'
alias dspra='docker system prune -a'
alias dcu='docker-compose up'
alias dca='docker-compose start'
alias dco='docker-compose stop'

alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'

alias fix-ssh-agent='eval $(gnome-keyring-daemon -r) && export SSH_AUTH_SOCK && export GNOME_KEYRING_CONTROL'
