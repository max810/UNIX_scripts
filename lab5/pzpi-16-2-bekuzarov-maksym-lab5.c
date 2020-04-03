#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <time.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/types.h>
#include "misc.h"

const int PING_CHOICE = 10;
const int KILL_CHOICE = 11;
const int PING_ASK_CHOICE = 12;
const int EXIT_CHOICE = 13;

int str_eqls(const char *str1, const char *str2) {
    return strcmp(str1, str2) == 0;
}

int main(int argc, char** argv){
    if(argc == 2 && (str_eqls(argv[1], "--help") || str_eqls(argv[1], "-h")))
    {
        printf("Developed by Maksym Bekuzarov on 2020-03-10.\n");
        printf("This programme launches REPL for communicating with the child process using SIGNALS.\n");
        printf("The following commands are supported:\n");
        printf("\tping - send a signal to the child process.\n");
        printf("\task - send a signal to the child process, that will be answered.\n");
        printf("\tstop - stop child process.\n");
        printf("\tquit - exits the programme.\n");
        return 0;
    }
    int process_id = fork();

    if (process_id == 0) {
        printf("OOPSIE...\n");
        signal(SIGUSR1, child_usr1_handler);
        signal(SIGTERM, child_term_handler);
        signal(SIGUSR2, child_ping_ask_handler);
        while (1) {

        }
    } else {
        signal(SIGUSR2, parent_ping_ask_handler);
        signal(SIGCHLD, SIG_IGN);
    
        while (1)
        {
            printf("Type command (ping;kill;ask;quit):\n");
            char user_input[100];
            int choice;

            scanf("%s", user_input);
            if (strcmp(user_input, "ping") == 0)
            {
                choice = PING_CHOICE;
            }
            if (str_eqls(user_input, "kill"))
            {
                choice = KILL_CHOICE;
            }
            if (str_eqls(user_input, "ask"))
            {
                choice = PING_ASK_CHOICE;
            }
            if (str_eqls(user_input, "quit"))
            {
                choice = EXIT_CHOICE;
            }
            int exit;
            switch (choice)
            {
            case 10:
                ping_child_process(process_id);
                break;
            case 11:
                kill_child_process(process_id);
                break;
            case 12:
                ping_ask(process_id);
                break;
            case 13:
                exit = 1;
                break;
            default:
                printf("Wrong command\n");
                break;
            }
            if (exit == 1)
            {
                break;
            }
        }
        
    }

    
    return 0;
}
