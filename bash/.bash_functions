dotfiles() {
    cd ~/.dotfiles || return
    tree-a
    gf
    gs
}

# Git
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
PS1="\[\033[01;32m\]\w \[\033[01;34m\]\$(parse_git_branch)\[\033[00m\]\$ "

git_init() {
    if [ -z "$1" ]; then
        printf "%s\n" "Please provide a directory name.";
    else
        mkdir "$1";
        builtin cd "$1" || return
        pwd;
        git init;
        touch readme.md .gitignore LICENSE;
        echo "# $(basename "$PWD")" >> readme.md
    fi
}

# Stow
run_stow() {
    echo "Running stow..."
    cd ~/.dotfiles || return
    for d in $(ls -d */ | cut -f1 -d '/');
    do
        ( stow "$d" )
    done
    echo "Done."
}

# Hugo
selector() {
    select name in "./" *; do
        if [ "$name" = "./" ]; then
            break
        elif [ -d "$name" ]; then
            cd "$name" || return
            selector
        elif [ -f "$name" ]; then
            export name="$name" && break
        fi
        break
    done
}

create_file() {
    read -rp "Enter filename: " filename
    read -rp "Create '$dir/$filename?' Yes(y) / No(n) / Go back(b) / Exit(e):- " choice
    case $choice in
        [yY]* ) hugo new "$dir/$filename" && vim "$dir/$filename" && cd "$path" || return ;;
        [nN]* ) create_file ;;
        [bB]* ) new_note ;;
        [eE]* ) return ;;
        * ) echo "Error, not an option" ;;
    esac
}

new_note() {
    path=~/notes

    cd "$path/content" || return
    selector
    dir=$(pwd | cut -d/ -f 5-)
    echo "$dir"
    cd "$path" || return
    create_file
}

open_note() {
    path=~/notes

    cd $path/content || return
    selector
    vim "$name"
    cd "$path" || return
}
