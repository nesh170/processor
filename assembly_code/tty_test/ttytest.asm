.text
main:
addi $r0, $r0, 0
addi $r4, $r0, 255
j loop
loop:
addi $r3,$r0,0
addi $r5,$r0,7
addi $r5,$r0,3
addi $r5,$r0,20
j loop


.data
addr: .word 0x0004AFFF