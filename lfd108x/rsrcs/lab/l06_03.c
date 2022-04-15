#include<fcntl.h>
#include<string.h>
#include<unistd.h>
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char **argv){
    if(argc != 2){
        printf("Enter a file name to write");
        exit(EXIT_SUCCESS);
    }
    int fd = open(argv[1], O_RDWR | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);
    char *buff = strdup("TESTING A WRITE");
    int rc = write(fd, buff, strlen(buff));
    printf("wrote %d bytes to %s\n", rc, argv[1]);
    close(fd);
    exit(EXIT_SUCCESS);
}
