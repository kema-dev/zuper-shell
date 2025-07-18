# Completions
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# enable grouping
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:messages' format '[%d]'
zstyle ':completion:*:warnings' format '[%d]'
# enable dot files and dirs
setopt globdots
# disable ./ and ../ completion
zstyle ':completion:*' special-dirs false
# enable correction
zstyle ':completion:*' completer _complete _match _extensions _approximate
# set acceptable error count for approximate completion
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'
# enable caching
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "${ZSH_CACHE_DIR}/.zcompcache"
# enable menu selection (useful when fzf-tab is not used)
zstyle ':completion:*' menu select
# enable grouping (useful when fzf-tab is not used)
zstyle ':completion:*' group-name ''
# disable long list (ls -l style)
zstyle ':completion:*' file-list false
# set // as /*/
zstyle ':completion:*' squeeze-slashes false
# disable - as an option prefix for cd
zstyle ':completion:*' complete-options false
# enable file sorting by name
zstyle ':completion:*' file-sort name
# enable partial completion
# 'm:{a-zA-Z}={A-Za-z} is messy with fzf-tab, when getting 2 matches with same prefix but different cases, fzf-tab will not show the lower case one
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# disable completion for some commands
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
# disable automatic completion commands updating
zstyle ':completion:*' rehash false
# enable verbose completion
zstyle ':completion:*' verbose true
# add the original command to the list of completions
zstyle ':completion:*:match:*' original true
# preview processes
zstyle ':completion:*:*:*:*:processes' command 'command ps -u ${USER} -o pid,user,comm -w -w'

# custom fzf flags for fzf-tab (from ${FZF_COLOR_OPTS})
zstyle ':fzf-tab:*' fzf-flags --color=fg:#4d4d4c,bg:#eff1f5,hl:#d7005f --color=fg+:#4d4d4c,bg+:#e8e8e8,hl+:#d7005f --color=info:#4271ae,prompt:#8959a8,pointer:#d7005f --color=marker:#4271ae,spinner:#4271ae,header:#4271ae

# switch group using `[` and `]`
zstyle ':fzf-tab:*' switch-group '[' ']'
# disable preview for command options
zstyle ':fzf-tab:complete:*:options' fzf-preview
# disable preview for subcommands
zstyle ':fzf-tab:complete:*:argument-*' fzf-preview
# preview expansions
zstyle ':fzf-tab:complete:((-parameter-|unset):|(export|typeset|declare|local):argument-rest)' fzf-preview 'echo ${(P)word}'
# kill: preview job
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w'
# systemctl: preview service status
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

complete -o nospace -C terraform terraform
complete -o nospace -C aws_completer aws

# https://gist.github.com/magicdude4eva/2d4748f8ef3e6bf7b1591964c201c1ab
# Fix slow pasting while using fast-syntax-highlighting
pasteinit() {
	OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
	zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
	zle -N self-insert "${OLD_SELF_INSERT}"
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish
