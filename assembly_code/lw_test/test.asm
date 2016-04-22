.text
main:
addi $r6, $r0, 1
lw $r4, 1($r0)
bne $r4, $r6, move_left #z pressed
lw $r4, 0($r0)
bne $r4, $r6, move_right #x pressed
move_left:
addi $r8,$r7,5
addi $r6,$r0,2
j exit
move_right:
addi $r8,$r7,20
exit:
halt
.data
left: .word 0x00000001
right: .word 0x00000002