.text
main:
addi $r2, $r0, 165761
addi $r3, $r0, 191361
addi $r1, $r0, 255
j loop
loop:
bgt $r2, $r3, exit
sw $r1, 0($r2)
addi $r2, $r2, 1
j loop
exit:
halt
.data