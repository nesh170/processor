.text
main:
addi $r1,$r0,0 #color register
addi $r2,$r0,0
lw $r3,0($r0)
j color_loop

color_loop:



exit:
halt
.data
addr: .word 0x0004AFFF