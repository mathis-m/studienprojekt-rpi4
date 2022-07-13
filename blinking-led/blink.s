@ mmap part taken from by https://bob.cs.sonoma.edu/IntroCompOrg-RPi/sec-gpio-mem.html

@ Constants for blink at GPIO21
@ GPIO_NUM can be set to any GPIO PIN
.equ    GPIO_NUM, 21    @ Target GPIO PIN

@ GPOI Related
.equ    GPCLR0, 0x28    @ clear register offset
.equ    GPSET0, 0x1c    @ set register offset

@ Args for mmap
.equ    OFFSET_FILE_DESCRP, 0   @ file descriptor
.equ    mem_fd_open, 3
.equ    BLOCK_SIZE, 4096        @ Raspbian memory page
.equ    ADDRESS_ARG, 3          @ device address

@ Misc
.equ    SLEEP_IN_S,1        @ sleep one second
.equ    BIT_3_MASK, 0b111   @ Mask for 3 bits

@ The following are defined in /usr/include/asm-generic/mman-common.h:
.equ    MAP_SHARED,1    @ share changes with other processes
.equ    PROT_RDWR,0x3   @ PROT_READ(0x1)|PROT_WRITE(0x2)

@ Constant program data
    .section .rodata
device:
    .asciz  "/dev/gpiomem"


@ The program
    .text
    .global main
main:
@ Open /dev/gpiomem for read/write and syncing
    ldr     r1, O_RDWR_O_SYNC   @ flags for accessing device
    ldr     r0, mem_fd          @ address of /dev/gpiomem
    bl      open     
    mov     r4, r0              @ use r4 for file descriptor

@ Map the GPIO registers to a main memory location so we can access them
@ mmap(addr[r0], length[r1], protection[r2], flags[r3], fd[r4])
    str     r4, [sp, #OFFSET_FILE_DESCRP]   @ r4=/dev/gpiomem file descriptor
    mov     r1, #BLOCK_SIZE                 @ r1=get 1 page of memory
    mov     r2, #PROT_RDWR                  @ r2=read/write this memory
    mov     r3, #MAP_SHARED                 @ r3=share with other processes
    mov     r0, #mem_fd_open                @ address of /dev/gpiomem
    ldr     r0, GPIO_BASE                   @ address of GPIO
    str     r0, [sp, #ADDRESS_ARG]          @ r0=location of GPIO
    bl      mmap
    mov     r5, r0           @ save the virtual memory address in r5

@ Alias some registers that will be prepopulated and used later on
    GPFSEL_N_OFFSET         .req r6     @ Will hold offset to GPFSELn register for GPIO_NUM
    GPSET_N_OFFSET          .req r7     @ Will hold offset to GPCLRn register for GPIO_NUM
    GPCLR_N_OFFSET          .req r8     @ Will hold offset to GPSETn register for GPIO_NUM
    GPFSEL_MASK             .req r9     @ Mask for setting function for GPIO_NUM
    GPFSEL_MAKE_OUTPUT_VAL  .req r10     @ Value for bitwise or to make PIN an output

@ Calculate GPIO register offsets and util values
    mov     r11, #GPIO_NUM      @ Store Target PIN NUM for calc

    @ Calculate GPFSELn offset (GPFSEL0 starts at offset 0x0)
    mov     r3, #10                 @ divisor (each GPFSEL register has place for 10 PIN Fields)
    udiv    r0, r11, r3             @ GPFSEL number = pin num / 10

    lsl     GPFSEL_N_OFFSET, r0, #2 @ each GPFSEL register has size of 4 bytes => shift reg num by 2 == offset
    
    @ Calculate GPSETn / GPCLRn offset
    mov     r3, #32         @ divisor (each GPSET / GPCLR register has place for 32 PIN Fields)
    udiv    r0, r11, r3     @ GPSET / GPCLR number = PIN NUM / 32

    lsl     GPSET_N_OFFSET, r0, #2                      @ each GPSET register has size of 4 bytes => shift reg num by 2 == offset to GPSET0
    mov     GPCLR_N_OFFSET, GPSET_N_OFFSET              @ copy to GPCLR_N_OFFSET
    add     GPSET_N_OFFSET, GPSET_N_OFFSET, #GPSET0     @ calculate offset using start offset
    add     GPCLR_N_OFFSET, GPCLR_N_OFFSET, #GPCLR0     @ calculate offset using start offset

    @ Calculate util values based on pin num
    mul     r1, r0, r3      @ compute remainder
    sub     r1, r11, r1     @     for GPFSEL pin => nth pin in GPFSELn register
    
    mov     r3, r1                      @ need to multiply pin
    add     r1, r1, r3, lsl #1          @    position by 3 (each pin has 3 bits in GPFSELn)

    mov     GPFSEL_MASK, #BIT_3_MASK    @ 3 bit high mask
    lsl     GPFSEL_MASK, GPFSEL_MASK, r1@ shift mask to pin position (shift= 3 * pin num)

    mov     GPFSEL_MAKE_OUTPUT_VAL, #1                          @ make output bit
    lsl     GPFSEL_MAKE_OUTPUT_VAL, GPFSEL_MAKE_OUTPUT_VAL, r1  @ shift bit to pin position[0] (shift= 3 * pin num)

@ Set up the GPIO pin funtion register in programming memory
    add     r0, r5, GPFSEL_N_OFFSET         @ calculate address for GPFSELn
    ldr     r2, [r0]                        @ get entire GPFSELn register
    bic     r2, r2, GPFSEL_MASK             @ clear pin field
    orr     r2, r2, GPFSEL_MAKE_OUTPUT_VAL  @ enter function code
    str     r2, [r0]                        @ update register


@ blinking 
loop:

@ Turn on
    add     r0, r5, GPSET_N_OFFSET  @ calc GPSETn address
    ldr     r2, [r0]                @ get entire GPSET0 register

    mov     r3, #1              @ turn on bit
    lsl     r3, r3, #GPIO_NUM   @ shift bit to pin position
    orr     r2, r2, r3          @ set bit
    str     r2, [r0]            @ update register

    mov     r0, #SLEEP_IN_S @ wait a second
    bl      sleep

@ Turn off
    add     r0, r5, GPCLR_N_OFFSET  @ calc GPCLRn address
    ldr     r2, [r0]                @ get entire GPCLRn register

    mov     r3, #1              @ turn off bit
    lsl     r3, r3, #GPIO_NUM   @ shift bit to pin position
    orr     r2, r2, r3          @ set bit
    str     r2, [r0]            @ update register

    mov     r0, #SLEEP_IN_S @ wait a second
    bl      sleep
    b       loop

GPIO_BASE:
    .word   0xfe200000  @GPIO Base address Raspberry pi 4
mem_fd:
    .word   device
O_RDWR_O_SYNC:
    .word   2|256       @ O_RDWR (2)|O_SYNC (256).
