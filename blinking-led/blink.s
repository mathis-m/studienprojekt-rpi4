.global _start

@ constants for GPIO21
@ see docu https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf

.equ BASE_GPIO_ADDR, 0xfe200000         @ GPIO base addr 0x3f200000 in arm space
.equ GPFSEL2, 0x08                      @ GPIO Function Select 2 offset (for GPIO Pins 20 to 29)
.equ GPCLR0, 0x28                       @ GPIO Pin Output Clear 0 offset (for GPIO Pins 0 to 31)
.equ GPSET0, 0x1c                       @ GPIO Pin Output Set 0 offset (forGPIO Pins 0 to 31)
.equ GPIO21_OUTPUT, 0b1000              @ Value for GPIO21 as Output (1 << 3)
.equ GPIO21_SET, 0x200000               @ Value for setting GPIO21 (1 << 21)


_start:
    ldr r0,=BASE_GPIO_ADDR

    @ Set GPIO21 as output
    ldr r1,=GPIO21_OUTPUT               @ Load the offset for GPIO21 select addr
    str r1,[r0,#GPFSEL2]                @ Store the offset for GPIO21 select addr

    @ Test turn on
    ldr r1,=GPIOVAL                     @ Load set value
    str r1, [r0,#GPSET0]               @ Store it in set register