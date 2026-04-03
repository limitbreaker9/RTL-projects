#define CONTROL_REG (*((volatile int*) 0x10000000))
#define GREEN_TIME_REG (*((volatile int*) 0x10000004))
#define YELLOW_TIME_REG (*((volatile int*) 0x10000008))
void _start(){
    GREEN_TIME_REG  = 15;
    YELLOW_TIME_REG = 5;
    CONTROL_REG     = 1;
    while(1);
}