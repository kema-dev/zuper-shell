# `ctrl+backspace` kill backward word sequence
bindkey '^W' vi-backward-kill-word
# `ctrl+left` jump to previous beggining of word sequence
bindkey '^[[1;5D' vi-backward-word
# `ctrl+right` jump to next end of word sequence
bindkey '^[[1;5C' emacs-forward-word
# `shift+left` jump to previous space
bindkey '^[[1;2D' vi-backward-blank-word
# `shift+right` jumpto next space
bindkey '^[[1;2C' vi-forward-blank-word
# `shift+up` jump to beginning-of-line
bindkey '^[[1;2A' beginning-of-line
# `shift+down` jump to end-of-line
bindkey '^[[1;2B' end-of-line
# `ctrl+o` copy terminal buffer to clipboard and clear buffer
zle -N cutbuffer
bindkey '^O' cutbuffer
# `alt+backspace` kill a (space-)word sequence backward
zle -N backward-kill-blank-word
bindkey '^[^?' backward-kill-blank-word
# `alt+delete` kill (space-)word sequence
zle -N forward-kill-blank-word
bindkey '^[[3;3~' forward-kill-blank-word
# `ctrl+r` to search in history
zle -N history_search_widget
bindkey '^r' history_search_widget
# `ctrl+g` to search in dirstack using
zle -N dirstack_search_widget
bindkey '^g' dirstack_search_widget
# `ctrl+t` to insert file path relative to current directory
zle -N insert-file-relpath
bindkey '^t' insert-file-relpath
zle -N full_clear_screen
bindkey '^l' full_clear_screen
