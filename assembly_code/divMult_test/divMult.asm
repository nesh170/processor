.text
main:
addi $r3,$r0,10
addi $r2,$r5,5
div $r4,$r3,$r2
nop
nop
nop
nop
nop
nop
nop
mul $r5,$r3,$r2
nop
nop
nop
nop
j exit
exit:
halt
.data
left: .word 0x00000001
right: .word 0x00000002