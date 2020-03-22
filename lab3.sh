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

print_help() {
    if is_ukr; then
        str="Розроблено Бекузаровим Максимом 2020-03-22.\n"
        str="${str}Цей скрипт встановлює програму для збору та збереження у вказаному файлі інформації про систему.\n"
    else
        str="Developed by Maksym Bekuzarov on 2020-03-01.\n"
        str="${str}This script installls the tool to gather and store information about the system in the given file.\n"
    fi
    
    echo -e "$str"
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

backup() {
    file_path=$1
    file_name=$(basename "$file_path")
    file_dir=$(dirname "$file_path")

    cur_d=$(date "+%Y%m%d")
    all_files_created_before=($(ls -1v "$file_dir" | grep -E "$file_name"))
    num_found=${#all_files_created_before[@]}
    new_num=$(expr "$num_found" + 1)
    new_num_fmt="$(printf "%04d" $new_num)"

    new_file_name="$file_name-$cur_d-$new_num_fmt"
    new_file_path="$file_dir/$new_file_name"

    cp "$file_path" "$new_file_path"
}

case $1 in
    '-h' | '--help') print_help && exit 0;;
esac

main() {
    tool_file_path=$1
    tool_file_name=$(basename "$tool_file_path")
    target_dir="$HOME/bin"
    ensure_directory_exists "$target_dir"
    cp "$tool_file_path" "$target_dir"

    backup "$HOME/.bash_profile"
    backup "$HOME/.bashrc"

    echo "export PATH="\$HOME/bin:\$PATH"" >> $HOME/.bash_profile
    chmod 755 "$HOME/bin/$tool_file_name"
}

main $(realpath "$1")