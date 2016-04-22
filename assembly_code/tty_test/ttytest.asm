.text
main:
addi $r0, $r0, 0
addi $r4, $r0, 255
j loop
loop:
addi $r27,$r0,0
bne $r27,$r0,keyboard_test
j loop
keyboard_test:
#execute the keyboard checks in here
nop
nop
nop
nop
nop
j loop
.data
addr: .word 0x0004AFFF