.text
main:
addi $r1, $r0, 300
addi $r2, $r0, 300
bne $r1, $r2, 4
add $r0, $r0, $r0
lw $r6, 0($r0)
add $r5, $r6, $r7
add $r0, $r0, $r0
addi $r7, $r0, 750
.data