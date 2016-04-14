.text
main:
#register 1 holds time in terms of clock frequency
# register 2 holds 50000
# register 3 holds time to be displayed
# register 4 and 5 hold the potential keyboard inputs to check against
# register 6 holds the keyboard input
j game_loop
game_loop:
addi $r1, $r1, 1 #register 1 holds time
jal calc_time
lw $r4, left($r0)
lw $r5, right($r0) 
calc_time:
addi $r2, $r0, 50000 #add 50000 to register 2 - 50000 is clock freq
bne $r1, $r2, update_time
# r1 = 50000, increment r2 that will be displayed on 7 seg display
jr $r31
update_time:
addi $r3, $r3, 1
add $r1, $r0, $r0
jr $r31
.data
left: .char Z
right: .char X