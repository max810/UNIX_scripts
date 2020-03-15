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

print_help() {
    if is_ukr; then
        str="Розроблено Бекузаровим Максимом 2020-03-01.\n"
        str="${str}Це програма для збору та збереження у вказаному файлі інформації про систему.\n"
        str="${str}Якщо файл існує, буде створено копію попереднього, а новий перезаписано.\n"
        str="${str}Використання:\n\t./task1.sh [-h|--help] [-n num] [file]\n"
        str="${str}Опції:\n"
        str="${str}\t-h|--help:\n"
        str="${str}\t\tНадрукувати цю справку і вийти\n\n"
        str="${str}\t-n \`num\`:int, >=1:\n"
        str="${str}\t\tВказати, яку кількість файлів з результатами залишити\n"
        str="${str}\t\tЯкщо не вказано=залишити всі\n\n"
        str="${str}\t\`file\`:\n"
        str="${str}\t\tВказати шлях до файлу, де буде збережено інформацію про систему\n"
        str="${str}\t\Якщо не вказано=~/bash/task1.out\n"
    else
        str="Developed by Maksym Bekuzarov on 2020-03-01.\n"
        str="${str}This is a tool to gather and store information about the system in the given file.\n"
        str="${str}If the file exists, a copy with a date and counter in its name will be created.\n"
        str="${str}Usage:\n\t./task1.sh [-h|--help] [-n num] [file]\n"
        str="${str}Options:\n"
        str="${str}\t-h|--help:\n"
        str="${str}\t\tPrint this help message and exit\n\n"
        str="${str}\t-n \`num\`:int, >=1:\n"
        str="${str}\t\tSpecify how many existing output files to leave, delete others (oldest first)\n"
        str="${str}\t\tDefault=keep all\n\n"
        str="${str}\t\`file\`:\n"
        str="${str}\t\tSpecify the file to store the output into\n"
        str="${str}\t\tDefault=~/bash/task1.out\n"
    fi
    
    echo -e "$str"
}

collect_info() {
    res_str="Date: $(date)\n"
    res_str="${res_str}----HARDWARE----\n"
    cpu_info=$(cat /proc/cpuinfo | grep -m 1 'model name')
    if [ $? -ne 0 ]; then
        warn_i18n "Failed to fetch CPU info, skipping..." "Не вдалося отримати інформацію про процесор, пропуск..."
        cpu_info="Unknown"
    else
        cpu_info=${cpu_info##*: }
    fi
    res_str="${res_str}CPU: \"${cpu_info}\"\n"

    mem_info=$(cat /proc/meminfo | grep -m 1 'MemTotal')
    if [ $? -ne 0 ]; then
        warn_i18n "Failed to fetch memory info, skipping..." "Не вдалося отримати інформацію про пам'ять, пропуск..."
        mem_info="Unknown"
    else
        mem_info=${mem_info##*: }
        mem_info=${mem_info%%kB}
        mem_info="$((mem_info / 1024)) Mi"
    fi
    res_str="${res_str}Memory: ${mem_info}B\n"

    mb_info_raw_str=$(dmidecode --type baseboard)
    if [ $? -ne 0 ]; then
        warn_i18n "Failed to fetch motherboard info, skipping..." "Не вдалося отримати інформацію про мат. плату, пропуск..."
        mb_info="Unknown"
    else
        mb_manufacturer=$(echo "$mb_info_raw_str" | grep Manufacturer)
        mb_manufacturer=${mb_manufacturer##*: }
        mb_product_name=$(echo "$mb_info_raw_str" | grep 'Product Name')
        mb_product_name=${mb_product_name##*: }
        mb_info="\"${mb_manufacturer}\", \"${mb_product_name}\""
    fi
    res_str="${res_str}Motherboard: ${mb_info}\n"

    serial_info=$(dmidecode --type system | grep 'Serial Number')
    if [ $? -ne 0 ]; then
        warn_i18n "Failed to fetch serial number info, skipping..." "Не вдалося отримати інформацію про серійний номер, пропуск..."
        serial_info="Unknown"
    else
        serial_info=${serial_info##*: }
    fi
    res_str="${res_str}System Serial Number: ${serial_info}\n"

    res_str="${res_str}----SYSTEM----\n"

    os_release=$(lsb_release -a | grep "Description")
    if [ $? -ne 0 ]; then
        warn_i18n "Failed to fetch os release info, skipping..." "Не вдалося отримати інформацію про білд ОС, пропуск..."
        os_release="Unknown"
    else
        os_release=${os_release##*:}
        os_release=$(echo "$os_release" | awk '$1=$1')
    fi
    res_str="${res_str}OS Distribution: ${os_release}\n"

    kernel_info=$(uname -v)
    if [ $? -ne 0 ]; then
        warn_i18n "Failed to fetch os kernel info, skipping..." "Не вдалося отримати інформацію про версію ядра ОС, пропуск..."
        kernel_info="Unknown"
    fi
    res_str="${res_str}Kernel version: ${kernel_info}\n"

    created_info=$(dumpe2fs $(mount | grep 'on / ' | awk '{print $1}') | grep 'Filesystem created: ')
    if [ $? -ne 0 ]; then
        warn_i18n "Failed to fetch installation date info, skipping..." "Не вдалося отримати інформацію дату інсталяції, пропуск..."
        created_info="Unknown"
    else
        created_info=${created_info#*:}
        # awk will autoremove all leading/trailing whitespaces if any column is accessed 
        # so we just don't do anything with the column -> and awk will remove whitespaces
        created_info=$(echo "$created_info" | awk '$1=$1')  
    fi
    res_str="${res_str}Installation date: ${created_info}\n"

    hostname=$(hostname)
    if [ $? -ne 0 ]; then
        warn_i18n "Failed to fetch hostname info, skipping..." "Не вдалося отримати інформацію про ім'я хосту, пропуск..."
        hostname="Unknown"
    fi
    res_str="${res_str}Hostname: ${hostname}\n"

    # parsing the columns between the first (cur. time) and the unknown (users online) column
    uptime=$(uptime | sed -r 's/^\s[0-9:]+\sup\s//' | sed -r 's/,\s+[0-9]+\susers.*//')
    if [ $? -ne 0 ]; then
        warn_i18n "Failed to fetch uptime info, skipping..." "Не вдалося отримати інформацію про час роботи, пропуск..."
        uptime="Unknown"
    fi
    res_str="${res_str}Uptime: ${uptime}\n"

    running_proccesses=$(ps aux | wc -l)
    if [ $? -ne 0 ]; then
        warn_i18n "Failed to fetch running proccesses info, skipping..." "Не вдалося отримати інформацію про процеси, пропуск..."
        running_proccesses="Unknown"
    fi
    res_str="${res_str}Processes running: ${running_proccesses}\n"

    unique_users=$(who | awk '{print $1}' | uniq | wc -l)
    if [ $? -ne 0 ]; then
        warn_i18n "Failed to users info, skipping..." "Не вдалося отримати інформацію про користувачів, пропуск..."
        unique_users="Unknown"
    fi
    res_str="${res_str}Users logged in: ${unique_users}\n"

    res_str="${res_str}----NETWORK----\n"
    # get all network interfaces
    #   -> grep names 
    #   -> remove number (leave name only) and whitespace 
    #   -> remove ':'
    net_interfaces=($(ip link show | grep -oE '^[0-9]+:\s[^\w]+:' | awk '{print $2}' | sed 's/://'))
    if [ $? -ne 0 ]; then
        warn_i18n "Failed to fetch network info, skipping..." "Не вдалося отримати інформацію про мережеві пристрої, пропуск..."
        res_str="${rest_str}\n"
    else
        for var in ${net_interfaces[@]}; do
            ip_addr=$(ip addr show "$var" | grep -E 'inet ' | awk '{print $2}')
            if [ -z "$ip_addr" ]; then
                ip_addr='-/-'
            fi
            res_str="${res_str}${var}: ${ip_addr}\n"
        done
    fi 
    res_str="${res_str}----EOF----\n"

    echo -e "$res_str" # -e means expand escaped sequences
}

for arg in $@; do
    case $arg in
        '-h' | '--help') print_help && exit 0;;
    esac
done

if (($# > 3)); then
    die_i18n "Too many arguments: $#!" "Забагато аргументів: $#!"
fi

while getopts "n:" OPTION; do # parse
    if [[ "$OPTARG" =~ ^-?[0-9]+$ ]]; then # check integer regex
        if ! (($OPTARG >= 1)); then
            die_i18n "-n must be an integer > 1, got $OPTARG" "-n повинна бути цілим числом > 1, а отримано $OPTARG"
        else
            _n=$OPTARG
        fi
    else
        die_i18n "-n must be an integer, got $OPTARG" "-n повинна бути цілим числом, а отримано $OPTARG"
    fi
done
shift $(($OPTIND - 1))
_file=$1

# if arguments not specified
if [ -z "$_n" ]; then
    _n=-1
fi

# if arguments not specified
if [ -z "$_file" ]; then
    _file="$HOME/bash/task1.out"
fi

_file_par_dir=$(dirname "$_file")
_file_name=$(basename $_file)
# check that directory for output exists
if [ ! -d $_file_par_dir ]; then
    print_i18n "Directory $_file_par_dir does not exist, creating..." "Директорія $_file_par_dir не існує, створюємо..."
    error_msg=$(mkdir -p "$_file_par_dir" 2>&1)
    # check if creating a directory failed
    if [ $? -ne 0 ]; then
        die_i18n "Error creating directory $_file_par_dir, reason: $error_msg" "Помилка при створенні директорії $_file_par_dir, причина: $error_msg"
    fi
fi

cur_d=$(date "+%Y%m%d")

_file_d="${_file}-${cur_d}"
_file_name_d="${_file_name}-${cur_d}"

if [ -f "$_file" ]; then
    # we get all the files with -nnnn in their names FOR TODAY, sort numerically from lowest to highest
    all_files_created_before=($(ls -1v "$_file_par_dir" | grep -E "^$_file_name_d"))
    num_found=${#all_files_created_before[@]}

    if [ $num_found -ne 0 ]; then
        # last_created_file_name=${all_files_created_before[$l]]}
        last_created_file_name=${all_files_created_before[$((num_found - 1))]}
        # remove the largest possible '*-' string from the beginning of the variable's contents
        last_created_number=${last_created_file_name##*-}
        new_number=$(expr "$last_created_number" + 1) # we use expr because otherwise 0100 -> 65 (octal -> dec)

        for ((i = $num_found - 1; i >= 0; i--)); do
            new_number_formatted="$(printf "%04d" $new_number)"
            old_file=${all_files_created_before[$i]}
            new_file="${_file_name_d}-${new_number_formatted}"
            
            mv "$_file_par_dir/$old_file" "$_file_par_dir/$new_file"

            new_number=$((new_number - 1))
        done   
    fi  

    mv "$_file" "$_file_d-0000"
fi

collect_info > "$_file"
print_i18n "Created output file $_file at $(date)." "Створено файл з результатами $_file, дата: $(date)"

updated_files_created_before=($(ls -1v "$_file_par_dir" | grep -E "^$_file_name_d"))
num_files=${#updated_files_created_before[@]}

if [ $_n -ne -1 ] && [ $_n -le $num_files ]; then
    for ((i = $num_files - 1; i >= $_n - 1; i--)); do
        file_to_delete="${updated_files_created_before[$i]}"
        print_i18n "Deleting old output file $file_to_delete..." "Видаляємо старий файл з результатами $file_to_delete..."
        rm -f "$_file_par_dir/$file_to_delete"
    done
fi