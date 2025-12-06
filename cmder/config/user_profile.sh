# use this file to run your own startup commands for msys2 bash'

# To add a new vendor to the path, do something like:
# export PATH=${CMDER_ROOT}/vendor/whatever:${PATH}

# Uncomment this to have the ssh agent load with the first bash terminal
# . "${CMDER_ROOT}/vendor/lib/start-ssh-agent.sh"export MSYS=winsymlinks:nativestict

export PATH=$GIT_INSTALL_ROOT/usr/bin:$GIT_INSTALL_ROOT/mingw64/bin:$PATH

. $CMDER_ROOT/config/user_aliases.sh

export BAT_CONFIG_PATH=$HOME/.config/bat/config
