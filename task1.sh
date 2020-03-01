#!/bin/bash
print_error() {
    echo "$1";
    exit 1
}

print_help() {
    echo "Help message!"
    exit 0
}

for arg in $@; do
    case $arg in 
        '-h'|'--help') print_help;;
    esac
done

if (( $# > 3 )); then
    print_error "Too many arguments: $#!";
fi

while getopts "n:" OPTION; do  # parse
    echo "$OPTION"
    if [[ "$OPTARG" =~ ^-?[0-9]+$ ]]; then  # check integer regex
        if ! (( $OPTARG >= 1)); then
            print_error "-n must be an integer > 1, got $OPTARG"
        else
            _n=$OPTARG
        fi
    else
        print_error "-n must be an integer, got $OPTARG"
    fi
done
shift $(( $OPTIND - 1 ))
_file=$1

# if arguments not specified
if [ -z "$_n" ]; then
    _n=-1
fi

# if arguments not specified
if [ -z "$_file" ]; then
    _file='~/bash/task1.out'
fi

echo "$_n"
# echo "$_file"

_file_par_dir=$(dirname "$_file")
_file_name=$(basename $_file)
# check that directory for output exists
if [ ! -d $_file_par_dir ]; then
    echo "Directory $_file_par_dir does not exist, creating..."
    error_msg=$(mkdir -p "$_file_par_dir" 2>&1)  
    # check if creating a directory failed
    if [ $? ]; then
        echo "Error creating directory $_file_par_dir, reason: $error_msg"
        exit 1
    fi
else
    echo "Directory exists! ($_file_par_dir)"
fi

if [ -f "$_file" ]; then
    cur_d=$(date "+%Y%m%d")
    
    _file="${_file}-${cur_d}";
    # we get all the files with -nnnn in their names, sorted numerically from lowest to highest
    all_files_created_before=($(ls -1v "$_file_par_dir" | grep -E "^$_file_name-[0-9]{4,}"))
    if [ ${#all_files_created_before[@]} -eq 0 ]; then  # if no such files found (i.e. len(all_files...) == 0)
        _file="${_file}-0000"
    else
        last_created_file_name=${all_files_created_before[-1]}
        # remove the largest possible '*-' string from the beginning of the variable's contents
        last_created_number=${last_created_file_name##*-}
        last_created_number=$(expr "$last_created_number" + 1)  # we use expr because otherwise 0100 -> 65 (octal -> dec)
        new_created_number="$(printf "%04d" $last_created_number)"
        _file="${_file}-${new_created_number}"
        if [ $_n -ne -1 ] && [ $_n -le ${#all_files_created_before[@]} ]; then
            leave_n_files=$(expr ${#all_files_created_before[@]} - $_n + 1)  # we delete +1 file because we will create a new just after
            for var in ${all_files_created_before[@]: 0:$leave_n_files}; do
                echo "Deleting old output file ${var}..."
                rm "${_file_par_dir}/${var}"
            done
        fi
    fi
fi
echo "$_file"
touch "$_file"