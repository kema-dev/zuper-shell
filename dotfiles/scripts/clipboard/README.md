# Clipboard manager

## Purpose

- Fuzzy search clipboard history

## Usage

- Build the clipnotify binary by running `task build` in the [backend](./backend) directory. If you do not have [task](https://github.com/go-task/task) installed, you can just take a look at the [taskfile.yml](./backend/Taskfile.yaml) and run the commands manually.
- Running [the daemon](./backend/run_daemon.sh) will start monitoring the clipboard, creating files in `${KEMA_CLIPBOARD_MANAGER_DIR}` (set in [the client](scripts/clipboard/client/client.sh)) to keep track of the clipboard history. [tmux](https://github.com/tmux/tmux) has been chosen as it is convenient for user-session related tasks, such as clipboard management. Running the daemon on startup is recommended.
- Change `KEMA_SCRIPTS_DIR_PUBLIC` in [client.sh](client/client.sh) to `KEMA_SCRIPTS_DIR_PUBLIC="/path/to/this/repo/scripts/directory"`
- You can use this custom shortcut for [gnome-magic-window](https://github.com/adrienverge/gnome-magic-window), which opens an [alacritty](https://github.com/alacritty/alacritty) terminal in full screen mode, running the clipboard manager client script

  ```js
  const BINDINGS = [
    {
      shortcut: "<Primary><Alt>x",
      title: "Clipboard Manager",
      command:
        'alacritty --title="Clipboard Manager" --class="Clipboard Manager" --option window.startup_mode=\"Maximized\" --command /path/to/scripts/clipboard/client/client.sh',
    }
  ];
  ```
