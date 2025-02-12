# Clipboard manager

## Purpose

- Fuzzy search clipboard history

## Usage (a bit messy but convenient)

- Build the clipnotify binary by running `task build` in the [backend](./backend) directory. If you do not have [task](https://github.com/go-task/task) installed, you can just take a look at the [taskfile.yml](./backend/Taskfile.yaml) and run the commands manually.
- Set `KEMA_SCRIPTS_DIR_PUBLIC` to the path of this repository in your shell and `KEMA_CLIPBOARD_MANAGER_DIR` to the parent directory of the clipboard history files, as those are used in the backend script that itself uses tmux, thus your shell environment.
- Running [the daemon](./backend/run_daemon.sh) will start monitoring the clipboard, creating files in `KEMA_CLIPBOARD_MANAGER_DIR` to keep track of the clipboard history. [tmux](https://github.com/tmux/tmux) has been chosen as it is convenient for user-session related tasks, such as clipboard management. Running the daemon on machine startup is recommended.
- Create a wrapper script for the client script that sets these variables and runs the client script
  - `COLOR_REGULAR_BLACK` to `\033[0;30m`
  - `COLOR_REGULAR_GREEN` to `\033[0;32m`
  - `PATH` to include the binaries of fzf and other tools used in the client script
  - `FZF_DEFAULT_OPTS` to the value defined in [kema_env.zsh](/dotfiles/shell/zsh/plugins/kema_env.zsh)
  - `KEMA_CLIPBOARD_MANAGER_DIR` same as in the backend script
  - `KEMA_SCRIPTS_DIR_PUBLIC` same as in the backend script
- Run your wrapper script to search the clipboard history
