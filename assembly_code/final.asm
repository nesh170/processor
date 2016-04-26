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
addi $r29,$r0,12
sw $r29,1202($r0)
add $r29,$r0,$r0
lw $r7, 12($r0) #upload initial position
lw $r27, 12($r0) #upload initial position
addi $r25, $r0, 2
lw $r8, 2($r0)
lw $r9, 3($r0)
lw $r10, 4($r0)
addi $r14, $r0, 160
addi $r15, $r0, 320
addi $r16, $r0, 480
addi $r29, $r0, 10000
sw $r29, 800($r0)
# ending address can't be expressed in 17 bits for addi, use lw
lw $r20, 16($r0) #last index
lw $r21, 8($r0) # starting index
addi $r22, $r0, 65
j background_loop # edit to write background
background_loop:
bgt $r21, $r20, exit_background
sw $r22, 0($r21)
addi $r21, $r21, 1
j background_loop
exit_background:
jal draw_initial_box
nop
nop
jal fix_brown_background #fix the brown spots in the background
addi $r22, $r0, 0
j game_loop

draw_initial_box:
sw $r31,200($r0)
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
lw $r31,200($r0)
#jal draw_bird
jr $ra

game_loop:
addi $r1, $r1, 1 #register 1 holds time
addi $r5, $r5, 1
lw $r30, 500($r0)
addi $r30, $r30, 1
jal check_time
jal increment_player_pos
jal check_player_pos
addi $r6, $r0, 0 # TTY display
lw $r22, 100($r0)
nop
nop
bne $r22, $r6, check_bird_bug # if previous input is same as current one, don't do anything, if it branches, they are equal, no need to update, if it doens't branch, they are not equal, so have to update current input into r22 to relfect on next iteration
#add $r22, $r6,$r0
sw $r6, 100($r0)
lw $r4, 0($r0)
nop
nop
bne $r6, $r4, move_left #z pressed
lw $r4, 1($r0)
nop
nop
bne $r6, $r4, move_right #x pressed
continue_game_loop:
lw $r8, 2($r0)
lw $r9, 3($r0)
lw $r10, 4($r0)
nop
nop
nop
bne $r6, $r8, a_press 
bne $r6, $r9, s_press
bne $r6, $r10, d_press
lw $r8, 19($r0) # key code for up
lw $r9, 20($r0) # key code for down
lw $r10, 21($r0)
nop
nop
bne $r6, $r8, up_press
bne $r6, $r9, down_press
bne $r6, $r10, five_color_change
check_bird_bug: #check for bug intersecting bird
bne $r7, $r11, quit
bne $r7, $r12, quit
bne $r7, $r13, quit
# render screen, update center
addi $r2,$r0, 1500 #render time
bne $r30, $r2, render_loop
sw $r30,500($r0)
j game_loop
render_loop:
addi $r30,$r0,0
sw $r30,500($r0)
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
lw $r18, 1202($r0)
nop
nop
jal fix_brown_background # at every iteration just to be save
nop
nop
jal draw_bug
lw $r18, 15($r0)
# register 11 will be used to draw all of the birds - so store it into memory, and then restore it back, to get the left bird's position back
sw $r11, 400($r0)
jal draw_bird
add $r11, $r12, $r0
jal draw_bird
add $r11, $r13, $r0
jal draw_bird
lw $r11, 400($r0)
#jump back to game loop
j game_loop #ankit no
# if player position less than (160, 320, 480) mod back to bottom of screen
check_player_pos:
bne $r7, $r14, mod_left
bne $r7, $r15, mod_center
bne $r7, $r16, mod_right
jr $r31
mod_left:
lw $r7, 11($r0)
lw $r27, 12($r0) #upload initial position
sw $r31, 300($r0)
jal draw_initial_box
lw $r31, 300($r0)
add $r11, $r0, $r0
add $r12, $r0, $r0
add $r13, $r0, $r0
jr $r31
mod_center:
lw $r7, 10($r0)
lw $r27, 12($r0) #upload initial position
sw $r31, 300($r0)
jal draw_initial_box
lw $r31, 300($r0)
# zero out bird registers, otherwise they will be re-drawn
add $r11, $r0, $r0
add $r12, $r0, $r0
add $r13, $r0, $r0
jr $r31
mod_right:
lw $r7, 9($r0)
lw $r27, 12($r0) #upload initial position
sw $r31, 300($r0)
jal draw_initial_box
lw $r31, 300($r0)
add $r11, $r0, $r0
add $r12, $r0, $r0
add $r13, $r0, $r0
jr $r31
check_time:
addi $r2, $r0, 60000 #add 50000 to register 2 - 50000 is clock freq
addi $r2, $r2, 60000
addi $r2, $r2, 60000
addi $r2, $r2, 60000
bne $r1, $r2, update_time
# r1 = 50000, increment r2 that will be displayed on 7 seg display
jr $r31
update_time:
addi $r3, $r3, 1
add $r1, $r0, $r0
jr $r31
increment_player_pos:
lw $r29, 800($r0)
#addi $r2, $r0, 10000
add $r2, $r0, $r29
nop
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
addi $r11, $r27, -25760
addi $r12, $r27, -51200
addi $r13, $r27, -25440
addi $r11, $r11, -16000
addi $r12, $r12, -16000
addi $r13, $r13, -16000
j check_bird_bug
s_press:
addi $r11, $r27, -25760
addi $r11, $r11, -51200
addi $r12, $r27, -51200 #CHANGE THIS CALL
addi $r13, $r27, -25440
addi $r11, $r11, -16000
addi $r12, $r12, -16000
addi $r13, $r13, -16000
j check_bird_bug
d_press:
addi $r11, $r27, -51360
addi $r12, $r27, -25600
addi $r13, $r27, -25440 # CHANGE THIS CALL
addi $r13, $r13, -51200
addi $r11, $r11, -16000
addi $r12, $r12, -16000
addi $r13, $r13, -16000
j check_bird_bug
up_press:
lw $r29, 800($r0)
addi $r29, $r29, -1000
sw $r29, 800($r0)
j check_bird_bug
down_press:
lw $r29, 800($r0)
addi $r29, $r29, 1000
sw $r29, 800($r0)
j check_bird_bug
five_color_change:
sw $r29, 1201($r0) #temp 29 location
lw $r29, 1202($r0)
addi $r29, $r29, 1
sw $r29, 1202($r0)
lw $r29, 1201($r0)
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
draw_bird: # for now is a red square
# 8 pixels on each side
sw $r18, -3199($r11)
sw $r18, -3198($r11)
sw $r18, -3197($r11)
sw $r18, -3196($r11)
sw $r18, -2561($r11)
sw $r18, -2560($r11)
sw $r18, -2559($r11)
sw $r18, -2558($r11)
sw $r18, -2557($r11)
sw $r18, -2556($r11)
sw $r18, -2555($r11)
sw $r18, -2554($r11)
sw $r18, -1921($r11)
sw $r18, -1920($r11)
sw $r18, -1919($r11)
sw $r18, -1918($r11)
sw $r18, -1917($r11)
sw $r18, -1916($r11)
sw $r18, -1915($r11)
sw $r18, -1914($r11)
sw $r18, -1281($r11)
sw $r18, -1280($r11)
sw $r18, -1279($r11)
sw $r18, -1278($r11)
sw $r18, -1277($r11)
sw $r18, -641($r11)
sw $r18, -640($r11)
sw $r18, -639($r11)
sw $r18, -638($r11)
sw $r18, -637($r11)
sw $r18, -4($r11)
sw $r18, -3($r11)
sw $r18, -2($r11)
sw $r18, -1($r11)
sw $r18, 0($r11)
sw $r18, 1($r11)
sw $r18, 2($r11)
sw $r18, 3($r11)
sw $r18, 4($r11)
sw $r18, 633($r11)
sw $r18, 634($r11)
sw $r18, 635($r11)
sw $r18, 636($r11)
sw $r18, 637($r11)
sw $r18, 638($r11)
sw $r18, 639($r11)
sw $r18, 640($r11)
sw $r18, 641($r11)
sw $r18, 642($r11)
sw $r18, 643($r11)
sw $r18, 644($r11)
sw $r18, 1273($r11)
sw $r18, 1274($r11)
sw $r18, 1275($r11)
sw $r18, 1276($r11)
sw $r18, 1277($r11)
sw $r18, 1278($r11)
sw $r18, 1279($r11)
sw $r18, 1280($r11)
sw $r18, 1281($r11)
sw $r18, 1282($r11)
sw $r18, 1283($r11)
sw $r18, 1284($r11)
sw $r18, 1913($r11)
sw $r18, 1914($r11)
sw $r18, 1915($r11)
sw $r18, 1916($r11)
sw $r18, 1917($r11)
sw $r18, 1918($r11)
sw $r18, 1919($r11)
sw $r18, 1920($r11)
sw $r18, 1921($r11)
sw $r18, 1922($r11)
sw $r18, 1923($r11)
sw $r18, 1924($r11)
sw $r18, 2553($r11)
sw $r18, 2554($r11)
sw $r18, 2555($r11)
sw $r18, 2556($r11)
sw $r18, 2557($r11)
sw $r18, 2558($r11)
sw $r18, 2559($r11)
sw $r18, 2560($r11)
sw $r18, 2561($r11)
sw $r18, 2562($r11)
sw $r18, 2563($r11)
sw $r18, 2564($r11)
sw $r18, 3193($r11)
sw $r18, 3194($r11)
sw $r18, 3195($r11)
sw $r18, 3196($r11)
sw $r18, 3197($r11)
sw $r18, 3198($r11)
sw $r18, 3199($r11)
sw $r18, 3200($r11)
sw $r18, 3201($r11)
sw $r18, 3202($r11)
sw $r18, 3203($r11)
sw $r18, 3204($r11)
sw $r18, 3833($r11)
sw $r18, 3834($r11)
sw $r18, 3836($r11)
sw $r18, 3837($r11)
sw $r18, 3840($r11)
sw $r18, 3841($r11)
jr $ra
#draw_bird_middle:
#sw $r18, 0($r12)
#sw $r18, 1($r12)
#sw $r18, 2($r12)
#sw $r18, 3($r12)
#sw $r18, 4($r12)
#sw $r18, 5($r12)
#sw $r18, 6($r12)
#sw $r18, 7($r12)
#sw $r18, -1($r12)
#sw $r18, -2($r12)
#sw $r18, -3($r12)
#sw $r18, -4($r12)
#sw $r18, -5($r12)
#sw $r18, -6($r12)
#sw $r18, -7($r12)
#r $ra

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

fix_brown_background:
sw $r19, 1501($r0) #register saving, store color
sw $r20, 1502($r0) #store start point
sw $r21, 1503($r0) #store counter
sw $r22, 1504($r0) #store end point
sw $r31, 1505($r0) #store return address
addi $r19,$r0,65 #storing that brown color
addi $r22,$r0,100 #end point is 100, go hundred pixels to the left
addi $r21,$r0,0 #reset register to 0
lw $r20,22($r0) #charging up the first part of the brown
jal loop_background_fix
addi $r21,$r0,0 #reset register to 0
lw $r20,23($r0) #charging up the second part of the brown
jal loop_background_fix
addi $r21,$r0,0 #reset register to 0
lw $r20,24($r0) #charging up the third part of the brown
jal loop_background_fix
lw $r19, 1501($r0) #register restoration
lw $r20, 1502($r0)
lw $r21, 1503($r0)
lw $r22, 1504($r0)
lw $r31, 1505($r0)
jr $r31

loop_background_fix:
add $r21,$r20,$r21 #to get it to the right pixels
sw $r19, -6400($r21)
sw $r19, -5760($r21)
sw $r19, -5120($r21)
sw $r19, -4480($r21)
sw $r19, -3840($r21)
sw $r19, -3200($r21)
sw $r19, -2560($r21)
sw $r19, -1920($r21)
sw $r19, -1280($r21)
sw $r19, -640($r21)
sw $r19, 0($r21)
sw $r19, 640($r21)
sw $r19, 1280($r21)
sw $r19, 1920($r21)
sw $r19, 2560($r21)
sw $r19, 3200($r21)
sw $r19, 3840($r21)
sw $r19, 4480($r21)
sw $r19, 5120($r21)
sw $r19, 5760($r21)
sw $r19, 6400($r21)
sub $r21,$r21,$r20 # to get it to a number between 0 and 100
addi $r21,$r21,1
blt $r21,$r22,loop_background_fix
jr $r31

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
addi $r18, $r0, 14 # color red
lw $r11, 17($r0)
jal draw_sad
addi $r11, $r11, 160
jal draw_sad
lw $r3, 18($r0)
halt
draw_sad:
sw $r18, -5769($r11)
sw $r18, -5768($r11)
sw $r18, -5767($r11)
sw $r18, -5766($r11)
sw $r18, -5765($r11)
sw $r18, -5764($r11)
sw $r18, -5763($r11)
sw $r18, -5758($r11)
sw $r18, -5757($r11)
sw $r18, -5756($r11)
sw $r18, -5755($r11)
sw $r18, -5754($r11)
sw $r18, -5753($r11)
sw $r18, -5752($r11)
sw $r18, -5129($r11)
sw $r18, -5123($r11)
sw $r18, -5118($r11)
sw $r18, -5112($r11)
sw $r18, -4489($r11)
sw $r18, -4487($r11)
sw $r18, -4486($r11)
sw $r18, -4485($r11)
sw $r18, -4483($r11)
sw $r18, -4478($r11)
sw $r18, -4476($r11)
sw $r18, -4475($r11)
sw $r18, -4474($r11)
sw $r18, -4472($r11)
sw $r18, -3849($r11)
sw $r18, -3847($r11)
sw $r18, -3846($r11)
sw $r18, -3845($r11)
sw $r18, -3843($r11)
sw $r18, -3842($r11)
sw $r18, -3841($r11)
sw $r18, -3840($r11)
sw $r18, -3839($r11)
sw $r18, -3838($r11)
sw $r18, -3836($r11)
sw $r18, -3835($r11)
sw $r18, -3834($r11)
sw $r18, -3832($r11)
sw $r18, -3209($r11)
sw $r18, -3207($r11)
sw $r18, -3206($r11)
sw $r18, -3205($r11)
sw $r18, -3203($r11)
sw $r18, -3202($r11)
sw $r18, -3201($r11)
sw $r18, -3200($r11)
sw $r18, -3199($r11)
sw $r18, -3198($r11)
sw $r18, -3196($r11)
sw $r18, -3195($r11)
sw $r18, -3194($r11)
sw $r18, -3192($r11)
sw $r18, -2569($r11)
sw $r18, -2567($r11)
sw $r18, -2566($r11)
sw $r18, -2565($r11)
sw $r18, -2563($r11)
sw $r18, -2558($r11)
sw $r18, -2556($r11)
sw $r18, -2555($r11)
sw $r18, -2554($r11)
sw $r18, -2552($r11)
sw $r18, -1929($r11)
sw $r18, -1923($r11)
sw $r18, -1918($r11)
sw $r18, -1912($r11)
sw $r18, -1289($r11)
sw $r18, -1288($r11)
sw $r18, -1287($r11)
sw $r18, -1286($r11)
sw $r18, -1285($r11)
sw $r18, -1284($r11)
sw $r18, -1283($r11)
sw $r18, -1278($r11)
sw $r18, -1277($r11)
sw $r18, -1276($r11)
sw $r18, -1275($r11)
sw $r18, -1274($r11)
sw $r18, -1273($r11)
sw $r18, -1272($r11)
sw $r18, 1271($r11)
sw $r18, 1272($r11)
sw $r18, 1273($r11)
sw $r18, 1274($r11)
sw $r18, 1275($r11)
sw $r18, 1276($r11)
sw $r18, 1277($r11)
sw $r18, 1278($r11)
sw $r18, 1279($r11)
sw $r18, 1280($r11)
sw $r18, 1281($r11)
sw $r18, 1282($r11)
sw $r18, 1283($r11)
sw $r18, 1284($r11)
sw $r18, 1285($r11)
sw $r18, 1286($r11)
sw $r18, 1287($r11)
sw $r18, 1288($r11)
sw $r18, 1911($r11)
sw $r18, 1912($r11)
sw $r18, 1913($r11)
sw $r18, 1914($r11)
sw $r18, 1915($r11)
sw $r18, 1916($r11)
sw $r18, 1917($r11)
sw $r18, 1918($r11)
sw $r18, 1919($r11)
sw $r18, 1920($r11)
sw $r18, 1921($r11)
sw $r18, 1922($r11)
sw $r18, 1923($r11)
sw $r18, 1924($r11)
sw $r18, 1925($r11)
sw $r18, 1926($r11)
sw $r18, 1927($r11)
sw $r18, 1928($r11)
sw $r18, 2551($r11)
sw $r18, 2552($r11)
sw $r18, 2553($r11)
sw $r18, 2554($r11)
sw $r18, 2555($r11)
sw $r18, 2556($r11)
sw $r18, 2557($r11)
sw $r18, 2558($r11)
sw $r18, 2559($r11)
sw $r18, 2560($r11)
sw $r18, 2561($r11)
sw $r18, 2562($r11)
sw $r18, 2563($r11)
sw $r18, 2564($r11)
sw $r18, 2565($r11)
sw $r18, 2566($r11)
sw $r18, 2567($r11)
sw $r18, 2568($r11)
sw $r18, 3191($r11)
sw $r18, 3192($r11)
sw $r18, 3193($r11)
sw $r18, 3194($r11)
sw $r18, 3205($r11)
sw $r18, 3206($r11)
sw $r18, 3207($r11)
sw $r18, 3208($r11)
sw $r18, 3831($r11)
sw $r18, 3832($r11)
sw $r18, 3833($r11)
sw $r18, 3834($r11)
sw $r18, 3845($r11)
sw $r18, 3846($r11)
sw $r18, 3847($r11)
sw $r18, 3848($r11)
sw $r18, 4471($r11)
sw $r18, 4472($r11)
sw $r18, 4473($r11)
sw $r18, 4474($r11)
sw $r18, 4485($r11)
sw $r18, 4486($r11)
sw $r18, 4487($r11)
sw $r18, 4488($r11)
sw $r18, 5111($r11)
sw $r18, 5112($r11)
sw $r18, 5113($r11)
sw $r18, 5114($r11)
sw $r18, 5125($r11)
sw $r18, 5126($r11)
sw $r18, 5127($r11)
sw $r18, 5128($r11)
jr $ra
.data
left: .word 0x0000006B
right: .word 0x00000074
a: .word 0x0000001C
s: .word 0x0000001B
d: .word 0x00000023
color_line: .word 0x000000ff
color_bug: .word 0x0000000C
color_bird: .word 0x00ffffff
color_background_limit: .word 0x000258AF
right_line_limit: .word 0x0004AF60
middle_line_limit: .word 0x0004AEC0
left_line_limit: .word 0x0004AE20
initial_position: .word 0x0004AEC0
color_bounding_box: .word 0x00000000
limit_drawing: .word 0x00047CC0
color_bird: .word 0x0000000E
background_last: .word 0x00038531
coordinate_quit: .word 0x0002EEF0
fail: .word 0x0000FA17
speed_up: .word 0x00000075
slow_down: .word 0x00000072
five_press: .word 0x00000073
brown_part_one: .word 0x0004970A
brown_part_two: .word 0x000497B4
brown_part_three: .word 0x000498FE