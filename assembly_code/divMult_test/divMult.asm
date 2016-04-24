.text
main:
addi $r3,$r0,10
addi $r2,$r5,5
div $r4,$r3,$r2
nop
nop
nop
nop
div $r8,$r4,$r0
nop
bex 8
addi $r5,$r0,28 #bexFAILED
setxWork:
nop
nop
addi $r9,$r0,15 #setxWork
mul $r5,$r3,$r2
nop
nop
j exit
bexWork:
setx 5
addi $r14,$r8,48 #bexWork
nop
bex -11
addi $r15,$r9,32 #bexFAILED, or setXFAILED
j exit
exit:
halt
.data
left: .word 0x00000001
right: .word 0x00000002