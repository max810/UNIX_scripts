#!/bin/bash

is_ukr() {
    [ $LANG == 'uk_UA.UTF-8' ]
}

print_i18n() {
    if is_ukr; then
        echo -e "$2"
    else
        echo -e "$1"
    fi
}

warn_i18n() {
    if is_ukr; then
        >&2 echo -e "$2"
    else
        >&2 echo -e "$1"
    fi
}

die_i18n() {
    warn_i18n "$1" "$2"
    exit 1
}


ensure_directory_exists() {
    dir_path=$1
    if [ ! -d "$dir_path" ]; then
        mkdir -p "$dir_path"
    fi

    if [ $? -ne 0 ]; then
        die_i18n "Failed creating directory $dir_path" "Не вдалося створити директорію $dir_path"
    fi
}


main() {
    ensure_directory_exists "$HOME/bin"
    cp pzpi-16-2-bekuzarov-maksym-lab5.out "$HOME/bin"

    echo "export PATH="\$HOME/bin:\$PATH"" >> $HOME/.bash_profile
    chmod 755 "$HOME/bin/pzpi-16-2-bekuzarov-maksym-lab5.out"
}

main