.text
main:
addi $r6, $r0, 1
lw $r4, 1($r0)
nop
nop
bne $r4, $r6, move_left #z pressed
round:
lw $r4, 0($r0)
nop
nop
bne $r4, $r6, move_right #x pressed
sky:
lw $r12, 2($r0)
addi $r18,$r12,52
move_left:
addi $r8,$r7,5
addi $r6,$r0,2
j round
move_right:
addi $r8,$r7,20
j sky



j exit
exit:
halt
.data
left: .word 0x00000001
right: .word 0x00000002
temp: .word 0x00000003