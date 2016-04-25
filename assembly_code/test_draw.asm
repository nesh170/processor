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
jal draw_initial_box
halt
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
lw $r18, 7($r0)
lw $r31,200($r0)
#jal draw_bird
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
draw_line:
sw $r18, 0($r17)
addi $r17, $r17, -640
blt $r17, $r19, stop_draw_line
j draw_line
stop_draw_line:
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
color_background_limit: .word 0x0004AFFF
right_line_limit: .word 0x00049660
middle_line_limit: .word 0x000495C0
left_line_limit: .word 0x00049520
initial_position: .word 0x000495C0
color_bounding_box: .word 0x00000000
limit_drawing: .word 0x00047CC0
color_bird: .word 0x0000000E