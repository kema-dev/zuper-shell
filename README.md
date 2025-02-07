# :zap: zuper-shell - ZSH on steroids! (and some other stuff)

A collection of scripts, configurations, and dotfiles to enhance your shell experience. The configuration is opinionated and is tailored to my needs, you may use it as a reference or as a starting point for your own configuration. Feel free to contribute or suggest improvements!

## Features

- [Dotfiles](./dotfiles/) - Configuration files for various tools
- [Shell](./dotfiles/shell/) - ZSH configuration with prompt, aliases, functions, completions, and more
- [Scripts](./dotfiles/scripts/) - Useful scripts for everyday tasks
- [Clipboard](./dotfiles/scripts/clipboard/) - Dumb TUI clipboard manager

> [!NOTE]
> Each directory contains a README with more information!

## Recommended tools

### Shell

#### Core

- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) - ZSH framework & plugins manager
- [Oh My Posh](https://github.com/jandedobbeleer/oh-my-posh) - Prompt theme engine
- [fzf](https://github.com/junegunn/fzf) - Command-line fuzzy finder, backend for many tools
- [fzf-tab](https://github.com/Aloxaf/fzf-tab) - Delightful tab completion using fzf
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - Fish-like autosuggestions for ZSH
- [Fast Syntax Highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) - Syntax highlighting for ZSH, with performance in mind
- [alias-tips](https://github.com/djui/alias-tips) - Remind you of aliases when you enter a command that could be an alias
- [forgit](https://github.com/wfxr/forgit) - Utility tool powered by fzf for using git interactively
- [Neovim](https://github.com/neovim/neovim) - Vim-fork focused on extensibility and usability
- [NvChad](https://github.com/NvChad/NvChad) - Full-featured Neovim setup with Lua scripting, LSP, and more
- [GitHub CLI](https://github.com/cli/cli) - GitHub's official CLI tool, with support for issues, PRs, and more

#### Useful

- [fd](https://github.com/sharkdp/fd) - Modern replacement for `find`
- [Choose](https://github.com/theryangeary/choose) - Modern replacement for `cut` and (sometimes) `awk`
- [Dust](https://github.com/bootandy/dust) - Modern replacement for `du`
- [bottom](https://github.com/ClementTsang/bottom) - Modern replacement for `top`
- [eva](https://github.com/oppiliappan/eva) - Modern replacement for `bc`
- [bat](https://github.com/sharkdp/bat) - Modern replacement for `cat`
- [eza](https://github.com/eza-community/eza) - Modern replacement for `ls`
- [sd](https://github.com/chmln/sd) - Modern replacement for `sed`
- [procs](https://github.com/dalance/procs) - Modern replacement for `ps`
- [duf](https://github.com/muesli/duf) - Modern replacement for `df`
- [tealdeer](https://github.com/tealdeer-rs/tealdeer) - (kind-of) Modern replacement for `man`
- [trashcli](https://github.com/andreafrancia/trash-cli) - (kind-of) Modern replacement for `rm`, using freedesktop's trash
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Line-oriented search tool that recursively searches for a regex pattern
- [delta](https://github.com/dandavison/delta) - Viewer for git and diff output
- [Glances](https://github.com/nicolargo/glances) - TUI for monitoring system resources
- [Catimg](https://github.com/posva/catimg) - Terminal image viewer
- [Chafa](https://github.com/hpjansson/chafa) - Terminal image viewer
- [Magika](https://github.com/google/magika) - Mime type detection through deep learning
- [lesspipe](https://github.com/wofr06/lesspipe) - Preprocessor for less, enhancing its capabilities
- [asciicinema](https://github.com/asciinema/asciinema) - Record and share your terminal sessions
- [fselect](https://github.com/jhspetersson/fselect) - Find files with SQL-like queries
- [Step CLI](https://github.com/smallstep/cli) - Zero trust swiss army knife
- [zsh-bench](https://github.com/romkatv/zsh-bench) - Benchmark ZSH startup time
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch) - System information tool
- [hyperfine](https://github.com/sharkdp/hyperfine) - Command-line benchmarking tool
- [rivalcfg](https://github.com/flozz/rivalcfg) - Configuration tool for SteelSeries gaming mice
- [gh-clean-branches](https://github.com/davidraviv/gh-clean-branches) - Clean up merged branches in GitHub

### Development

#### Core

- [Visual Studio Code](https://github.com/microsoft/vscode) - Full-featured code editor, with great support for extensions, notably
  - Obviously extensions for the languages you're working with
  - [Monokai Night Theme](https://marketplace.visualstudio.com/items?itemName=fabiospampinato.vscode-monokai-night) - Editor theme
  - [Material Icon Theme](https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme) - File icon theme
  - [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one) - Markdown support
  - [GitHub Markdown Preview](https://marketplace.visualstudio.com/items?itemName=bierner.github-markdown-preview) - GitHub-flavored markdown preview
  - [Markdown Checkboxes](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-checkbox) - Markdown checkboxes
  - [Markdown Emoji](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-emoji) - Markdown emoji
  - [Markdown Extended](https://marketplace.visualstudio.com/items?itemName=jebbs.markdown-extended) - Markdown extended support
  - [Markdown Footnotes](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-footnotes) - Markdown footnotes
  - [Markdown Preview Enhanced](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced) - Markdown preview enhanced
  - [Markdown Preview GitHub Styling](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-preview-github-styles) - GitHub markdown styling
  - [Markdown Preview Mermaid Support](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid) - Markdown mermaid support
  - [Markdown yaml Preamble](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-yaml-preamble) - Markdown YAML preamble
  - [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint) - Markdown linter
  - [:emojisense:](https://marketplace.visualstudio.com/items?itemName=bierner.emojisense) - Emoji autocomplete
  - [vscode-pdf](https://marketplace.visualstudio.com/items?itemName=tomoki1207.pdf) - PDF viewer
  - [Svg Preview](https://marketplace.visualstudio.com/items?itemName=SimonSiefke.svg-preview) - SVG preview
  - [Draw.io Integration](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio) - Draw.io integration
  - [Todo Tree](https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree) - Notes and todos from comments
  - [GitHub Pull Requests](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-pull-request-github) - GitHub pull requests integration
  - [GitHub Actions](https://marketplace.visualstudio.com/items?itemName=github.vscode-github-actions) - GitHub Actions integration
  - [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) - AI-powered code completion
  - [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) - AI-powered chat assistant
  - [Git Graph](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph) - Git graph viewer
  - [Git History](https://marketplace.visualstudio.com/items?itemName=donjayamanne.githistory) - Git history viewer
  - [git-commit-plugin](https://marketplace.visualstudio.com/items?itemName=redjue.git-commit-plugin) - Commit message helper
  - [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) - Git supercharged
  - [Live Share](https://marketplace.visualstudio.com/items?itemName=ms-vsliveshare.vsliveshare) - Real-time collaborative development
  - [IntelliCode](https://marketplace.visualstudio.com/items?itemName=VisualStudioExptTeam.vscodeintellicode) - AI-assisted suggestions
  - [Path Intellisense](https://marketplace.visualstudio.com/items?itemName=christian-kohler.path-intellisense) - Path autocompletion
  - [Batch Rename](https://marketplace.visualstudio.com/items?itemName=JannisX11.batch-rename-extension) - Batch rename files
  - [Bracket Select](https://marketplace.visualstudio.com/items?itemName=chunsen.bracket-select) - Select text between brackets
  - [expand-region](https://marketplace.visualstudio.com/items?itemName=letrieu.expand-region) - Expand selection to the next logical element
  - [Sort lines](https://marketplace.visualstudio.com/items?itemName=Tyriar.sort-lines) - Sort lines
  - [String Manipulation](https://marketplace.visualstudio.com/items?itemName=marclipovsky.string-manipulation) - String manipulation utilities
  - [Multiple cursor case preserve](https://marketplace.visualstudio.com/items?itemName=Cardinal90.multi-cursor-case-preserve) - Preserve case when using multiple cursors
  - [indent-rainbow](https://marketplace.visualstudio.com/items?itemName=oderwat.indent-rainbow) - Colorize indentation
  - [EditorConfig for VS Code](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig) - EditorConfig support
  - [Task](https://marketplace.visualstudio.com/items?itemName=task.vscode-task) - Task runner
  - [Project Manager](https://marketplace.visualstudio.com/items?itemName=alefragnani.project-manager) - Easily switch between projects
  - [Output Colorizer](https://marketplace.visualstudio.com/items?itemName=IBM.output-colorizer) - Colorize output
  - [JSON Crack](https://marketplace.visualstudio.com/items?itemName=AykutSarac.jsoncrack-vscode) - JSON viewer
- [Firefox Developer Edition](https://www.mozilla.org/en-US/firefox/developer/) - Developer-friendly browser
- [Homebrew](https://github.com/Homebrew/brew) - Package manager, works great on Linux too!
- [Alacritty](https://github.com/alacritty/alacritty) - GPU-accelerated terminal emulator
- [Pulumi](https://github.com/pulumi/pulumi) - Infrastructure as code tool using a real programming language
- [Task](https://github.com/go-task/task) - Modern replacement for `make`

#### Containers

- [Kubernetes](https://github.com/kubernetes/kubernetes) - World's most popular container orchestration system
- [kind](https://github.com/kubernetes-sigs/kind/) - Kubernetes in Docker for local development
- [K9s](https://github.com/derailed/k9s) - TUI for Kubernetes
- [cilium](https://github.com/cilium/cilium) - Networking, security, and observability for Kubernetes
- [Docker](https://github.com/docker/cli) - World's most popular container runtime
- [crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane) - Container image manipulation tool
- [kubectx](https://github.com/ahmetb/kubectx) - Kubernetes contexts and namespaces switcher

#### Useful

- [Ansible](https://github.com/ansible/ansible) - Automation tool for IT tasks
- [Ventoy](https://github.com/ventoy/Ventoy) - Multi-boot USB drive creator
- [Wireshark](https://www.wireshark.org/) - Network protocol analyzer
- [VLC](https://github.com/videolan/vlc) - Media player
- [DBeaver](https://github.com/dbeaver/dbeaver) - Universal database tool
- [kopia](https://github.com/kopia/kopia) - Fast and secure backup tool
- [gnome-magic-window](https://github.com/adrienverge/gnome-magic-window) - GNOME extension for window management
- [gnome-shell-system-monitor-applet](https://github.com/mgalgs/gnome-shell-system-monitor-applet) - GNOME extension for system monitoring
- [date-menu-formatter](https://github.com/marcinjakubowski/date-menu-formatter) - GNOME extension for date formatting in the top bar

### Collaboration

- [Signal](https://github.com/signalapp) - Secure messaging app, trusted by millions
- [LibreOffice](https://github.com/LibreOffice/core) - Free and open-source office suite
- [Draw io](https://github.com/jgraph/drawio-desktop) - Diagramming software
- [RustDesk](https://github.com/rustdesk/rustdesk) - Remote desktop software
- [LocalSend](https://github.com/localsend/localsend) - File sharing through the local network
