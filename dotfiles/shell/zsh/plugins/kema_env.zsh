# https://github-wiki-see.page/m/junegunn/fzf/wiki/Color-schemes Paper Color
export FZF_COLOR_OPTS="--color=fg:#4d4d4c,bg:#eff1f5,hl:#d7005f --color=fg+:#4d4d4c,bg+:#e8e8e8,hl+:#d7005f --color=info:#4271ae,prompt:#8959a8,pointer:#d7005f --color=marker:#4271ae,spinner:#4271ae,header:#4271ae"

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
${FZF_COLOR_OPTS}
"

# https://github.com/Aloxaf/fzf-tab
# NOTE height is overridden in fzf-tab, needs to be set as FZF_TMUX_HEIGHT before sourcing fzf-tab plugin
export FZF_TMUX_HEIGHT="100%"

# https://github.com/wfxr/forgit
# NOTE height is overridden in forgit, needs to be set as FORGIT_FZF_DEFAULT_OPTS before sourcing forgit plugin
export FORGIT_FZF_DEFAULT_OPTS="--height=100%"

# go
export GOPATH="${HOME}/go"

# node
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
export LESSOPEN="| ${KEMA_SCRIPTS_DIR_PUBLIC}/lesspipe_improved.sh %s"

# editor
export VISUAL="codium"
export EDITOR="nvim"

# k8s
export KUBE_EDITOR="${EDITOR}"

export PATH="${HOME}/dev/tool/bin:${HOME}/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:${GOPATH}/bin:${HOME}/.cargo/bin:${HOME}/.npm-global/bin"
