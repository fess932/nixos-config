if status is-interactive
    # Commands to run in interactive sessions can go here
end

pyenv init - | source
set -gx TELEPORT_PROXY tp.wb.ru:443

# Setting PATH for Python 3.12
# The original version is saved in /Users/fess932/.config/fish/config.fish.pysave
set -x PATH "/Library/Frameworks/Python.framework/Versions/3.12/bin" "$PATH"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

fish_add_path /Users/fess932/.spicetify

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
