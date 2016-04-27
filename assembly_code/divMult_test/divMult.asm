.text
main:
addi $r3,$r0,10
addi $r2,$r5,5
div $r8,$r4,$r0
nop
nop
nop
nop
div $r4,$r3,$r2
nop
bex bexWork
addi $r5,$r0,28 #bexFAILED
setxWork:
nop
nop
addi $r9,$r0,15 #setxWork
mul $r5,$r3,$r2
nop
nop
setx -1
bex setXFail
addi $r3,$r0,1566
j testMult
setXFail:
addi $r15,$r0,9000
j exit
bexWork:
setx 5
addi $r14,$r8,48 #bexWork
nop
bex setxWork
addi $r15,$r9,32 #bexFAILED, or setXFAILED
j exit
works:
addi $r15,$r0,7512 #that mult exp woked
j exit
testMult:
lw $r15,0($r0)
lw $r16,1($r0)
mul $r27,$r16,$r15
nop
nop
nop
nop
bex works
addi $r3,$r0,2323 #failed
j exit
exit:
halt
.data
lefta: .word 0xFFFFFFFF
right: .word 0xFFFFFFFF