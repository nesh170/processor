.text
main:
addi $r2, $r0, 0
lw $r3, 0($r0)
addi $r1, $r0, 0
addi $r4, $r0, 255
j color_loop
color_loop:
bgt $r1, $r4, exit_color
jal loop
addi $r1, $r1, 1
j color_loop
loop:
bgt $r2, $r3, exit
sw $r1, 0($r2)
addi $r2, $r2, 1
j loop
exit:
jr $ra
exit_color:
halt
.data
addr: .word 0x0004AFFF