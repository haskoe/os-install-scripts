# github and azure using local gnupg password store
GH_USER=heas
GH_EMAIL=henrik@haskoe.dk
tee ~/.gitconfig <<-EOF
[user]
	name = ${GH_USER}
	email = ${GH_EMAIL}
[pull]
	rebase = false
[credential]
	credentialStore = gpg
	helper = /usr/bin/git-credential-manager

[credential "https://dev.azure.com"]
	useHttpPath = true
EOF
