.data	
end_cond: .word 0
player_x: .word 5
player_y: .word 15
player_health: .word 100
screen_width: .word 32
score: .word 0
enemy_x: .word 30
enemy_y: .word 15 # doesn't matter; cuz it's randomized anyways
enemy_speed: .word 1
enemy_pause: .word 120
game_speed: .word 400
collision: .word 300
direction: .word 115 # doesn't matter; cuz it'll affect when an input is entered
# input variable - ASCII code
# 119 - moving up - w
# 115 - moving down - s
# 97 - moving left - a
# 100 - moving right - d
# 112 - restart - p
red: .word 0xff0000
grey: .word 0x9F9F9F
blue: .word 0x0080ff
d_blue: .word 0x0050A0

.eqv	BASE_ADDRESS	0x10008000
.text globl main

main:	
######################################################
# Fill Screen to Black, for reset
######################################################
	lw $a0, screen_width
	li $a1, 0x000000
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
	lw $a0, screen_width
	lw $a1, red
	mul $a2, $a0, $a0 #total number of pixels on screen
	mul $a2, $a2, 4 #align addresses
	add $a2, $a2, $gp #add base of gp
	add $a0, $gp, $zero #loop counter
fill_red_cont:	
	beq $a0, $a2, init
	sw $a1, 0($a0)
	addiu $a0, $a0, 128
	j fill_red_cont
	
init:	sw, $zero, end_cond
	li $t0, 5
	sw $t0, player_x
	li $t0 15
	sw $t0, player_y
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
	sw $t0, direction
	
clear_reg:
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
	lw $t2, d_blue
	lw $t3, red
	lw $a0, player_x # load player's x coordinate
	lw $a1, player_y # load player's y coordinate
	jal CoordinateToAddress
	move $a0, $v0
	move $a1, $t2 # set color as blue
	jal DrawPixel # drawing head
	
	addi $a0, $a0, -4 # set address for middle of player
	move $a1, $t2 # set color as dark blue
	jal DrawPixel # drawing body
	
	addi $a0, $a0, -4 # set address for tail of player
	move $a1, $t3 # set color as red
	jal DrawPixel # drawing tail
######################################################################	
	# rng - generate random number within (0-32)
	li $v0, 42 
	li $a0, 0
	li $a1, 32
	syscall
	
	sw $a0, enemy_y
	
	# load enemy ships
	lw $a0, enemy_x
	lw $a1, enemy_y
	jal CoordinateToAddress
	move $a0, $v0
	lw $a1, grey
	jal DrawPixel # drawing OO
		      #		XO
	
	addi $a0, $a0, -128
	li $a1, 0xFFFFFF
	jal DrawPixel # drawing XO
		      # 	XO
		      
	addi $a0, $a0, 4
	lw $a1, grey
	jal DrawPixel # drawing XX
		      #		XO

	addi $a0, $a0, 128
	jal DrawPixel # drawing XX
		      # 	XX
		      
######################################################################	

game_loop:
	lw $t1, end_cond
	beq $t1, 1, end_game
	# get user input
	lw $a0, game_speed # sleep for a brief moment
	jal Pause
	# get the input from the keyboard
	li $t0, 0xffff0000
	lw $t1, 0($t0)
	bne $t1, 1, update_enemy
	lw $t1, 4($t0)
	sw $t1, direction
	beq $t1, 112, restart
	lw $a0, 4($t0) # store new direction based on input
	lw $a1, player_x # save player's current x
	lw $a2, player_y # save player's current y
	jal check_bounds
	
	beq $v0, 1, erase # erase previous position if valid

redraw_player:
	lw $a0, player_x
	lw $a1, player_y
	jal CoordinateToAddress
	move $a0, $v0 # set address
	lw $a1, d_blue # set color
	jal DrawPixel # redrawing head
	addi $a0, $a0, -4
	lw $a1, d_blue
	jal DrawPixel # redraing body
	addi $a0, $a0, -4
	lw $a1, red
	jal DrawPixel # redrawing tail 
	
update_enemy: 
	# erasing enemy at old position
	lw $a0, enemy_x
	lw $a1, enemy_y
	jal CoordinateToAddress
	move $a0, $v0
	li $a1, 0x000000
	jal DrawPixel  # erasing XX
		       # 	 OX
	
	addi $a0, $a0, -128
	jal DrawPixel # erasing OX
		      #		OX
	
	addi $a0, $a0, 4
	jal DrawPixel # erasing OO
		      #		OX
	
	addi $a0, $a0, 128
	jal DrawPixel # erasing OO
		      # 	OO
		      
	lw $t3, enemy_speed
	lw $t4, grey
	lw $a0, enemy_x
	lw $a1, enemy_y
	sub $a0, $a0, $t3
	jal check_enemy_collision
	lw $a0, enemy_x
	lw $a1, enemy_y
	sub $a0, $a0, $t3
	beq $v0, 1, animate_player_collision
	bgt $a0, 0, continue
respawn:
	# rng - generate random number within (0-32)
	li $v0, 42 
	li $a0, 0
	li $a1, 32
	syscall
	
	sw $a0, enemy_y
	
	li $a0, 30
	j continue

animate_player_collision: 
	lw $a0, player_x
	addi $a0, $a0, -2
	lw $a1, player_y
	jal CoordinateToAddress
	move $a0, $v0
	li $a1, 0xFFFFFF
	jal DrawPixel
	move $t1, $a0
	lw $a0, collision
	jal Pause
	move $a0, $t1
	lw $a1, red
	jal DrawPixel
	j respawn

continue:
	# redrawing enemy at new postion 
	sw $a0, enemy_x
	lw $a1, enemy_y
	jal CoordinateToAddress
	move $a0, $v0
	move $a1, $t4
	jal DrawPixel # redrawing OO
		      #		  XO
	
	addi $a0, $a0, -128
	li $a1, 0xFFFFFF
	jal DrawPixel # redrawing XO
		      #		  XO
	
	addi $a0, $a0, 4
	lw $a1, grey
	jal DrawPixel # redrawing XX
		      #		  XO
	
	addi $a0, $a0, 128
	jal DrawPixel # redrawing XX
		      #		  XX
	j game_loop
###################################################
#	$a0 - enemy's x-coordinate
#	$a1 - enemy's y-coordinate 
###################################################
#	$v0 - return whether there's a collision
###################################################
check_enemy_collision: 
	lw $t1, player_x
	lw $t2, player_y
	beq $a0, $t1, check_y_collision
	j return_no_collision

check_y_collision:
	beq $a1, $t2, return_collision
	addi $a1, $a1, -1
	beq $a1, $t2, return_collision
	j return_no_collision

return_collision:
	li $v0, 1
	jr $ra

return_no_collision:
	li $v0, 0
	jr $ra
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
	blt $t0, 32, valid
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

erase:	lw $a0, player_x # save player's current x
	lw $a1, player_y # save player's current y
	jal CoordinateToAddress
	move $a0, $v0
	li $a1, 0x000000
	jal DrawPixel # erasing head
	addi $a0, $a0, -4
	jal DrawPixel # erasing body
	addi $a0, $a0, -4
	jal DrawPixel # erasing tail

update_player:
	lw $t1, player_x # save player's current x
	lw $t2, player_y # save player's current y
	lw $t3, direction # get new dir
	beq $t3, 119, move_up # move user up
	beq $t3, 115, move_down # move user down
	beq $t3, 97, move_left # move user left
	beq $t3, 100, move_right # move user right
	
move_up:
	addi $t2, $t2, -2
	sw $t2, player_y
	j end_move

move_down:
	addi $t2, $t2, 2
	sw $t2, player_y
	j end_move

move_left:
	addi $t1, $t1, -2
	sw $t1, player_x
	j end_move

move_right:
	addi $t1, $t1, 2
	sw $t1, player_x
	j end_move

end_move:
	j redraw_player
##################################################################
#CoordinatesToAddress Function
# $a0 -> x coordinate
# $a1 -> y coordinate	
##################################################################
# returns $v0 -> the address of the coordinates for bitmap display
##################################################################
CoordinateToAddress:
	lw $v0, screen_width 	#Store screen width into $v0
	mul $v0, $v0, $a1	#multiply by y position
	add $v0, $v0, $a0	#add the x position
	mul $v0, $v0, 4		#multiply by 4
	add $v0, $v0, $gp	#add global pointer from bitmap display
	jr $ra			# return $v0

##################################################################
#Draw Function
# $a0 -> Address position to draw at
# $a1 -> Color the pixel should be drawn
##################################################################
# no return value
##################################################################
DrawPixel:
	sw $a1, 0($a0) 	#fill the coordinate with specified colors
	jr $ra		#return

##################################################################
#Animate Collision Function
# $a0 -> x-coordinate of player
# $a1 -> y-coordiante of player
##################################################################
# no return value
##################################################################
animate_collision:
	add $a0, $a0, -2
	jal CoordinateToAddress
	move $a0, $v0
	li $a1, 0x000000
	jal DrawPixel
	lw, $a1, red
	jal DrawPixel
	jr $ra

##################################################################
#Draw Function
# $a0 -> x Coordinate
# $a1 -> y Coordinate
# $a2 -> 1 for collision detected; 0 for no collision
##################################################################
# returns the previous position in address
##################################################################
draw_player:
	jal CoordinateToAddress 
	move $t1, $v0 # save previous address for return 
	move $a0, $v0 
	li $a1, 0xC6FF00
	jal DrawPixel
	#addi $a0, $a0, 1
	#jal CoordinateToAddress
	#move $a0, $v0
	#li $a1, 0xC6FF00
	#jal DrawPixel
	#addi $a0, $a0, -2
	#jal CoordinateToAddress
	#move $a0, $v0
	#li $a1, 0xC6FF00
	#jal DrawPixel
	
	move $v0, $t1 # return address of previous position
	jr $ra
##################################################################
# Pause Function
# $a0 - amount to pause
##################################################################
# no return values
##################################################################
Pause:
	li $v0, 32 #syscall value for sleep
	syscall
	jr $ra

restart:
	j main
end_game: 
	li $v0, 10
	syscall
