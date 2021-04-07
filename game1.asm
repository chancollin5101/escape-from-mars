.data	
end_cond: .word 0
player_tail_x: .word 3
player_head_x: .word 5
player_x: .word 5
player_y: .word 15
player_lives: .word 3
screen_width: .word 32
score: .word 0
enemy_x: .word 32
enemy_y: .word 15
enemy_speed: .word 1
enemy_pause: .word 50
game_speed: .word 40
direction: .word 115 #initially moving up
# direction variable
# 119 - moving up - W
# 115 - moving down - S
# 97 - moving left - A
# 100 - moving right - D
# numbers are selected due to ASCII characters
red: .word 0xff0000
green: .word 0x00ff00
bllue: .word 0x0000ff

.eqv	BASE_ADDRESS	0x10008000
.text globl main

main:	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	# draw inital player
	lw $a0, player_x #load x coordinate
	lw $a1, player_y #load y coordinate
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	li $a1, 0xC6FF00 #store color into $a1
	jal DrawPixel	#draw color at pixel
	# load enemy ships
	lw $a0, enemy_x
	lw $a1, enemy_y
	jal CoordinateToAddress
	move $a0, $v0
	lw $a1, red
	jal DrawPixel
	 
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
	lw $a0, 4($t0) # store new direction based on input
	lw $a1, player_x # save player's current x
	lw $a2, player_y # save player's current y
	jal check_bounds
	
	beq $v0, 1, erase # erase previous position if valid

return_here:
	lw $a0, player_x
	lw $a1, player_y
	jal CoordinateToAddress
	move $a0, $v0 # set address
	li $a1, 0xC6FF00 # set color
	jal DrawPixel # draw new pixel

update_enemy: 
	lw $a0, enemy_pause
	jal Pause
	lw $a0, enemy_x
	lw $a1, enemy_y
	jal CoordinateToAddress
	move $a0, $v0
	li $a1, 0x000000
	jal DrawPixel
	lw $t3, enemy_speed
	lw $t4, red
	lw $a0, enemy_x
	lw $a1, enemy_y
	sub $a0, $a0, $t3
	bge $a0, 0, continue

respawn:
	li $a0, 32
	
continue: 
	sw $a0, enemy_x
	jal CoordinateToAddress
	move $a0, $v0
	move $a1, $t4
	jal DrawPixel
	
	j game_loop

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
	ble $t0, 32, valid
	j not_valid

check_left:
	addi $t0, $a1, -2
	bgez $t0, valid
	j not_valid

check_right:
	addi $t0, $a1, 2
	ble $t0, 32, valid
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
	jal DrawPixel
	j update_position

update_position:
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
	j return_here
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
	sw $a1, ($a0) 	#fill the coordinate with specified colors
	jr $ra		#return

##################################################################
#Draw Function
# $a0 -> x Coordinate
# $a1 -> y Coordinate
# $a2 -> new direction
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

end_game: 
	li $v0, 10
	syscall
