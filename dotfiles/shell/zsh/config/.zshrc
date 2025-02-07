# Set debug mode if KEMA_ZSH_DEBUG_STARTUP is set
if [[ -n "${KEMA_ZSH_DEBUG_STARTUP}" ]]; then
	zmodload zsh/datetime
	setopt PROMPT_SUBST
	PS4='+$EPOCHREALTIME %N:%i ### command = '
	LOGFILE="$(mktemp /tmp/zsh_profile.XXXXXXXX)"
	exec 3>&2 2>${LOGFILE}
	setopt XTRACE
	zmodload zsh/zprof
fi

plugins=(
	# fzf-tab needs to be first
	fzf-tab

	extract
	git
	forgit
	alias-tips
	zsh-autosuggestions
	fast-syntax-highlighting

	# kema needs to be last (override)
	kema
)

# Basic settings for oh-my-zsh
zstyle ':omz:update' mode disabled
export ZSH="${HOME}/.oh-my-zsh"
export ZSH_THEME=""
export DISABLE_AUTO_TITLE=true
export DISABLE_LS_COLORS=true
export DISABLE_UNTRACKED_FILES_DIRTY="true"
export ZSH_CACHE_DIR="${ZSH}/cache"

export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
# https://github.com/Homebrew/brew completions
if [[ ! ":${FPATH}:" == *":${HOMEBREW_PREFIX}/share/zsh/site-functions:"* ]]; then
	export FPATH="${HOMEBREW_PREFIX}/share/zsh/site-functions:${FPATH}"
fi

export ZSH_COMPDUMP="${ZSH_CACHE_DIR}/.zcompdump"

source "${ZSH}/oh-my-zsh.sh"

# https://github.com/jandedobbeleer/oh-my-posh
eval "$(${HOMEBREW_PREFIX}/bin/oh-my-posh init zsh --config ${KEMA_DOTFILES_DIR_PUBLIC}/dotfiles/shell/prompt/kema_theme.omp.yaml)"

# Print debug info if KEMA_ZSH_DEBUG_STARTUP is set
if [[ -n "${KEMA_ZSH_DEBUG_STARTUP}" ]]; then
	unsetopt XTRACE
	exec 2>&3 3>&-
	echo -e "${COLOR_BOLD_YELLOW}Longest calls:${COLOR_RESET}"
	"${KEMA_SCRIPTS_DIR_PUBLIC}/zsh_profile_parse.sh" "${LOGFILE}" | head -n 30
	echo -e "${COLOR_BOLD_YELLOW}Profile:${COLOR_RESET}"
	zprof
	exit
fi
