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
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
.data	
end_cond: .word 0
player_x: .word 5
player_y: .word 16
player_lives: .word 3
screen_width: .word 32
score: .word 0
game_speed: .word 200
direction:	.word 119 #initially moving up
# direction variable
# 119 - moving up - W
# 115 - moving down - S
# 97 - moving left - A
# 100 - moving right - D
# numbers are selected due to ASCII characters
#this array stores the screen coordinates of a direction change
#once the tail hits a position in this array, its direction is changed
#this is used to have the tail follow the head correctly
directionChangeAddressArray:	.word 0:100
#this stores the new direction for the tail to move once it hits
#an address in the above array
newDirectionChangeArray:	.word 0:100
#stores the position of the end of the array (multiple of 4)
arrayPosition:			.word 0
locationInArray:		.word 0

.eqv	BASE_ADDRESS	0x10008000
.text globl main

main:	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	li $t1, 0xff0000 # $t1 stores the red colour code
	li $t2, 0x00ff00 # $t2 stores the green colour code
	li $t3, 0x0000ff # $t3 stores the blue colour code
	
	
draw_player:	
######################################################
# Draw Initial player Position
######################################################
	#draw middle layer of player
	lw $a0, player_x #load x coordinate
	lw $a1, player_y #load y coordinate
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	li $a1, 0xC6FF00 #store color into $a1
	jal DrawPixel	#draw color at pixel
	#lw $a0, player_x #load x coordinate
	#lw $a1, player_y #load y coordinate
	#add $a0, $a0, 1
	#jal CoordinateToAddress #get screen coordinates
	#move $a0, $v0 #copy coordinates to $a0
	#li $a1, 0xC6FF00 #store color into $a1
	#jal DrawPixel	#draw color at pixel
	#lw $a0, player_x #load x coordinate
	#lw $a1, player_y #load y coordinate
	#add $a0, $a0, 2
	#jal CoordinateToAddress #get screen coordinates
	#move $a0, $v0 #copy coordinates to $a0
	#li $a1, 0xC6FF00 #store color into $a1
	#jal DrawPixel	#draw color at pixel
	#lw $a0, player_x #load x coordinate
	#lw $a1, player_y #load y coordinate
	#add $a0, $a0, -1
	#jal CoordinateToAddress #get screen coordinates
	#move $a0, $v0 #copy coordinates to $a0
	#li $a1, 0x0088FF #store color into $a1
	#jal DrawPixel	#draw color at pixel
	
	#draw top level
	#lw $a0, player_x #load x coordinate
	#lw $a1, player_y #load y coordinate
	#add $a1, $a1, 1
	#jal CoordinateToAddress #get screen coordinates
	#move $a0, $v0 #copy coordinates to $a0
	#li $a1, 0x0088FF #store color into $a1
	#jal DrawPixel	#draw color at pixel
	#lw $a0, player_x #load x coordinate
	#lw $a1, player_y #load y coordinate
	#add $a1, $a1, -1
	#add $a0, $a0, 1
	#jal CoordinateToAddress #get screen coordinates
	#move $a0, $v0 #copy coordinates to $a0
	#li $a1, 0x0088FF #store color into $a1
	#jal DrawPixel	#draw color at pixel
	#lw $a0, player_x #load x coordinate
	#lw $a1, player_y #load y coordinate
	#add $a1, $a1, -1
	#add $a0, $a0, -1
	#jal CoordinateToAddress #get screen coordinates
	#move $a0, $v0 #copy coordinates to $a0
	#li $a1, 0x0088FF #store color into $a1
	#jal DrawPixel	#draw color at pixel
	
	#draw bottom level
	#lw $a0, player_x #load x coordinate
	#lw $a1, player_y #load y coordinate
	#add $a1, $a1, 1
	#jal CoordinateToAddress #get screen coordinates
	#move $a0, $v0 #copy coordinates to $a0
	#li $a1, 0x0088FF #store color into $a1
	#jal DrawPixel	#draw color at pixel
	#lw $a0, player_x #load x coordinate
	#lw $a1, player_y #load y coordinate
	#add $a1, $a1, 1
	#add $a0, $a0, 1
	#jal CoordinateToAddress #get screen coordinates
	#move $a0, $v0 #copy coordinates to $a0
	#li $a1, 0x0088FF #store color into $a1
	#jal DrawPixel	#draw color at pixel
	#lw $a0, player_x #load x coordinate
	#lw $a1, player_y #load y coordinate
	#add $a1, $a1, 1
	#add $a0, $a0, -1
	#jal CoordinateToAddress #get screen coordinates
	#move $a0, $v0 #copy coordinates to $a0
	#li $a1, 0x0088FF #store color into $a1
	#jal DrawPixel	#draw color at pixel
main_loop:
	lw $t4, end_cond
	beq $t4, 1, end_game	
	j InputCheck
	sw $v0, player_x
	sw $v1, player_y
	j main_loop
	
######################################################
# Check for Direction Change
######################################################

InputCheck:
	lw $a0, game_speed

	#get the coordinates of current player for direction change if needed
	lw $a1, player_x
	lw $a2, player_y

	#get the input from the keyboard
	li $t0, 0xffff0000
	lw $t1, ($t0)
	bne $t1, 1, InputCheck
	lw $a0, 4($t0) #store direction based on input
	jal check_bounds
	jr $ra													

check_bounds:
	beq $a0, 119, check_up # going up
	beq $a0, 115, check_down # going down
	beq $a0, 97, check_left # going left
	beq $a0, 100, check_right # going right

check_up:
	addi $t0, $a2, -2
	bgez $t0, move_up
	jr $ra
check_down:
	addi $t0, $a2, 2
	ble $t0, 32, move_down
	jr $ra
check_left:
	addi $t0, $a1, -2
	bgez $t0, move_left
	jr $ra
check_right:
	addi $t0, $a1, 3
	ble $t0, 32, move_right

move_up:
	addi $a2, $a2, -1
	move $a0, $a1 
	move $a1, $a2
	move $v0, $a0 # save new x coor
	move $v1, $a1 # save new y coor
	move $t2, $ra # save previous caller
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0
	li $a1, 0x0088FF #store color into $a1
	jal DrawPixel
	jr $t2
	
move_down:
	addi $a2, $a2, 1
	move $a0, $a1 
	move $a1, $a2
	move $v0, $a0 # save new x coor
	move $v1, $a1 # save new y coor
	move $t2, $ra # save previous caller
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0
	li $a1, 0x0088FF #store color into $a1
	jal DrawPixel
	jr $t2

move_left:
	addi $a1, $a1, -1
	move $a0, $a1 
	move $a1, $a2
	move $v0, $a0 # save new x coor
	move $v1, $a1 # save new y coor
	move $t2, $ra # save previous caller	
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0
	li $a1, 0x0088FF #store color into $a1
	jal DrawPixel
	jr $t2

move_right:
	addi $a1, $a1, 1
	move $a0, $a1 
	move $a1, $a2
	move $v0, $a0 # save new x coor
	move $v1, $a1 # save new y coor
	move $t2, $ra # save previous caller
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0
	li $a1, 0x0088FF #store color into $a1
	jal DrawPixel
	jr $t2

end_move:
	
	jr $ra
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
	add $v0, $v0, $gp	#add global pointerfrom bitmap display
	jr $ra			# return $v0

##################################################################
#Draw Function
# $a0 -> Address position to draw at
# $a1 -> Color the pixel should be drawn
##################################################################
# no return value
##################################################################
DrawPixel:
	sw $a1, ($a0) 	#fill the coordinate with specified color
	jr $ra		#return

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