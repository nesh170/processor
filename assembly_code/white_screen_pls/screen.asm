.text
main:
addi $r2, $r0, 0
addi $r3, $r0, 307199
addi $r1, $r0, 160077215
j loop
loop:
bgt $r2, $r3, exit
sw $r1, 0($r0)
addi $r2, $r2, 1
j loop
exit:
halt
.data