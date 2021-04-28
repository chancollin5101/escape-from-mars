#####################################################################
#
# CSCB58 Winter 2021 Assembly Final Project
# University of Toronto, Scarborough
# 
# Student: Collin Chan, Student Number: 1006200889, UTorID: chancol7
# 
# Bitmap Display Configuration:
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestoneshave beenreached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4 (choose the one the applies)
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 1. Smooth Graphics
# 2. Increasing Difficulty as the game progresses
# 3. A Scoring System; 10 points per wave and -5 points per collision
#
# Link to video demonstration for final submission:
# - https://youtu.be/SOpnTmNc1zI
#
# Are you OK with us sharing the video with people outside course staff?
# - yes
#
# Any additional information that the TA needs to know:
# - forgot the mention in the video but you can press p to restart
#   and q to quit the game when you are at the game over screen
#
#####################################################################
.data	
end_cond: .word 0
player_x: .word 5
player_y: .word 15
player_health: .word 100
player_hp_bar_x: .word 15
player_hp_bar_y: .word 29
screen_width: .word 32
score: .word 0
enemy_res: .word 1
num_enemy: .word 3
enemy_x: .word 30
enemy_y: .word 15 # doesn't matter; cuz it's randomized anyways
enemy_arr_x: .word 30, 30, 30, 30, 30, 30, 30, 30, 30, 30
enemy_arr_y: .word 15, 14, 15, 14, 15, 15, 16, 16, 15, 15
enemy_speed: .word 1
enemy_pause: .word 120
game_speed: .word 20
num_collision: .word 0
collision_pause: .word 300
input: .word 115 # doesn't matter; cuz it'll affect when an input is entered
# input variable - ASCII code
# 119 - moving up - w
# 115 - moving down - s
# 97 - moving left - a
# 100 - moving right - d
# 112 - restart - p
C: .byte 0 -1 -1 -1 0  -1 0 0 0 0  -1 0 0 0 0  -1 0 0 0 0  0 -1 -1 -1 0
E: .byte -1 -1 -1 -1 -1  -1 0 0 0 0  -1 -1 -1 0 0  -1 0 0 0 0  -1 -1 -1 -1 -1
G: .byte 0 -1 -1 -1 0  -1 0 0 0 0  -1 0 0 -1 -1  -1 0 0 0 -1  0 -1 -1 -1 0
H: .byte -1 0 0 0 -1  -1 0 0 0 -1  -1 -1 -1 -1 -1  -1 0 0 0 -1  -1 0 0 0 -1
L: .byte -1 0 0 0 0  -1 0 0 0 0  -1 0 0 0 0  -1 0 0 0 0  -1 -1 -1 -1 -1
P: .byte -1 -1 -1 -1 0  -1 0 0 0 -1  -1 -1 -1 -1 -1  -1 0 0 0 0  -1 0 0 0 0
S: .byte -1 -1 -1 -1 -1  -1 0 0 0 0  -1 -1 -1 -1 -1  0 0 0 0 -1  -1 -1 -1 -1 -1
V: .byte -1 0 0 0 -1  -1 0 0 0 -1  0 -1 0 -1 0  0 -1 0 -1 0  0 0 -1 0 0

int_0: .byte 0 -1 -1 -1 0  -1 0 0 -1 -1  -1 0 -1 0 -1  -1 -1 0 0 -1  0 -1 -1 -1 0
int_1: .byte 0 0 -1 0 0  0 -1 -1 0 0  0 0 -1 0 0  0 0 -1 0 0  0 -1 -1 -1 0
int_2: .byte -1 -1 -1 -1 -1  0 0 0 0 -1  -1 -1 -1 -1 -1  -1 0 0 0 0  -1 -1 -1 -1 -1
int_3: .byte -1 -1 -1 -1 0  0 0 0 0 -1  0 0 -1 -1 0  0 0 0 0 -1  -1 -1 -1 -1 0
int_4: .byte -1 0 0 0 -1  -1 0 0 0 -1  -1 -1 -1 -1 -1  0 0 0 0 -1  0 0 0 0 -1
int_5: .byte -1 -1 -1 -1 -1  -1 0 0 0 0  -1 -1 -1 -1 0  0 0 0 0 -1  -1 -1 -1 -1 0
int_6: .byte 0 -1 -1 -1 0  -1 0 0 0 0  -1 -1 -1 -1 0  -1 0 0 0 -1  0 -1 -1 -1 0
int_7: .byte -1 -1 -1 -1 -1  0 0 0 0 -1  0 0 0 -1 0  0 0 -1 0 0  0 -1 0 0 0
int_8: .byte 0 -1 -1 -1 0  -1 0 0 0 -1  0 -1 -1 -1 0  -1 0 0 0 -1  0 -1 -1 -1 0
int_9: .byte 0 -1 -1 -1 0  -1 0 0 0 -1  0 -1 -1 -1 -1  0 0 0 0 -1  0 -1 -1 -1 0
red: .word 0xff0000
grey: .word 0x9F9F9F
blue: .word 0x0080ff
d_blue: .word 0x0050A0
black: .word 0x000000
white: .word 0xFFFFFF
green: .word 0x00FF00

.eqv	BASE_ADDRESS	0x10008000
.text globl main

main:	
######################################################
# fill Screen to Black and Red, for reset
	lw $a0, screen_width
	lw $a1, black
	mul $a2, $a0, $a0 #total number of pixels on screen
	mul $a2, $a2, 4 #align addresses
	add $a2, $a2, $gp #add base of gp
	add $a0, $gp, $zero #loop counter
fill_black:
	beq $a0, $a2, fill_red
	sw $a1, 0($a0) #store color
	addiu $a0, $a0, 4 #increment counter
	j fill_black
fill_red:
	# fill the left with red to signify the sun
	lw $a0, screen_width
	lw $a1, red
	mul $a2, $a0, $a0 # end of 3rd last row index
	mul $a2, $a2, 4 # align addresses
	add $a2, $a2, $gp # add base of gp
	add $a0, $gp, $zero # loop counter
fill_red_cont:	
	beq $a0, $a2, init
	add $t1, $a2, -512
	beq $a0, $t1, fill_hp
	sw $a1, 0($a0)
	addiu $a0, $a0, 128
	j fill_red_cont
	
######################################################################	
	# draw full health bar
fill_hp:
	add $a0, $a0, 4
	# draw HP: first row of HP:
	lw $a1, white
	jal draw_pixel
	add $a0, $a0, 8
	jal draw_pixel
	add $a0, $a0, 8
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	add $a0, $a0, 8
	jal draw_pixel
	add $a0, $a0, 12
	# draw outline of health bar
	lw $a1, grey
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	li $a0, 1
	li $a1, 29
	jal coor_to_addr
	move $a0, $v0
	
	# second row of HP:
	lw $a1, white
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	add $a0, $a0, 8
	jal draw_pixel
	add $a0, $a0, 8
	jal draw_pixel
	add $a0, $a0, 16
	lw $a1, grey
	jal draw_pixel
	lw $a1, green
	add $a0, $a0, 4
	# draw 4 bars of health
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	lw $a1, grey
	add $a0, $a0, 4
	jal draw_pixel
	li $a0, 1
	li $a1, 30
	jal coor_to_addr
	move $a0, $v0
	
	# third row of HP: 
	lw $a1, white
	jal draw_pixel
	add $a0, $a0, 8
	jal draw_pixel
	add $a0, $a0, 8
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	add $a0, $a0, 8
	jal draw_pixel
	add $a0, $a0, 12
	# draw outline of health bar
	lw $a1, grey
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	add $a0, $a0, 4
	jal draw_pixel
	li $a0, 1
	li $a1, 31
	jal coor_to_addr
	move $a0, $v0
	
	# fourth row of HP: 
	lw $a1, white
	jal draw_pixel
	add $a0, $a0, 8
	jal draw_pixel
	add $a0, $a0, 8
	jal draw_pixel

	j init
######################################################################	
init:	# initialize all local variables 
	sw, $zero, end_cond
	li $t0, 5
	sw $t0, player_x
	li $t0 15
	sw $t0, player_y
	sw $t0, player_hp_bar_x
	li $t0, 100
	sw $t0, player_health
	li $t0, 32 
	sw $t0, screen_width
	sw $zero, score
	li $t0, 30
	sw $t0, enemy_x
	sw $zero, enemy_y
	li $t0, 1
	sw $t0, enemy_speed
	li $t0, 500
	sw $t0, enemy_pause
	li $t0, 40
	sw $t0, game_speed
	li $t0, 115
	sw $t0, input
	sw $zero, num_collision
	li $t0, 3
	sw $t0, num_enemy
	
clear_reg:
	# clear all registers to avoid any unexpected behaviour
	li $v0, 0
	li $a0, 0
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0		

######################################################################	
	# draw inital player
	lw $a0, player_x # load player's x coordinate
	lw $a1, player_y # load player's y coordinate
	jal coor_to_addr
	move $a0, $v0
	lw $a1, blue # drawing head
	jal draw_pixel
	
	add $a0, $a0, -4
	jal draw_pixel # drawing body
	
	add $a0, $a0, -4
	lw $a1, red
	jal draw_pixel # drawing tail
	
######################################################################	
	
	li $t2, 0 # enemy array index
	lw $t3, num_enemy
	mul $t3, $t3, 4
spawn_enemies:
	beq $t2, $t3, game_loop # if index is 2 
	
	# rng - generate random number within (0-32)
	li $v0, 42 
	li $a0, 0
	li $a1, 26
	syscall
	add $a0, $a0, 2 # randomly generate to 26 and then add 2 to it all the time
	# so a 0 is never generated and the enemies will always be within the bounds
	
	sw $a0, enemy_arr_y($t2) # storing y coordinate of enemy to new random number
	move $a1, $a0
	lw $a0, enemy_arr_x($t2) # getting x coordinate of enemy
	jal coor_to_addr
	move $a0, $v0
	lw $a1, grey
	jal draw_pixel # drawing OO
		      #		 XO
	
	addi $a0, $a0, -128
	lw $a1, white
	jal draw_pixel # drawing XO
		      # 	 XO
		      
	addi $a0, $a0, 4
	lw $a1, grey
	jal draw_pixel # drawing XX
		      #		 XO

	addi $a0, $a0, 128
	jal draw_pixel # drawing XX
		      # 	 XX
	addi $t2, $t2, 4 # increment index
	
	j spawn_enemies
	
######################################################################	

game_loop:
	lw $t1, end_cond
	lw $t2, player_health
	ble $t2, 0, end_game
	beq $t1, 1, end_game
	
	# increase # of enemies if wave 10 is reached
	lw $t0, enemy_res
	lw $t1, num_enemy
	mul $t1, $t1, 10
	bge $t0, $t1, add_difficulty
	j cont_game_loop
	
# logic for adding difficulty
add_difficulty:
	lw $t1, num_enemy
	beq $t1, 10, add_speed
	add $t1, $t1, 1
	sw $t1, num_enemy
	j add_diff_end
	
# increment speed only when 10 enemies are spawned at the same time at the current level 
add_speed:
	lw $t1, enemy_speed
	add $t1, $t1, 1
	sw $t1, enemy_speed

add_diff_end:
	lw $t1, enemy_res
	lw $t2, score
	addi $t2, $t2, 10
	sw $t2, score
	sw $zero, enemy_res

cont_game_loop:	
	# get user input
	lw $a0, game_speed # sleep for a brief moment
	jal pause
	# get the input from the keyboard
	li $t0, 0xffff0000
	lw $t1, 0($t0)
	li $s2, 0
	lw $s3, num_enemy
	mul $s3, $s3, 4
	beq $t1, 0, update_enemy # if no input is detected, skip to update enemy positions
	
	lw $a0, 4($t0) # save user's new input
	sw $a0, input
	beq $a0, 112, restart # if user entered p, then restart entire game

	lw $a1, player_x # load player's current x for func call
	lw $a2, player_y # load player's current y for func call
	jal check_bounds
	bne $v0, 1, update_enemy # if player does not need to move, skip to update enemy positions 
	
	# erase player at current position
	lw $a0, player_x # load player's current x for func call
	lw $a1, player_y # load player's current y for func call
	jal coor_to_addr
	move $a0, $v0
	lw $a1, black # erase head
	jal draw_pixel
	
	add $a0, $a0, -4
	jal draw_pixel # erase body

	add $a0, $a0, -4
	jal draw_pixel # erase tail
	
update_player:
	lw $t1, player_x # save player's current x
	lw $t2, player_y # save player's current y
	lw $t3, input # get new dir
	beq $t3, 119, move_up # move user up
	beq $t3, 115, move_down # move user down
	beq $t3, 97, move_left # move user left
	beq $t3, 100, move_right # move user right
	
move_up:
	addi $t2, $t2, -2
	sw $t2, player_y
	j redraw_player

move_down:
	addi $t2, $t2, 2
	sw $t2, player_y
	j redraw_player

move_left:
	addi $t1, $t1, -2
	sw $t1, player_x
	j redraw_player

move_right:
	addi $t1, $t1, 2
	sw $t1, player_x
	j redraw_player
	
redraw_player:
	lw $a0, player_x
	lw $a1, player_y
	jal coor_to_addr
	move $a0, $v0
	lw $a1, blue # drawing head
	jal draw_pixel
	
	add $a0, $a0, -4
	jal draw_pixel # drawing body
	
	add $a0, $a0, -4
	lw $a1, red
	jal draw_pixel # drawing tail
	li $s2, 0 # enemy arr index

update_enemy: 
	# erasing enemy at current position
	beq $s2, $s3, game_loop
	
	lw $a0, enemy_arr_x($s2)
	lw $a1, enemy_arr_y($s2)
	jal coor_to_addr
	move $a0, $v0
	lw $a1, black
	jal draw_pixel  # erasing XX
		       # 	  OX
	
	addi $a0, $a0, -128
	jal draw_pixel # erasing OX
		      #		 OX
	
	addi $a0, $a0, 4
	jal draw_pixel # erasing OO
		       #	 OX
	
	addi $a0, $a0, 128
	jal draw_pixel # erasing OO
		      # 	 OO
		      
	lw $t3, enemy_speed
	lw $t4, grey
	lw $a0, enemy_arr_x($s2)
	lw $a1, enemy_arr_y($s2)
	sub $a0, $a0, $t3
	jal check_enemy_collision

	beq $v0, 1, animate_player_collision # if check_enemy_collision returned a 1, then there was a collision and it will animate now
	bgt $a0, 0, update_enemy_cont # if enemy is still within the screen, then continue

respawn:
	# rng - generate random number within (0-32)
	li $v0, 42 
	li $a0, 0
	li $a1, 26
	syscall
	addi $a0, $a0, 2
	
	sw $a0, enemy_arr_y($s2) # store random number as enemy's y
	
	li $a0, 30 # reset enemy's x back to the right of the screen
	lw $t0, enemy_res
	add $t0, $t0, 1
	sw $t0, enemy_res
	
	j update_enemy_cont # continue

animate_player_collision: 
	# update # of collisions from the player
	lw $t0, num_collision
	add $t0, $t0, 1
	sw $t0, num_collision

	lw $a0, player_x
	addi $a0, $a0, -2
	lw $a1, player_y
	jal coor_to_addr
	move $a0, $v0
	lw $a1, white 
	jal draw_pixel # draw smoke
	
	move $t1, $a0 # save address of tail
	lw $a0, collision_pause # get collision pause duration
	jal pause # pause the ship for a sec
	
	move $a0, $t1 # get address of tail back 
	lw $a1, red
	jal draw_pixel # redraw it red
	
	lw $t2, player_health # get health of player
	addi $t2, $t2, -25
	sw $t2, player_health # update health of player
	
	# update health bar on the bottom
	lw $a0, player_hp_bar_x
	lw $a1, player_hp_bar_y
	jal coor_to_addr
	move $a0, $v0
	lw $a1, black
	jal draw_pixel
	lw $t0, player_hp_bar_x
	beq $t0, 13, change_hp_red

animate_cont:
	add $t0, $t0, -1
	sw $t0, player_hp_bar_x 	
	j respawn 

# update health bar to red when only one pixel is left				
change_hp_red:
	li $a0, 12
	lw $a1, player_hp_bar_y
	jal coor_to_addr
	move $a0, $v0
	lw $a1, red
	jal draw_pixel
	j animate_cont

update_enemy_cont:
	# redrawing enemy at new postion 
	sw $a0, enemy_arr_x($s2)
	lw $a1, enemy_arr_y($s2)
	jal coor_to_addr
	move $a0, $v0
	lw $a1, grey
	jal draw_pixel # redrawing OO
		      #		   XO
	
	addi $a0, $a0, -128
	lw $a1, white
	jal draw_pixel # redrawing XO
		      #		   XO
	
	addi $a0, $a0, 4
	lw $a1, grey
	jal draw_pixel # redrawing XX
		      #		   XO
	
	addi $a0, $a0, 128
	jal draw_pixel # redrawing XX
		      #		   XX
	addi $s2, $s2, 4
	j update_enemy
	
	#j game_loop

###########################################################
#	$a0 - enemy's x-coordinate
#	$a1 - enemy's y-coordinate 
###########################################################
#	$v0 - return 1 for there's a collision; 0 for none
###########################################################
check_enemy_collision: 
	lw $t3, player_x
	lw $t4, player_y
	beq $a0, $t3, check_y_collision
	addi $t3, $t3, -1
	beq $a0, $t3, check_y_collision
	j return_no_collision

check_y_collision:
	beq $a1, $t4, return_collision
	addi $a1, $a1, -1
	beq $a1, $t4, return_collision
	j return_no_collision

return_collision:
	li $v0, 1
	jr $ra

return_no_collision:
	li $v0, 0
	jr $ra
####################################################
# $a0 - new input
# $a1 - player's current x coordinate
# $a2 - player's current y coordinate
####################################################
# $v0 - return 1 for valid; 0 for invalid
####################################################
check_bounds:
	beq $a0, 119, check_up # going up
	beq $a0, 115, check_down # going down
	beq $a0, 97, check_left # going left
	beq $a0, 100, check_right # going right
	
check_up:
	addi $t0, $a2, -2
	bgez $t0, valid
	j not_valid

check_down:
	addi $t0, $a2, 2
	blt $t0, 28, valid
	j not_valid

check_left:
	addi $t0, $a1, -4
	bgez $t0, valid
	j not_valid

check_right:
	addi $t0, $a1, 2
	blt $t0, 32, valid
	j not_valid

valid:	li $v0, 1
	jr $ra
	
not_valid:
	li $v0, 0
	jr $ra

##################################################################
# coor_to_addr Function
# $a0 -> x coordinate
# $a1 -> y coordinate	
##################################################################
# returns $v0 -> the address of the coordinates for bitmap display
##################################################################
coor_to_addr:
	lw $v0, screen_width 	#Store screen width into $v0
	mul $v0, $v0, $a1	#multiply by y position
	add $v0, $v0, $a0	#add the x position
	mul $v0, $v0, 4		#multiply by 4
	add $v0, $v0, $gp	#add global pointer from bitmap display
	jr $ra			# return $v0

##################################################################
# draw_pixel Function
# $a0 -> Address position to draw at
# $a1 -> Color the pixel should be drawn
##################################################################
# no return value
##################################################################
draw_pixel:
	sw $a1, 0($a0) 	#fill the coordinate with specified colors
	jr $ra		#return

##################################################################
# draw_int Function
# $a0 -> Address of top left of 5x5
# $a1 -> int
##################################################################
# no return value
##################################################################
draw_int:
	# check to see which char data is needed
	beq $a1, 0, set_0
	beq $a1, 1, set_1
	beq $a1, 2, set_2
	beq $a1, 3, set_3
	beq $a1, 4, set_4
	beq $a1, 5, set_5
	beq $a1, 6, set_6
	beq $a1, 7, set_7
	beq $a1, 8, set_8
	beq $a1, 9, set_9

# set the corresponding char data in bytes	
set_0:	la $t1, int_0
	j draw_char_next

set_1:	la $t1, int_1
	j draw_char_next

set_2:	la $t1, int_2
	j draw_char_next

set_3:	la $t1, int_3
	j draw_char_next

set_4:	la $t1, int_4
	j draw_char_next

set_5:	la $t1, int_5
	j draw_char_next

set_6:	la $t1, int_6
	j draw_char_next
	
set_7:	la $t1, int_7
	j draw_char_next
	
set_8:	la $t1, int_8
	j draw_char_next			

set_9:	la $t1, int_9
	j draw_char_next
##################################################################
# draw_char Function
# $a0 -> Address of top left of 5x5
# $a1 -> char
##################################################################
# no return value
##################################################################
draw_char:
	# check to see which char data is needed
	beq $a1, 'c', set_C
	beq $a1, 'e', set_E
	beq $a1, 'g', set_G
	beq $a1, 'h', set_H
	beq $a1, 'l', set_L
	beq $a1, 'p', set_P
	beq $a1, 's', set_S
	beq $a1, 'v', set_V

# set the corresponding char data in bytes	
set_C:	la $t1, C
	j draw_char_next

set_E:	la $t1, E
	j draw_char_next

set_G:	la $t1, G
	j draw_char_next

set_H:	la $t1, H
	j draw_char_next

set_L:	la $t1, L
	j draw_char_next

set_P:	la $t1, P
	j draw_char_next

set_S:	la $t1, S
	j draw_char_next
	
set_V:	la $t1, V
	j draw_char_next
	
draw_char_next:
	# drawing first row of char/int
	lb $t0, 0($t1)
	sw $t0, 0($a0)
	lb $t0, 1($t1)
	sw $t0, 4($a0)
	lb $t0, 2($t1)
	sw $t0, 8($a0)
	lb $t0, 3($t1)
	sw $t0, 12($a0)
	lb $t0, 4($t1)
	sw $t0, 16($a0)
	
	# drawing second row of char/int
	lb $t0, 5($t1)
	sw $t0, 128($a0)
	lb $t0, 6($t1)
	sw $t0, 132($a0)
	lb $t0, 7($t1)
	sw $t0, 136($a0)
	lb $t0, 8($t1)
	sw $t0, 140($a0)
	lb $t0, 9($t1)
	sw $t0, 144($a0)

	# drawing third row of char/int
	lb $t0, 10($t1)
	sw $t0, 256($a0)
	lb $t0, 11($t1)
	sw $t0, 260($a0)
	lb $t0, 12($t1)
	sw $t0, 264($a0)
	lb $t0, 13($t1)
	sw $t0, 268($a0)
	lb $t0, 14($t1)
	sw $t0, 272($a0)
	
	# drawing fourth row of char/int
	lb $t0, 15($t1)
	sw $t0, 384($a0)
	lb $t0, 16($t1)
	sw $t0, 388($a0)
	lb $t0, 17($t1)
	sw $t0, 392($a0)
	lb $t0, 18($t1)
	sw $t0, 396($a0)
	lb $t0, 19($t1)
	sw $t0, 400($a0)

	# drawing fifth row of char/int
	lb $t0, 20($t1)
	sw $t0, 512($a0)
	lb $t0, 21($t1)
	sw $t0, 516($a0)
	lb $t0, 22($t1)
	sw $t0, 520($a0)
	lb $t0, 23($t1)
	sw $t0, 524($a0)
	lb $t0, 24($t1)
	sw $t0, 528($a0)

	jr $ra		#return

##################################################################
# pause Function
# $a0 - amount to pause
##################################################################
# no return values
##################################################################
pause:
	li $v0, 32 #syscall value for sleep
	syscall
	jr $ra

restart:
	j main
end_game:
	# draw gg
	lw $a0, screen_width
	lw $a1, black
	mul $a2, $a0, $a0 #total number of pixels on screen
	mul $a2, $a2, 4 #align addresses
	add $a2, $a2, $gp #add base of gp
	add $a0, $gp, $zero #loop counter
fill_gg:
	beq $a0, $a2, draw_gg
	sw $a1, 0($a0) #store color
	addiu $a0, $a0, 4 #increment counter
	j fill_gg
	
draw_gg:# draw GG
	li $a0, 11
	li $a1, 13
	jal coor_to_addr
	move $a0, $v0
	li $a1, 'g'
	jal draw_char
	li $a0, 17
	li $a1, 13
	jal coor_to_addr
	move $a0, $v0
	li $a1, 'g'
	jal draw_char
	
	# draw sc
	li $a0, 3
	li $a1, 20
	jal coor_to_addr
	move $a0, $v0
	li $a1, 's'
	jal draw_char
	li $a0, 9
	li $a1, 20
	jal coor_to_addr
	move $a0, $v0
	li $a1, 'c'
	jal draw_char
	
	# draw ':'
	li $a0, 15
	li $a1, 21
	jal coor_to_addr
	move $a0, $v0
	lw $a1, white
	jal draw_pixel
	add $a0, $a0, 256
	jal draw_pixel
	
	# tally up score
	lw $t0, num_enemy
	lw $a0, score
	add $a0, $a0, $t0
	
	# draw score at the tenth digit
	li $a0, 17
	li $a1, 20
	jal coor_to_addr
	move $a0, $v0
	lw $t1, score 
	add $t2, $t1, -24
	sw $a1, score
	blt $t2, 0, return_zero
	li $t0, 10
	div $t2, $t0
	mflo $a1
	
	j return_score
return_zero:
	li $a1, 0
	sw $a1, score
	
return_score:	
	jal draw_int
	
	# draw score at the unit digit
	li $a0, 23
	li $a1, 20
	jal coor_to_addr
	move $a0, $v0
	lw $t1, score
	div $t1, $t0
	mfhi $a1
	jal draw_int
	
ask_res:
	# get the input from the keyboard
	li $t0, 0xffff0000
	lw $t1, 0($t0)
	li $s2, 0
	beq $t1, 0, ask_res # if no input is detected, keep waiting
	lw $a0, 4($t0) # save user's new input
	beq $a0, 112, restart
	bne $a0, 113, ask_res
	
exit:	
	li $v0, 10
	syscall
