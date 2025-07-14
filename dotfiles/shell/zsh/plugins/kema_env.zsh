# https://github.com/junegunn/fzf
export FZF_DEFAULT_OPTS="
--exit-0
--extended
--tiebreak=begin,length
--ansi
--layout=reverse
--cycle
--multi
--walker=file,dir,follow,hidden
-i
--info=inline-right
--header-first
--no-scrollbar
--height=100%
--preview-window=':default:wrap:right:60%'
--bind 'ctrl-r:toggle-sort'
--bind 'change:top'
--bind 'ctrl-\:toggle-preview'
--bind 'alt-\:toggle-preview-wrap'
--bind 'alt-enter:transform:echo print-query'
--bind 'ctrl-space:toggle'
--header 'ctrl-r : toggle sort | ctrl-\ : toggle preview | alt-\ toggle wrap | alt-enter : print query | ctrl-space : select'
--color=border:#808080,spinner:#E6DB74,hl:#F7EF54,fg:#F8F8F2,header:#b7815d,info:#A6E22E,pointer:#A6E22E,marker:#F92672,fg+:#F8F8F2,prompt:#F92672,hl+:#F92672
"

# https://github.com/Aloxaf/fzf-tab
# NOTE height is overridden in fzf-tab, needs to be set as FZF_TMUX_HEIGHT before sourcing fzf-tab plugin
export FZF_TMUX_HEIGHT="100%"

# https://github.com/wfxr/forgit
# NOTE height is overridden in forgit, needs to be set as FORGIT_FZF_DEFAULT_OPTS before sourcing forgit plugin
export FORGIT_FZF_DEFAULT_OPTS="--height=100%"

# brew
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
# NOTE brew shellenv is slow, performance / portability tradeoff in favor of performance here by exporting variables
export HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar"
export HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
if [[ ":${PATH}:" == *":${HOMEBREW_PREFIX}/bin:"* ]]; then
	export PATH="${HOMEBREW_PREFIX}/bin:${PATH}"
fi
if [[ ! ":${PATH}:" == *":${HOMEBREW_PREFIX}/sbin:"* ]]; then
	export PATH="${HOMEBREW_PREFIX}/sbin:${PATH}"
fi
export MANPATH="${HOMEBREW_PREFIX}/share/man:${MANPATH+:$MANPATH}"
export INFOPATH="${HOMEBREW_PREFIX}/share/info:${INFOPATH:-}"

# ruby
export GEM_HOME="${HOME}/gems"

# go
export GOPATH="${HOME}/go"
export GOROOT="${HOMEBREW_PREFIX}/opt/go/libexec"

# node
export NVM_DIR="${HOME}/.nvm"
export NPM_CONFIG_PREFIX="${HOME}/.npm-global"
if [[ ! -d "${NPM_CONFIG_PREFIX}" ]]; then
	mkdir -p "${NPM_CONFIG_PREFIX}" >/dev/null 2>&1
fi

# https://github.com/dagger/dagger
export DAGGER_NO_NAG=1

# https://github.com/docker/cli
export COMPOSE_BAKE="true"

# https://github.com/wofr06/lesspipe
export LESSQUIET=1

# editor
export VISUAL="code"
export EDITOR="nvim"

# k8s
export KUBE_EDITOR="${EDITOR}"

# 1.  ${HOMEBREW_PREFIX}/bin
# 2.  ${HOMEBREW_PREFIX}/sbin
# 3.  ${HOMEBREW_PREFIX}/opt/go/libexec/bin
# 4.  ${HOME}/.local/bin
# 5.  /usr/local/bin
# 6.  /usr/local/sbin
# 7.  /usr/bin
# 8.  /bin
# 9.  /usr/sbin
# 10. /sbin
# 11. ${GOPATH}/bin
# 12. ${HOME}/.cargo/bin
# 13. ${HOME}/.npm-global/bin
# 14. ${HOME}/.pub-cache/bin
# 15. ${NVM_DIR}/bin
# 16. ${GEM_HOME}/bin
# 17. ${HOME}/.krew/bin
# 18. /var/lib/snapd/snap/bin
export PATH="${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:${HOMEBREW_PREFIX}/opt/go/libexec/bin:${HOME}/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:${GOPATH}/bin:${HOME}/.cargo/bin:${HOME}/.npm-global/bin:${HOME}/.pub-cache/bin:${NVM_DIR}/bin:${GEM_HOME}/bin:${HOME}/.krew/bin:/var/lib/snapd/snap/bin"
