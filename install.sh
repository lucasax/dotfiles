#!/bin/bash

DIR=$(pwd)

# make a symlink to home directory for given dotfile
function dotlink(){
    local FROM=$HOME/.$1
    local TO=$DIR/$1

    if [ -d "$FROM" ]; 
    then
    echo "Directory $FROM exists, deleting..."
    rm -r $FROM
    fi

    if [ -f "$FROM" ]; 
    then
    echo "File $FROM exists, deleting..."
    rm $FROM
    fi

    echo "Simlink from $FROM to $TO created!"
    ln -sfn $TO $FROM
}

# Parse input arguments
getopt --test > /dev/null
if [[ $? -ne 4 ]]; then
    echo "I’m sorry, `getopt --test` failed in this environment."
    exit 1
fi

SHORT=abcC
LONG=all,brew,colors,clean

# -temporarily store output to be able to check for errors
# -activate advanced mode getopt quoting e.g. via “--options”
# -pass arguments only via   -- "$@"   to separate them correctly
PARSED=$(getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    # e.g. $? == 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# use eval with "$PARSED" to properly handle the quoting
eval set -- "$PARSED"

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -a|--all)
            brew=1
            colors=1
            shift
            ;;
        -b|--brew)
            brew=1
            shift
            ;;
        -c|--colors)
            colors=1
            shift
            ;;
        -C|--clean)
            clean=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

if [[ $clean -eq 1 ]]; then
    echo 'Cleaning install path...'
    rm -rf $HOME/.linuxbrew
    rm -rf $HOME/.base16-shell
    exit
fi

dotlink profile
dotlink bashrc
dotlink zshrc
dotlink tmux.conf
dotlink dircolors

if [[ $brew -eq 1 ]]; then
    git clone https://github.com/Linuxbrew/brew.git $HOME/.linuxbrew
fi

if [[ $colors -eq 1 ]]; then
    git clone https://github.com/chriskempson/base16-shell.git $HOME/.base16-shell
fi
