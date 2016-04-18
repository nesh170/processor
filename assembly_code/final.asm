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
# register 20 holds the ending address for background color for testing (black)
# register 21 holds the index for the for loop
# register 22 holds the color to store (red)
# register 23 holds the offset for drawing bounding box (50)
# register 24 holds the offset for drawing other offset of bounding box (-50)
# register 25 holds whether the player is in position 1, 2 or 3 (left, center, or right)
# register 26 holds the position to check against (1)
# register 27 holds the horizontal offsets to add to redraw the boxes
# register 28 holds the upward offsets to redraw the boxes
nop
lw $r4, 0($r0)
lw $r5, 1($r0)
lw $r7, 12($r0) #upload initial position
addi $r25, $r0, 2
lw $r8, 2($r0)
lw $r9, 3($r0)
lw $r10, 4($r0)
addi $r14, $r0, 160
addi $r15, $r0, 320
addi $r16, $r0, 480
# ending address can't be expressed in 17 bits for addi, use lw
lw $r20, 8($r0)
addi $r21, $r21, 0
addi $r22, $r0, 92
j background_loop # edit to write background
background_loop:
bgt $r21, $r20, exit_background
sw $r22, 0($r21)
addi $r21, $r21, 1
j background_loop
exit_background:
j initialize_screen
initialize_screen:
lw $r18, 13($r0)
lw $r17, 9($r0)
addi $r19, $r0, 480
# draws right bounding box
jal draw_bounding_box
# draw middle bounding box
lw $r17, 10($r0)
addi $r19, $r0, 320
jal draw_bounding_box
# draw left bounding box
lw $r17, 11($r0)
addi $r19, $r0, 160
jal draw_bounding_box
lw $r17, 9($r0)
lw $r18, 5($r0)
addi $r19, $r0, 480
jal draw_line
lw $r17, 10($r0)
# register18 should still have the color of the line, draw middle line
addi $r19, $r0, 320
jal draw_line
# draw left line
lw $r17, 11($r0)
addi $r19, $r0, 160
jal draw_line
j game_loop
game_loop:
addi $r1, $r1, 1 #register 1 holds time
jal check_time
jal increment_player_pos
jal check_player_pos
addi $r6, $r0, 0 # TTY display
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
# if bug is on left line, redraw bounding box and line around that bug on all three
addi $r26, $r0, 1
bne $r25, $r26, update_left
continue_pls_drawing:
# bug on center line
addi $r26, $r0, 2
#bne $r25, $r26, update_center
# bug on right line
addi $r26, $r0, 3
#bne $r25, $r26, update_right
resume_drawing:
lw $r18, 6($r0)
jal draw_bug
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
lw $r7, 11($r0)
jr $r31
mod_center:
lw $r7, 10($r0)
jr $r31
mod_right:
lw $r7, 9($r0)
jr $r31
check_time:
addi $r2, $r0, 200 #add 50000 to register 2 - 50000 is clock freq
bne $r1, $r2, update_time
# r1 = 50000, increment r2 that will be displayed on 7 seg display
jr $r31
update_time:
addi $r3, $r3, 1
add $r1, $r0, $r0
jr $r31
increment_player_pos:
addi $r2, $r0, 1
bne $r1, $r2, update_player_pos
jr $r31
update_player_pos:
addi $r7, $r7, -640
jr $r31
move_left:
addi $r26, $r0, 1
bne $r25, $r26, continue_game_loop
addi $r25, $r25, -1
addi $r7, $r7, -160
j continue_game_loop
move_right:
addi $r26, $r0, 3
bne $r25, $r26, continue_game_loop
addi $r7, $r7, 160
addi $r25, $r25, 1
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
update_left:
addi $r27, $r7, 0
addi $r28, $r27, -12800
lw $r18, 13($r0)
update_pls:
addi $r29, $r28, 8
blt $r29, $r28, stop_drawing_right
sw $r18, 0($r29)
addi $r29, $r29, -1
j update_pls
stop_drawing_right:
# draw on the left side
addi $r29, $r28, -8
bgt $r29, $r28, stop_drawing_left
sw $r18, 0($r29)
addi $r29, $r29, 1
j stop_drawing_right
stop_drawing_left:
lw $r18, 5($r0)
sw $r18, 0($r28) # store white at center point
addi $r28, $r28, 640
bgt $r28, $r27, exit_update
lw $r18, 13($r0)
j update_pls
exit_update:
j continue_pls_drawing
#addi $r27, $r7, 160
#addi $r27, $r7, 320
draw_bug: # contains position of bug
sw $r18, 0($r7)
sw $r18, -640($r7)
sw $r18, -1280($r7)
sw $r18, 1($r7)
sw $r18, -1($r7)
sw $r18, 2($r7)
sw $r18, -2($r7)
sw $r18, 640($r7)
sw $r18, 641($r7)
sw $r18, 642($r7)
sw $r18, 639($r7)
sw $r18, 638($r7)
#stop_draw_bug:
jr $ra
draw_bounding_box:
add $r30, $r31, $r0 # move previous ra to $r30
j pls_draw_bounding_box
pls_draw_bounding_box:
addi $r23, $r17, -8
addi $r24, $r17, 8
jal actual_draw
blt $r17, $r19, stop_drawing
addi $r17, $r17, -640
j pls_draw_bounding_box
stop_drawing:
add $ra,$r0,$r30
jr $ra
actual_draw:
bgt $r23, $r24, exit_actual_draw
sw $r18, 0($r23)
addi $r23, $r23, 1
j actual_draw
exit_actual_draw:
jr $ra
quit:
addi $r30, $r0, -1
halt
.data
left: .word 0x0000006B
right: .word 0x00000074
a: .char a
s: .char s
d: .char d
color_line: .word 0x000000ff
color_bug: .word 0x0000000C
color_bird: .word 0x00ffffff
color_background: .word 0x0004AFFF
right_line_limit: .word 0x0004AF60
middle_line_limit: .word 0x0004AEC0
left_line_limit: .word 0x0004AE20
initial_position: .word 0x0004AEC0
color_bounding_box: .word 0x00000000