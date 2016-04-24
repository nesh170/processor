.text
main:
#register 1 holds time in terms of clock frequency
# register 2 holds 50000
# register 3 holds time to be displayed
# register 4 holds the potential keyboard inputs to check against
# regster 5 holds the time to increment player
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
# register 22 holds the color to store (blue) for initialization, and for white screen at end, will also be used for storing previous keyboard input
# register 23 holds the offset for drawing bounding box (50)
# register 24 holds the offset for drawing other offset of bounding box (-50)
# register 25 holds whether the player is in position 1, 2 or 3 (left, center, or right)
# register 26 holds the position to check against (1)
# register 27 holds the position of the bug relative to the center
# register 28 holds the coordinate 20 pixels north of register 27
# register 30 holds the coordinates 20 pixels south of register 27
nop
lw $r7, 12($r0) #upload initial position
lw $r27, 12($r0) #upload initial position
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
j draw_initial_box
draw_initial_box:
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
lw $r18, 6($r0)
j draw_bug_start
draw_bug_start:
jal draw_bug
lw $r18, 7($r0)
#jal draw_bird
addi $r22, $r0, 0
j game_loop
game_loop:
addi $r1, $r1, 1 #register 1 holds time
addi $r5, $r5, 1
jal check_time
jal increment_player_pos
jal check_player_pos
addi $r6, $r0, 0 # TTY display
bne $r22, $r6, check_bird_bug # if previous input is same as current one, don't do anything, if it branches, they are equal, no need to update, if it doens't branch, they are not equal, so have to update current input into r22 to relfect on next iteration
add $r22, $r6,$r0
lw $r4, 0($r0)
nop
nop
bne $r6, $r4, move_left #z pressed
lw $r4, 1($r0)
nop
nop
bne $r6, $r4, move_right #x pressed
continue_game_loop:
bne $r6, $r8, a_press 
bne $r6, $r9, s_press
bne $r6, $r10, d_press
check_bird_bug: #check for bug intersecting bird
bne $r7, $r11, quit
bne $r7, $r12, quit
bne $r7, $r13, quit
# render screen, update center
addi $r28, $r27, -12800
addi $r29, $r27, 12800
jal update_bounding_box
# update left bounding box
addi $r27, $r27, -160
addi $r28, $r27, -12800
addi $r29, $r27, 12800
jal update_bounding_box
addi $r27, $r27, 160 # add offset back
# update rounding box
addi $r27, $r27, 160
addi $r28, $r27, -12800
addi $r29, $r27, 12800
jal update_bounding_box
addi $r27, $r27, -160
lw $r18, 6($r0)
jal draw_bug
lw $r18, 15($r0)
jal draw_bird_left
jal draw_bird_middle
jal draw_bird_right
#jump back to game loop
jal draw_initial_box
j game_loop
# if player position less than (160, 320, 480) mod back to bottom of screen
check_player_pos:
bne $r7, $r14, mod_left
bne $r7, $r15, mod_center
bne $r7, $r16, mod_right
jr $r31
mod_left:
lw $r7, 11($r0)
lw $r27, 12($r0) #upload initial position
jr $r31
mod_center:
lw $r7, 10($r0)
lw $r27, 12($r0) #upload initial position
jr $r31
mod_right:
lw $r7, 9($r0)
lw $r27, 12($r0) #upload initial position
jr $r31
check_time:
addi $r2, $r0, 10000 #add 50000 to register 2 - 50000 is clock freq
bne $r1, $r2, update_time
# r1 = 50000, increment r2 that will be displayed on 7 seg display
jr $r31
update_time:
addi $r3, $r3, 1
add $r1, $r0, $r0
jr $r31
increment_player_pos:
addi $r2, $r0, 1000
bne $r5, $r2, update_player_pos
jr $r31
update_player_pos:
addi $r7, $r7, -640
addi $r27, $r27, -640
add $r5, $r0, $r0
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
addi $r11, $r27, -19360
addi $r12, $r27, -10880
addi $r13, $r27, -9440
j check_bird_bug
s_press:
addi $r12, $r7, -9600 #CHANGE THIS CALL
j check_bird_bug
d_press:
addi $r13, $r7, -9600 # CHANGE THIS CALL
j check_bird_bug
draw_line:
sw $r18, 0($r17)
addi $r17, $r17, -640
blt $r17, $r19, stop_draw_line
j draw_line
stop_draw_line:
jr $ra
draw_bug: # contains position of bug
sw $r18, -3847($r7)
sw $r18, -3833($r7)
sw $r18, -3207($r7)
sw $r18, -3206($r7)
sw $r18, -2567($r7)
sw $r18, -2566($r7)
sw $r18, -2565($r7)
sw $r18, -2562($r7)
sw $r18, -2561($r7)
sw $r18, -2560($r7)
sw $r18, -2559($r7)
sw $r18, -2558($r7)
sw $r18, -2555($r7)
sw $r18, -2554($r7)
sw $r18, -2553($r7)
sw $r18, -1927($r7)
sw $r18, -1926($r7)
sw $r18, -1925($r7)
sw $r18, -1924($r7)
sw $r18, -1923($r7)
sw $r18, -1922($r7)
sw $r18, -1921($r7)
sw $r18, -1920($r7)
sw $r18, -1919($r7)
sw $r18, -1918($r7)
sw $r18, -1917($r7)
sw $r18, -1916($r7)
sw $r18, -1915($r7)
sw $r18, -1914($r7)
sw $r18, -1913($r7)
sw $r18, -1282($r7)
sw $r18, -1281($r7)
sw $r18, -1280($r7)
sw $r18, -1279($r7)
sw $r18, -1278($r7)
sw $r18, -642($r7)
sw $r18, -641($r7)
sw $r18, -640($r7)
sw $r18, -639($r7)
sw $r18, -638($r7)
sw $r18, -2($r7)
sw $r18, -1($r7)
sw $r18, 0($r7)
sw $r18, 1($r7)
sw $r18, 2($r7)
sw $r18, 638($r7)
sw $r18, 639($r7)
sw $r18, 640($r7)
sw $r18, 641($r7)
sw $r18, 642($r7)
sw $r18, 1278($r7)
sw $r18, 1279($r7)
sw $r18, 1280($r7)
sw $r18, 1281($r7)
sw $r18, 1282($r7)
sw $r18, 1913($r7)
sw $r18, 1914($r7)
sw $r18, 1915($r7)
sw $r18, 1916($r7)
sw $r18, 1917($r7)
sw $r18, 1918($r7)
sw $r18, 1919($r7)
sw $r18, 1920($r7)
sw $r18, 1921($r7)
sw $r18, 1922($r7)
sw $r18, 1923($r7)
sw $r18, 1924($r7)
sw $r18, 1925($r7)
sw $r18, 1926($r7)
sw $r18, 1927($r7)
sw $r18, 2553($r7)
sw $r18, 2554($r7)
sw $r18, 2555($r7)
sw $r18, 2556($r7)
sw $r18, 2557($r7)
sw $r18, 2558($r7)
sw $r18, 2559($r7)
sw $r18, 2560($r7)
sw $r18, 2561($r7)
sw $r18, 2562($r7)
sw $r18, 2563($r7)
sw $r18, 2564($r7)
sw $r18, 2565($r7)
sw $r18, 2566($r7)
sw $r18, 2567($r7)
sw $r18, 3193($r7)
sw $r18, 3194($r7)
sw $r18, 3195($r7)
sw $r18, 3198($r7)
sw $r18, 3199($r7)
sw $r18, 3200($r7)
sw $r18, 3201($r7)
sw $r18, 3202($r7)
sw $r18, 3205($r7)
sw $r18, 3206($r7)
sw $r18, 3207($r7)
#stop_draw_bug:
jr $ra
draw_bird_left: # for now is a red square
# 8 pixels on each side
sw $r18, 0($r11)
sw $r18, 1($r11)
sw $r18, 2($r11)
sw $r18, 3($r11)
sw $r18, 4($r11)
sw $r18, 5($r11)
sw $r18, 6($r11)
sw $r18, 7($r11)
sw $r18, -1($r11)
sw $r18, -2($r11)
sw $r18, -3($r11)
sw $r18, -4($r11)
sw $r18, -5($r11)
sw $r18, -6($r11)
sw $r18, -7($r11)
jr $ra
draw_bird_middle:
sw $r18, 0($r12)
sw $r18, 1($r12)
sw $r18, 2($r12)
sw $r18, 3($r12)
sw $r18, 4($r12)
sw $r18, 5($r12)
sw $r18, 6($r12)
sw $r18, 7($r12)
sw $r18, -1($r12)
sw $r18, -2($r12)
sw $r18, -3($r12)
sw $r18, -4($r12)
sw $r18, -5($r12)
sw $r18, -6($r12)
sw $r18, -7($r12)
jr $ra
draw_bird_right:
sw $r18, 0($r13)
sw $r18, 1($r13)
sw $r18, 2($r13)
sw $r18, 3($r13)
sw $r18, 4($r13)
sw $r18, 5($r13)
sw $r18, 6($r13)
sw $r18, 7($r13)
sw $r18, -1($r13)
sw $r18, -2($r13)
sw $r18, -3($r13)
sw $r18, -4($r13)
sw $r18, -5($r13)
sw $r18, -6($r13)
sw $r18, -7($r13)
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

update_bounding_box:
bgt $r28, $r29, finish_update
j inner_bounding_box_loop



inner_bounding_box_loop:
lw $r18, 5($r0)
sw $r18, 0($r28)
lw $r18, 13($r0) # load color
sw $r18, 1($r28)
sw $r18, 2($r28)
sw $r18, 3($r28)
sw $r18, 4($r28)
sw $r18, 5($r28)
sw $r18, 6($r28)
sw $r18, 7($r28)
sw $r18, 8($r28)
sw $r18, -1($r28)
sw $r18, -2($r28)
sw $r18, -3($r28)
sw $r18, -4($r28)
sw $r18, -5($r28)
sw $r18, -6($r28)
sw $r18, -7($r28)
sw $r18, -8($r28)
addi $r28, $r28, 640
j update_bounding_box

finish_update:
jr $ra
quit:
addi $r30, $r0, -1
# refresh background
lw $r20, 8($r0) # load last pixel index on screen
add $r21, $r0, $r0 # index
addi $r22, $r0, 255 # reset r22 to white color
j update_background
update_background:
bgt $r21, $r20, exit_update_background
sw $r22, 0($r21)
addi $r21, $r21, 1
j update_background
exit_update_background:
halt
.data
left: .word 0x0000006B
right: .word 0x00000074
a: .word 0x0000001C
s: .word 0x0000001B
d: .word 0x00000023
color_line: .word 0x000000ff
color_bug: .word 0x0000000C
color_bird: .word 0x00ffffff
color_background_limit: .word 0x0004AFFF
right_line_limit: .word 0x0004AF60
middle_line_limit: .word 0x0004AEC0
left_line_limit: .word 0x0004AE20
initial_position: .word 0x0004AEC0
color_bounding_box: .word 0x00000000
limit_drawing: .word 0x00047CC0
color_bird: .word 0x0000000E