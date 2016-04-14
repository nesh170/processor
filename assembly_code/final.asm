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
# registers 14-16 hold the bound limits for the screen
# register 30 holds losing status
# register 19 holds the coordinate value limit for drawing
lw $r4, left($r0)
lw $r5, right($r0)
lw $r8, a($r0)
lw $r9, s($r0)
lw $r10, d($r0)
addi $r14, $r0, 160
addi $r15, $r0, 320
addi $r16, $r0, 480
j game_loop
game_loop:
addi $r7, $r7,-120 #increment player's position for time - UPDATE CALL TO REFLECT CORRECT VALUE
jal check_player_pos
addi $r1, $r1, 1 #register 1 holds time
jal check_time
beq $r6, $r4, move_left #z pressed
beq $r6, $r5, move_right #x pressed
continue_game_loop:
beq $r6, $r8, a_press 
beq $r6, $r9, s_press
beq $r6, $r10, d_press
check_bird_bug: #check for bug intersecting bird
beq $r7, $r11, quit
beq $r7, $r12, quit
beq $r7, $r13, quit
# render screen
addi $r19, $r0, 480
jal draw_line_right
jal draw_bug
jal draw_bird
# jump back to game loop
j game_loop
# if player position less than (160, 320, 480) mod back to bottom of screen
check_player_pos:
beq $r7, $r14, mod_left
beq $r7, $r15, mod_center
beq $r7, $r16, mod_right
jr $r31
mod_left:
addi $r7, $r0, 306720
jr $r31
mod_center:
addi $r7, $r0, 306880
jr $r31
mod_right:
addi $r7, $r0, 307040
jr $r31
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
draw_line_right:
addi $r19, $r0, 480
addi $r17, $r0, 307040
lw $r18, color_one($r0)
swd r18, 0($r17)
addi $r17, $r17, -640
blt $r17, $r19, stop_draw_line
j draw_line
stop_draw_line:
jr $ra
quit:
addi $r30, $r0, -1
halt
.data
left: .char z
right: .char x
a: .char a
s: .char s
d: .char d
color_one .word 0x00ffffff
color_two .word 0x00ffffff
color_three .word 0x00ffffff