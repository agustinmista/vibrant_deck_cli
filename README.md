# vibrant_deck_cli

A simple command line utility to tweak the screen saturation of the Steam Deck, along with a service to automatically enable it at startup.

Based on [vibrantDeck](https://github.com/libvibrant/vibrantDeck).

## Installation

### TL;DR

In desktop mode, paste the following into the terminal:

```bash
curl -sL https://github.com/agustinmista/vibrant_deck_cli/raw/main/install.sh | sh
```

Which should produce the following output:

```
Looking up the files we need to download ...
Downloading https://raw.githubusercontent.com/agustinmista/vibrant_deck_cli/main/vibrant_deck_cli into /home/deck/.local/bin/vibrant_deck_cli ...
Creating config file at /home/deck/.config/vibrant_deck_cli/config ...
Downloading https://raw.githubusercontent.com/agustinmista/vibrant_deck_cli/main/vibrant_deck_cli.service into /home/deck/.config/systemd/user ...
Enabling vibrant_deck_cli.service on systemd ...
Created symlink /home/deck/.config/systemd/user/default.target.wants/vibrant_deck_cli.service → /home/deck/.config/systemd/user/vibrant_deck_cli.service.
Starting vibrant_deck_cli.service ...
Checking if everything worked ...
Done! The screen saturation is now set to 1.500000 :D
The default saturation value can be changed in /home/deck/.config/vibrant_deck_cli/config
```

### Sligtly longer TL;DR

The installer will download two files into your Steam Deck

* `/home/deck/.local/bin/vibrant_deck_cli`: the tool itself
* `/home/deck/.config/systemd/user/vibrant_deck_cli.service`: the service that runs the tool at startup

Additionally, it will create the file:

* `/home/deck/.config/vibrant_deck_cli/config`

The only tunable parameter is the saturation value that the tool sets at startup, which the installer sets to 1.5 by default. You can change it by editing the file above:

```
SATURATION=1.25
```

If you're not sure which value to pick, you can manually run `vibrant_deck_cli` passing an input value between 0.0 and 4.0 and see the change in real time without having to reboot every time:

```
$ ~/.local/bin/vibrant_deck_cli 1.25
Setting screen saturation to 1.250000
Screen saturation set to 1.250000
```

Note that `vibrant_deck_cli` is not in your $PATH by default, so you need to run it from its installed location at `~/.local/bin`. Also note that this tool only affects the saturation while in game mode. The easiest way to the changes in real-time is to run `vibrant_deck_cli` from an SSH session while in game mode.

## Uninstallation

Simply run:

```bash
curl -sL https://github.com/agustinmista/vibrant_deck_cli/raw/main/uninstall.sh | sh
```

Which will stop the startup service and remove all the relevant files:

```
Stopping vibrant_deck_cli.service ...
Disabling vibrant_deck_cli.service ...
Removed /home/deck/.config/systemd/user/default.target.wants/vibrant_deck_cli.service.
Removing /home/deck/.config/systemd/user/vibrant_deck_cli.service ...
Removing /home/deck/.local/bin/vibrant_deck_cli ...
Removing /home/deck/.config/vibrant_deck_cli ...
```
