#include <stdio.h>
#include <stdlib.h>


#include "igpg.h"

int 
main(int argc, char **argv) {
    printf("start test\n");


    gpg_main(argc, argv);
    //g10_exit(1);


    printf("end test\n");
    return 0;
}
