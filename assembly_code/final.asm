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
# register 17 holds the indexing for the for loop
# register 18 holds the color that is loaded from data memory
# register 19 holds the coordinate value limit for drawing
lw $r4, 0($r0)
lw $r5, 1($r0)
lw $r8, 2($r0)
lw $r9, 3($r0)
lw $r10, 4($r0)
addi $r14, $r0, 160
addi $r15, $r0, 320
addi $r16, $r0, 480
j game_loop
game_loop:
addi $r7, $r7,-120 #increment player's position for time - UPDATE CALL TO REFLECT CORRECT VALUE
jal check_player_pos
addi $r1, $r1, 1 #register 1 holds time
jal check_time
bne $r6, $r4, move_left #z pressed
bne $r6, $r5, move_right #x pressed
continue_game_loop:
bne $r6, $r8, a_press 
bne $r6, $r9, s_press
bne $r6, $r10, d_press
check_bird_bug: #check for bug intersecting bird
bne $r7, $r11, quit
bne $r7, $r12, quit
bne $r7, $r13, quit
# render screen, draw right line first
addi $r17, $r0, 307040
lw $r18, 5($r0)
addi $r19, $r0, 480
jal draw_line
addi $r17, $r0, 306880
# register18 should still have the color of the line, draw middle line
addi $r19, $r0, 320
jal draw_line
# draw left line
addi $r17, $r0, 304160
addi $r19, $r0, 160
jal draw_line
lw $r18, 6($r0)
#jal draw_bug
lw $r18, 7($r0)
#jal draw_bird
# jump back to game loop
j game_loop
# if player position less than (160, 320, 480) mod back to bottom of screen
check_player_pos:
bne $r7, $r14, mod_left
bne $r7, $r15, mod_center
bne $r7, $r16, mod_right
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
bne $r1, $r2, update_time
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
draw_line:
sw $r18, 0($r17)
addi $r17, $r17, -640
blt $r17, $r19, stop_draw_line
j draw_line
stop_draw_line:
jr $ra
#draw_bug:
#stop_draw_bug:
#jr $ra
quit:
addi $r30, $r0, -1
halt
.data
left: .word 0x0000006B
right: .word 0x00000074
a: .char a
s: .char s
d: .char d
color_line: .word 0x00ffffff
color_bug: .word 0x00ffffff
color_bird: .word 0x00ffffff