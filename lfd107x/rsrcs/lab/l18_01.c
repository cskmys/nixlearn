#include <stdio.h>
#include <stdlib.h>
#include <sys/sysinfo.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>

#define MB (1024*1024) // in bytes
#define QUIT_TIME (20) // in seconds
#define BS (16) // nb MB allocated per iteration
#define CHUNK (MB * BS) // nb bytes allocated per iteration
#define SLEEP_TIME (5)

void quitOnTimeout(int sig){
    printf("\n\nTime expired, quitting\n");
    exit(EXIT_SUCCESS);
}

int main(int argc, char **argv){
    struct sysinfo si;
    sysinfo(&si);
    int m = si.totalram / MB;
    printf("Total System Memory in MB = %d MB\n", m);
    m = (9 * m)/10; // reduce 10%
    printf("Will consume somewhat less: %d MB\n", m);

    if(argc == 2 && strcmp(argv[1],"")){
        m = atoi(argv[1]);
        printf("Will consume instead mem = %d MB\n", m);
    }

    signal(SIGALRM, quitOnTimeout);
    printf("Will quite in %d seconds if no normal termination\n", QUIT_TIME);
    alarm(QUIT_TIME);

#ifndef TEST
    for(int i = 0; i <= m; i += BS){
        char *c = malloc(CHUNK);
        memset(c, i, CHUNK);
        printf("%8d", i);
        fflush(stdout);
    }
#endif

    printf("\n\n Sleeping for %d seconds\n", SLEEP_TIME);
    sleep(SLEEP_TIME);
    printf("\n\n Quitting and releasing memory\n");
    exit(EXIT_SUCCESS);
}