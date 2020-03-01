#!/bin/bash
print_error() {
    >&2 echo "$1"
    exit 1
}

print_help() {
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
    
    echo -e "$str"
    exit 0
}

collect_info() {
    res_str="Date: $(date)\n"
    res_str="${res_str}----HARDWARE----\n"
    cpu_info=$(cat /proc/cpuinfo | grep -m 1 'model name')
    if [ $? -ne 0 ]; then
        >&2 echo "Failed to fetch CPU info, skipping..."
        cpu_info="Unknown"
    else
        cpu_info=${cpu_info##*: }
    fi
    res_str="${res_str}CPU: \"${cpu_info}\"\n"

    mem_info=$(cat /proc/meminfo | grep -m 1 'MemTotal')
    if [ $? -ne 0 ]; then
        >&2 echo "Failed to fetch memory info, skipping..."
        mem_info="Unknown"
    else
        mem_info=${mem_info##*: }
        mem_info=${mem_info%%kB}
        mem_info="$(numfmt --to iec $((mem_info * 1000)))"
    fi
    res_str="${res_str}Memory: ${mem_info}B\n"

    mb_info_raw_str=$(sudo dmidecode --type baseboard)
    if [ $? -ne 0 ]; then
        >&2 echo "Failed to fetch motherboard info, skipping..."
        mb_info="Unknown"
    else
        mb_manufacturer=$(echo "$mb_info_raw_str" | grep Manufacturer)
        mb_manufacturer=${mb_manufacturer##*: }
        mb_product_name=$(echo "$mb_info_raw_str" | grep 'Product Name')
        mb_product_name=${mb_product_name##*: }
        mb_info="\"${mb_manufacturer}\", \"${mb_product_name}\""
    fi
    res_str="${res_str}Motherboard: ${mb_info}\n"

    serial_info=$(sudo dmidecode --type system | grep 'Serial Number')
    if [ $? -ne 0 ]; then
        >&2 echo "Failed to fetch serial number info, skipping..."
        serial_info="Unknown"
    else
        serial_info=${serial_info##*: }
    fi
    res_str="${res_str}System Serial Number: ${serial_info}\n"

    res_str="${res_str}----SYSTEM----\n"

    os_release=$(cat /etc/os-release | grep "PRETTY_NAME")
    if [ $? -ne 0 ]; then
        >&2 echo "Failed to fetch os release info, skipping..."
        os_release="Unknown"
    else
        os_release=${os_release##*=}
    fi
    res_str="${res_str}OS Distribution: ${os_release}\n"

    kernel_info=$(uname -v)
    if [ $? -ne 0 ]; then
        >&2 echo "Failed to fetch os kernel info, skipping..."
        kernel_info="Unknown"
    fi
    res_str="${res_str}Kernel version: ${kernel_info}\n"

    created_info=$(sudo dumpe2fs $(mount | grep 'on / ' | awk '{print $1}') 2> /dev/null | grep 'Filesystem created: ')
    if [ $? -ne 0 ]; then
        >&2 echo "Failed to fetch installation date info, skipping..."
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
        >&2 echo "Failed to fetch hostname info, skipping..."
        hostname="Unknown"
    fi
    res_str="${res_str}Hostname: ${hostname}\n"

    uptime=$(uptime -p | sed 's/up\s*//')
    if [ $? -ne 0 ]; then
        >&2 echo "Failed to fetch uptime info, skipping..."
        uptime="Unknown"
    fi
    res_str="${res_str}Uptime: ${uptime}\n"

    running_proccesses=$(ps aux | wc -l)
    if [ $? -ne 0 ]; then
        >&2 echo "Failed to fetch running proccesses info, skipping..."
        running_proccesses="Unknown"
    fi
    res_str="${res_str}Processes running: ${running_proccesses}\n"

    unique_users=$(who | awk '{print $1}' | uniq | wc -l)
    if [ $? -ne 0 ]; then
        >&2 echo "Failed to users info, skipping..."
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
        >&2 echo "Failed to fetch network info, skipping..."
        res_str="${rest_str}\n"
    else
        for var in ${net_interfaces[@]}; do
            ip_addr=$(ip addr show "$var" | grep -E 'inet ' | awk '{print $2}')
            if [ -z "$ip_addr" ]; then
                ip_addr='NoIP'
            fi
            res_str="${res_str}${var}: ${ip_addr}\n"
        done
    fi 
    res_str="${res_str}----EOF----\n"

    echo -e "$res_str" # -e means expand escaped sequences
}

for arg in $@; do
    case $arg in
    '-h' | '--help') print_help ;;
    esac
done

if (($# > 3)); then
    print_error "Too many arguments: $#!"
fi

while getopts "n:" OPTION; do # parse
    if [[ "$OPTARG" =~ ^-?[0-9]+$ ]]; then # check integer regex
        if ! (($OPTARG >= 1)); then
            print_error "-n must be an integer > 1, got $OPTARG"
        else
            _n=$OPTARG
        fi
    else
        print_error "-n must be an integer, got $OPTARG"
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
    _file='~/bash/task1.out'
fi

_file_par_dir=$(dirname "$_file")
_file_name=$(basename $_file)
# check that directory for output exists
if [ ! -d $_file_par_dir ]; then
    echo "Directory $_file_par_dir does not exist, creating..."
    error_msg=$(mkdir -p "$_file_par_dir" 2>&1)
    # check if creating a directory failed
    if [ $? ]; then
        print_error "Error creating directory $_file_par_dir, reason: $error_msg"
    fi
fi

if [ -f "$_file" ]; then
    cur_d=$(date "+%Y%m%d")

    _file="${_file}-${cur_d}"
    # we get all the files with -nnnn in their names, sorted numerically from lowest to highest
    all_files_created_before=($(ls -1v "$_file_par_dir" | grep -E "^$_file_name-[0-9]{4,}"))
    if [ ${#all_files_created_before[@]} -eq 0 ]; then # if no such files found (i.e. len(all_files...) == 0)
        _file="${_file}-0000"
    else
        last_created_file_name=${all_files_created_before[-1]}
        # remove the largest possible '*-' string from the beginning of the variable's contents
        last_created_number=${last_created_file_name##*-}
        last_created_number=$(expr "$last_created_number" + 1) # we use expr because otherwise 0100 -> 65 (octal -> dec)
        new_created_number="$(printf "%04d" $last_created_number)"
        _file="${_file}-${new_created_number}"
        if [ $_n -ne -1 ] && [ $_n -le ${#all_files_created_before[@]} ]; then
            leave_n_files=$(expr ${#all_files_created_before[@]} - $_n + 1) # we delete +1 file because we will create a new just after
            for var in ${all_files_created_before[@]:0:$leave_n_files}; do
                echo "Deleting old output file ${var}..."
                rm "${_file_par_dir}/${var}"
            done
        fi
    fi
fi

collect_info > "$_file"
echo "Created output file $_file at $(date)."