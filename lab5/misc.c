#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <time.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/types.h>


char *concat(const char *s1, const char *s2)
{
    char *result = malloc(strlen(s1) + strlen(s2) + 1);
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}

void log_message(char *str, int pid, int signal, char* signal_str)
{
    FILE *file;
    const char *home = getenv("HOME");
    
    struct stat st = {0};

    char *log_dir = concat(home, "/log");
    
    if (stat(log_dir, &st) == -1) {
        printf("Directory fail %s", log_dir);
        mkdir(log_dir, 0777);
    }
    char *path = concat(log_dir, "/pzpi-16-2-bekuzarov-maksym-lab5.log");
    time_t rawtime;
    struct tm *info;
    char buffer[80];

    time(&rawtime);

    info = localtime(&rawtime);

    strftime(buffer,80,"%a, %d %b %Y %X %z", info);

    char* timestamp = (char*)malloc(20 * sizeof(char));
    sprintf(timestamp, "%d",(int)time(NULL));
    file = fopen(path, "a+");

    char* message = (char*)malloc(100 * sizeof(char));
    sprintf(message, "%s; %s; %d; %d; %s; %s\n", buffer, timestamp, pid, signal, signal_str, str);
    fprintf(file, "%s", message);
    fclose(file);

    char* logger_formatted_message = (char*)malloc(100 * sizeof(char));
    sprintf(logger_formatted_message, "\"%s\"", message);
    system(concat("logger ", logger_formatted_message));
    
}

void ping_child_process(int pid)
{
    printf("Ping child process %d\n", pid);
    int result = kill(pid, SIGUSR1);
    printf("Ping result %d\n", result);
}

void kill_child_process(int pid)
{
    printf("Kill child process %d\n", pid);
    kill(pid, SIGTERM);
}

void ping_ask(int pid)
{
    printf("Ping ask process %d\n", pid);
    kill(pid, SIGUSR2);
}

void parent_ping_ask_handler() {
    printf("parent ping ask handler\n");
    log_message("Nothing - child pinged ask signal", getpid(), 17, "SIGUSR2");
}

void child_usr1_handler() {
    printf("child usr1 handler\n");
    log_message("Nothing - ping signal", getpid(), 16, "SIGUSR1");
}

void child_ping_ask_handler() {
    printf("child ping back handler\n");
    log_message("Nothing - child pinged back signal", getpid(), 17, "SIGUSR2");
    ping_ask(getppid());
}

void child_term_handler() {
    printf("child term handler\n");
    log_message("Child termination", getpid(), 15, "SIGTERM");
    exit(1);
}

void parent_child_died_handler() {
    printf("parent child die handler\n");
    log_message("Child process die", getpid(), 18, "SIGCHLD");
}