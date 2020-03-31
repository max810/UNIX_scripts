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
        str="Розроблено Бекузаровим Максимом 2020-03-28.\n"
        str="${str}Цей скрипт запускає REPL для комунікації з дочірним процесом за допомогою сигналів.\n"
        str="${str}Команди для REPL:\n"
        str="${str}\tping - відправити сигнал до дочірнього процесу.\n"
        str="${str}\task - відправити сигнал до дочірнього процесу, на який буде надіслано відповідь.\n"
        str="${str}\tstop - зупинити доічірній процес.\n"
    else
        str="Developed by Maksym Bekuzarov on 2020-03-01.\n"
        str="${str}This script launches REPL for communicating with the child process using SIGNALS.\n"
        str="${str}The following commands are supported:\n"
        str="${str}\tping - send a signal to the child process.\n"
        str="${str}\task - send a signal to the child process, that will be answered.\n"
        str="${str}\tstop - stop child process.\n"
    fi
    
    echo -e "$str"
}

cur_file_name=$(basename "$0")

ensure_log_file_exists() {
    if [ ! -d "$HOME/log" ]; then
        mkdir "$HOME/log"
    fi

    if [ ! -f "$HOME/log/$cur_file_name" ]; then
        touch "$HOME/log/$cur_file_name"
    fi
}

case $1 in
    '-h' | '--help') print_help && exit 0;;
esac


log_message() {
    msg="$1"
    current_date=$(date)
    timestamp=$(date +%s)
    message=$(printf "%s; %s; %s" "$current_date" "$timestamp" "$msg")
    logger $message
    echo $message >> "$HOME/log/$cur_file_name"
}

ping_child() {
    kill -SIGUSR1 "$child_pid"
    echo "Sent test signal to child process"
}

ask_child() {
    kill -SIGUSR2 "$child_pid"
    echo "Sent ping back signal to child process"
}

kill_child() {
    kill -SIGTERM "$child_pid"
    echo "Killed child process"
}

on_parent_term() { 
    kill -SIGTERM "$child_pid"
    log_message "${current_pid}; 15; SIGTERM; parent exits and sends SIGTERM to child"
    echo "Sent sigterm to child with pid=${child_pid}"
    exit 1
}

on_parent_int() {
    log_message "${current_pid}; 2; SIGINT; parent was interrupted."
    exit 1
}

on_parent_answer() {
    log_message "${current_pid}; 12; SIGUSR2; child answered!"
}

ensure_log_file_exists

(
    child_term() {
        ya=$(exec sh -c 'echo "$PPID"')
        log_message "${ya}; 15; SIGTERM; child process terminated"
        exit 1
    }

    custom_signal() {
        ya=$(exec sh -c 'echo "$PPID"')
        log_message "${ya}; 10; SIGUSR1; ping signal"
    }

    ping_back_signal() {
        ya=$(exec sh -c 'echo "$PPID"')
        log_message "${ya}; 12; SIGUSR2; answer parent's ping"
        kill -SIGUSR2 $$
    }

    health_check() {
        ya=$(exec sh -c 'echo "$PPID"')
        log_message "${ya}; 18; SIGCONTv; health check"
    }

    echo "Inside the child process"

    trap child_term SIGTERM
    trap custom_signal SIGUSR1
    trap ping_back_signal SIGUSR2
    trap health_check 18

    while true; do
        echo "Child is working..." 1>/dev/null
        sleep 5
    done
) &

child_pid=$!
current_pid=$$
echo "Created child process ${child_pid}"
echo "My process ${current_pid}"


trap on_parent_term SIGTERM
trap on_parent_int SIGINT
trap on_parent_answer SIGUSR2

(
    # infinite ping loop - i.e. health_check
    while true; do
        kill -18 "$child_pid" 2>/dev/null
        sleep 3
    done
) &

health_check_pid=$!
echo "Health check pid=${health_check_pid}"

while read -r -p "Type command (ping;kill;ask;q): "; do
  case $REPLY in
    ping) ping_child;;
    kill) kill_child;;
    ask) ask_child;;
    q) break;;
    *) echo "Wrong command.";;
  esac
done

kill $health_check_pid