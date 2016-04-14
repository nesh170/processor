.text
main:
#register 1 holds time in terms of clock frequency
# register 2 holds 50000
# register 3 holds time to be displayed
# register 4 and 5 hold the potential keyboard inputs to check against
# register 6 holds the keyboard input
# register 7 holds the player's position
# register 8-10 holds the positions of the birds to check against (a, s, d)
#registers 11-13 holds the position of the birds
j game_loop
game_loop:
addi $r7, $r7,-120 #increment player's position for time - UPDATE CALL TO REFLECT CORRECT VALUE
addi $r1, $r1, 1 #register 1 holds time
jal check_time
lw $r4, left($r0)
lw $r5, right($r0)
beq $r6, $r4, move_left #z pressed
beq $r6, $r5, move_right #x pressed
continue_game_loop:
lw $r8, a($r0) #load value of a
lw $r9, s($r0)
lw $r10, d($r0)
beq $r6, $r8, a_press
beq $r6, $r9, s_press
beq $r6, $r10, d_press
check_bird_bug:
beq $r7, $r11, bird_one_hit
beq $r7, $r12, bird_two_hit
beq $r7, $r13, bird_three_hit
check_time:
addi $r2, $r0, 50000 #add 50000 to register 2 - 50000 is clock freq
beq $r1, $r2, update_time
# r1 = 50000, increment r2 that will be displayed on 7 seg display
jr $r31
update_time:
addi $r3, $r3, 1
add $r1, $r0, $r0
jr $r31
move_left:
addi $r7, $r7, -120
j continue_game_loop
move_right:
addi $r7, $r7, 120
j continue_game_loop
a_press:
addi $r11, $r7, 100 # CHANGE THIS CALL
j check_bird_bug
s_press:
addi $r12, $r7, 100 #CHANGE THIS CALL
j check_bird_bug
d_press:
addi $r13, $r7, 100 # CHANGE THIS CALL
j check_bird_bug
quit:
halt
.data
left: .char z
right: .char x
a: .char a
s: .char s
d: .char d