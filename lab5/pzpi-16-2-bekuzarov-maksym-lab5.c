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


int main(){
    const int PING_CHOICE = 10;
    const int KILL_CHOICE = 11;
    const int PING_ASK_CHOICE = 12;
    const int EXIT_CHOICE = 13;
    
    int pid = fork();

    if (pid == 0) {
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
            char text_choice[100];
            int choice;

            scanf("%s", text_choice);
            if (strcmp(text_choice, "ping") == 0)
            {
                choice = PING_CHOICE;
            }
            if (strcmp(text_choice, "kill") == 0)
            {
                choice = KILL_CHOICE;
            }
            if (strcmp(text_choice, "ask") == 0)
            {
                choice = PING_ASK_CHOICE;
            }
            if (strcmp(text_choice, "quit") == 0)
            {
                choice = EXIT_CHOICE;
            }
            int exit;
            switch (choice)
            {
            case 10:
                ping_child_process(pid);
                break;
            case 11:
                kill_child_process(pid);
                break;
            case 12:
                ping_ask(pid);
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
