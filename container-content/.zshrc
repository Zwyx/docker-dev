# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="robbyrussell"

# Remind to update Oh My Zsh
zstyle ':omz:update' mode reminder

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Automatically run `nvm use` if a directory contains a `.nvmrc` file
autoload -U add-zsh-hook
load-nvmrc() {
	local nvmrc_path
	nvmrc_path="$(nvm_find_nvmrc)"

	if [ -n "$nvmrc_path" ]; then
		local nvmrc_node_version
		nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

		if [ "$nvmrc_node_version" = "N/A" ]; then
			echo "\n\n"
			echo -n '\033[0;31m' && printf '─%.0s' {1..$(tput cols)} && echo '\033[0m'
			echo "  WARNING: Node version '$(cat "${nvmrc_path}")' is not installed, run 'nvm install' to install it."
			echo -n '\033[0;31m' && printf '─%.0s' {1..$(tput cols)} && echo '\033[0m'
			echo "\n\n"
		elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
			nvm use
		fi
	elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
		echo "Reverting to nvm default version"
		nvm use default
	fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

alias n='npm'
alias ni='npm i'
alias nid='npm i -D'
alias nig='npm i -g'
alias nci='npm ci'
alias nun='npm uninstall'
alias nug='npm uninstall -g'
alias ns='npm start'
alias nr='npm run'
# alias nrd='npm run dev'
alias nrd='nrdh' # We always need `--host` inside the container
alias nrdh='npm run dev -- --host 0.0.0.0'
alias nrt='npm run test'
alias nrl='npm run lint'
alias nrp='npm run prettier'
alias nrc='npm run clean'
alias nrb='npm run build'
alias nrdp='npm run deploy'
alias np='npm pack'
alias nv='npm version'
alias nvmj='npm version major'
alias nvmn='npm version minor'
alias nvp='npm version patch'
