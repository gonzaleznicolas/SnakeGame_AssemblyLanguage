/*
Student:	Nicolas Gonzalez
ID:		10151261
Date:		March 2016
Course:		CPSC 359
Professor:	Jalal Kawash
TA:		Salim Afra
*/

.section .text

//------------------------------------------------------------------

.globl	printInstructions
printInstructions:
	push	{lr}

	ldr	r0, =black
	bl	coverScreen

	// instructions title sprite
	ldr	r0, =100		// x
	ldr	r1, =250		// y
	ldr	r2, =instructionsSprite	// sprite
	bl	printSprite		// comment to get rid of load time

	// sprites on instructions screen
	ldr	r0, =120
	ldr	r1, =300
	ldr	r2, =appleBlack
	bl	printSprite

	ldr	r0, =170
	ldr	r1, =300
	ldr	r2, =vpBlack
	bl	printSprite

	ldr	r0, =220
	ldr	r1, =300
	ldr	r2, =doorBlack
	bl	printSprite

	// instructions
	ldr	r0, =0xFFFF
	push	{r0}				// arg 5: color
	ldr	r0, =instructionLine1		// arg 1
	ldr	r1, =iL1Length			// arg 2
	ldr	r2, =100			// arg 3: x
	ldr	r3, =350			// arg 4: y
	bl	printString


	ldr	r0, =0xFFFF
	push	{r0}				// arg 5: color
	ldr	r0, =instructionLine2		// arg 1
	ldr	r1, =iL2Length			// arg 2
	ldr	r2, =100			// arg 3: x
	ldr	r3, =375			// arg 4: y
	bl	printString

	ldr	r0, =0xFFFF
	push	{r0}				// arg 5: color
	ldr	r0, =instructionLine3		// arg 1
	ldr	r1, =iL3Length			// arg 2
	ldr	r2, =100			// arg 3: x
	ldr	r3, =400			// arg 4: y
	bl	printString

	ldr	r0, =0xFFFF
	push	{r0}				// arg 5: color
	ldr	r0, =instructionLine4		// arg 1
	ldr	r1, =iL4Length			// arg 2
	ldr	r2, =100			// arg 3: x
	ldr	r3, =425			// arg 4: y
	bl	printString

	ldr	r0, =0xFFFF
	push	{r0}				// arg 5: color
	ldr	r0, =instructionLine5		// arg 1
	ldr	r1, =iL5Length			// arg 2
	ldr	r2, =100			// arg 3: x
	ldr	r3, =450			// arg 4: y
	bl	printString

	ldr	r0, =0xFFFF
	push	{r0}				// arg 5: color
	ldr	r0, =instructionLine6		// arg 1
	ldr	r1, =iL6Length			// arg 2
	ldr	r2, =100			// arg 3: x
	ldr	r3, =475			// arg 4: y
	bl	printString

	ldr	r0, =0xFFFF
	push	{r0}				// arg 5: color
	ldr	r0, =instructionLine7		// arg 1
	ldr	r1, =iL7Length			// arg 2
	ldr	r2, =100			// arg 3: x
	ldr	r3, =500			// arg 4: y
	bl	printString


instructionLoop:
	bl	readSNES
	bl	identifyButtonsPressed	// output of read SNES is input to this
	cmp	r0, #5
	beq	instructionLoop


	pop	{pc}
//------------------------------------------------------------------
/*
input
	none
output
	r0 - flag. 0 = value pack not found, 1=value pack found
precondition
	the vp has been spawned at (vpI, vpJ) and has not been eaten
postcondition
	flag is returned correctly. if VP is found, vpPresent flag is set to 0 and the value pack is errased.
*/
.globl	seeIfVPFound
seeIfVPFound:
	push	{r4-r8, lr}


	snake_i		.req	r4
	snake_j		.req	r5
	vp_i		.req	r6
	vp_j		.req	r7
	returnVal	.req	r8

	mov	r0, #0			// arg 1: body piece number
	bl	getSnakePiecePosition
	mov	snake_i, r0
	mov	snake_j, r1



	ldr	r0, =vpI
	ldr	vp_i, [r0]
	ldr	r0, =vpJ
	ldr	vp_j, [r0]

	// if the i's are different, the head != vp, return
	cmp	snake_i, vp_i
	movne	returnVal, #0
	bne	returnseeIfVPFound

	// if the j's are different, the head != vp, return
	cmp	snake_j, vp_j
	movne	returnVal, #0
	bne	returnseeIfVPFound

	// if here, (snake_i, snake_j) == (door_i, door_j), so we have found the door
	mov	returnVal, #1

	// if here, the value pack was found
	// the value pack will give you 4 extra points
	// and it will increment the speed of the snake for 100 gameLoop iterations

	// increment score by 4
	bl	incrementScore
	bl	incrementScore
	bl	incrementScore
	bl	incrementScore

	// set the vpKey to 0
	ldr	r0, =vpKey
	mov	r1, #0
	str	r1, [r0]


	// decrement the amountOfTimeToWait
	ldr	r0, =amountOfTimeToWait
	ldr	r1, =50000
	str	r1, [r0]


	ldr	r0, =vpPresent
	mov	r1, #0
	str	r1, [r0]
	


returnseeIfVPFound:

	mov	r0, returnVal

	.unreq	snake_i
	.unreq	snake_j
	.unreq	vp_i
	.unreq	vp_j
	.unreq	returnVal

	pop	{r4-r8, pc}
//------------------------------------------------------------------
/*
input:
	none
output:
	none
precondition:
	none
postcondition:
	if there is no vp on the screen already (if vpPresent==0), a vp apears on the screen on
	a cell without a wall, border, or snake.
	also, set vpI and vpJ, and set vpPresent

*/
.globl	spawnValuePack
spawnValuePack:
	push	{r4-r9, lr}

	i			.req	r4
	j			.req	r5
	length			.req	r6
	snakePieceNumber	.req	r7
	snakeI			.req	r8
	snakeJ			.req	r9

	// see if there is already a value pack present (by testing global flag).
	// if so, just return without making another value pack
	ldr	r0, =vpPresent
	ldr	r1, [r0]			// vpPresent flag in r1
	cmp	r1, #1				// see if vpPresent == 1
	beq	returnSpawnValuePack		// if so, it is present so simply return without making a vp


spawnValuePackStart:
	// GET i (number in interval [5, 22] )
	bl	randomNum
	ldr	r2, =0x1F
	and	r0, r0, r2
	mov	i, r0
	// make sure it is [5, 22] by taking a mod 19 result and adding 5
	mov	r0, i		// arg 1: divided
	mov	r1, #18		// arg 2: divisor
	bl	divide		// quotient in r0. remainder in r1 (modular result)
	mov	i, r1

	add	i, #5		// i now contains a random value in [5, 22]


	// GET j (number in interval [1, 30] )
	bl	randomNum
	ldr	r2, =0x1F
	and	r0, r0, r2
	mov	j, r0
	// make sure it is [1, 30] by taking a mod 30 result and adding 1
	mov	r0, i		// arg 1: divided
	mov	r1, #30		// arg 2: divisor
	bl	divide		// quotient in r0. remainder in r1 (modular result)
	mov	j, r1
	add	j, #1		// j now contains a random value in [1, 30]


	// CHECK THAT (i, j) is not a wall (see screen register)
	// calculate offset=(32i+j)*4
	add	r0, j, i, lsl #5	// r0 = offset = 32i + j
	lsl	r0, #2			// r0 = offset = (32i+j)*4
	ldr	r3, =screen
	add	r3, r0			// address of (i, j) in r0
	ldr	r0, [r3]		// address of sprite at (i, j) in r0
	ldr	r1, =wood
	cmp	r1, r0
	beq	spawnValuePack


	// CHECK THAT (i, j) is not a snake piece

	mov	snakePieceNumber, #0
spawnValuePackLoop:
	// get position of snakePiece number
	mov	r0, snakePieceNumber	// arg 1
	bl	getSnakePiecePosition
	mov	snakeI, r0
	mov	snakeJ, r1

	// see if (i,j)==(snakeI, snakeJ). if so,  we have to calculate a new (i,j)
	cmp	i, snakeI
	bne	differentV
	cmp	j, snakeJ
	bne	differentV

	// if here, (i,j)==(snakeI, snakeJ). make new apple position (i,j)
	b	spawnValuePackStart

differentV:
	// if the apple is not at that snake piece, check the next piece

	add	snakePieceNumber, #1
	cmp	snakePieceNumber, length
	ble	spawnValuePackLoop

	// if here, we lookeed at all the snake pieces and none of them are where we are about to spawn the apple.


validValuePackPosition:

	// if here, (i, j) is not a wall nor snake
	ldr	r0, =vpI
	str	i, [r0]
	ldr	r0, =vpJ
	str	j, [r0]
	// print to screen
	mov	r0, i
	mov	r1, j
	ldr	r2, =valuePackSprite
	bl	printCell

	// update vpPresent flag
	ldr	r0, =vpPresent
	mov	r1, #1
	str	r1, [r0]


returnSpawnValuePack:
	.unreq	i
	.unreq	j
	.unreq	length
	.unreq	snakePieceNumber
	.unreq	snakeI
	.unreq	snakeJ

	pop	{r4-r9, pc}




//------------------------------------------------------------------


.globl	eraseDoor
eraseDoor:
	push	{r4-r5, lr}

	i	.req	r4
	j	.req	r5

	ldr	r0, =doorI
	ldr	i, [r0]
	ldr	r0, =doorJ
	ldr	j, [r0]


	// erase door by printing background overtop
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	ldr	r2, =background
	bl	printCell


	.unreq	i
	.unreq	j

	pop	{r4-r5, pc}

//------------------------------------------------------------------
/*
input
	none
output
	r0 - flag. 0 = door not found, 1=door found
precondition
	the exit door has been spawned at (doorI, doorJ)
postcondition
	flag is returned correctly
*/
.globl	seeIfDoorFound
seeIfDoorFound:
	push	{r4-r8, lr}

	snake_i		.req	r4
	snake_j		.req	r5
	door_i		.req	r6
	door_j		.req	r7
	returnVal	.req	r8

	mov	r0, #0			// arg 1: body piece number
	bl	getSnakePiecePosition
	mov	snake_i, r0
	mov	snake_j, r1

	ldr	r0, =doorI
	ldr	door_i, [r0]
	ldr	r0, =doorJ
	ldr	door_j, [r0]

	// if the i's are different, the head != door, return
	cmp	snake_i, door_i
	movne	returnVal, #0
	bne	returnseeIfDoorFound

	// if the j's are different, the head != door, return
	cmp	snake_j, door_j
	movne	returnVal, #0
	bne	returnseeIfDoorFound

	// if here, (snake_i, snake_j) == (door_i, door_j), so we have found the door
	mov	returnVal, #1
	


returnseeIfDoorFound:

	mov	r0, returnVal

	.unreq	snake_i
	.unreq	snake_j
	.unreq	door_i
	.unreq	door_j
	.unreq	returnVal

	pop	{r4-r8, pc}

//------------------------------------------------------------------
/*
input:
	none
output:
	none
precondition:
	none
postcondition:
	a door has apeared on the screen on a cell without a wall, border, or snake.
	at the same place in the screen array, the door sprite has been written
	also, set doorI and doorJ

*/
.globl	spawnDoor
spawnDoor:
	push	{r4-r9, lr}

	i			.req	r4
	j			.req	r5
	length			.req	r6
	snakePieceNumber	.req	r7
	snakeI			.req	r8
	snakeJ			.req	r9

spawnDoorStart:
	// GET i (number in interval [5, 22] )
	bl	randomNum
	ldr	r2, =0x1F
	and	r0, r0, r2
	mov	i, r0
	// make sure it is [5, 22] by taking a mod 19 result and adding 5
	mov	r0, i		// arg 1: divided
	mov	r1, #18		// arg 2: divisor
	bl	divide		// quotient in r0. remainder in r1 (modular result)
	mov	i, r1

	add	i, #5		// i now contains a random value in [5, 22]


	// GET j (number in interval [1, 30] )
	bl	randomNum
	ldr	r2, =0x1F
	and	r0, r0, r2
	mov	j, r0
	// make sure it is [1, 30] by taking a mod 30 result and adding 1
	mov	r0, i		// arg 1: divided
	mov	r1, #30		// arg 2: divisor
	bl	divide		// quotient in r0. remainder in r1 (modular result)
	mov	j, r1
	add	j, #1		// j now contains a random value in [1, 30]


	// CHECK THAT (i, j) is not a wall (see screen register)
	// calculate offset=(32i+j)*4
	add	r0, j, i, lsl #5	// r0 = offset = 32i + j
	lsl	r0, #2			// r0 = offset = (32i+j)*4
	ldr	r3, =screen
	add	r3, r0			// address of (i, j) in r0
	ldr	r0, [r3]		// address of sprite at (i, j) in r0
	ldr	r1, =wood
	cmp	r1, r0
	beq	spawnDoorStart


	// CHECK THAT (i, j) is not a snake piece

	mov	snakePieceNumber, #0
spawnDoorLoop:
	// get position of snakePiece number
	mov	r0, snakePieceNumber	// arg 1
	bl	getSnakePiecePosition
	mov	snakeI, r0
	mov	snakeJ, r1

	// see if (i,j)==(snakeI, snakeJ). if so,  we have to calculate a new (i,j)
	cmp	i, snakeI
	bne	differentD
	cmp	j, snakeJ
	bne	differentD

	// if here, (i,j)==(snakeI, snakeJ). make new apple position (i,j)
	b	spawnDoorStart

differentD:
	// if the apple is not at that snake piece, check the next piece

	add	snakePieceNumber, #1
	cmp	snakePieceNumber, length
	ble	spawnDoorLoop

	// if here, we lookeed at all the snake pieces and none of them are where we are about to spawn the apple.


validDoorPosition:

	// if here, (i, j) is not a wall nor snake
	ldr	r0, =doorI
	str	i, [r0]
	ldr	r0, =doorJ
	str	j, [r0]
	// print to screen
	mov	r0, i
	mov	r1, j
	ldr	r2, =doorSprite
	bl	printCell


	.unreq	i
	.unreq	j
	.unreq	length
	.unreq	snakePieceNumber
	.unreq	snakeI
	.unreq	snakeJ

	pop	{r4-r9, pc}

//------------------------------------------------------------------
/*
input:
	r0 - i (current snake position)
	r1 - j (current snake position)
output:
	r0 - collision flag. 0=no collision, 1=current snake position is occupied by a snake piece
precondition
	the snake head is currently at (i, j)
postcondition
	flag is returned correctly
*/
.globl	checkForSnakeCollision
checkForSnakeCollision:
	push	{r4-r10, lr}

	snakePieceNumber	.req	r4
	length			.req	r5
	i			.req	r6
	j			.req	r7
	snakeI			.req	r8
	snakeJ			.req	r9
	returnVal		.req	r10

	mov	i, r0
	mov	j, r1

	// put snake length in length register
	ldr	r0, =snakeLength
	ldr	length, [r0]


	mov	snakePieceNumber, #1			// start looking at the second snake piece
							// becase obviously the head is at the position of
							// a snake piece... that of the head
							// doesnt mean there is a collision
checkForSnakeCollisionLoop:

	mov	r0, snakePieceNumber			// arg 1
	bl	getSnakePiecePosition
	mov	snakeI, r0				// move output to safe place
	mov	snakeJ, r1

	cmp	snakeI, i
	bne	noCollisionWithThisBodyPiece

	cmp	snakeJ, j
	bne	noCollisionWithThisBodyPiece

	// if here, snakeI==i and snakeJ==j
	// so there is a collision
	mov	returnVal, #1
	b	returnCheckForSnakeCollision


noCollisionWithThisBodyPiece:


	add	snakePieceNumber, #1
	cmp	snakePieceNumber, length
	ble	checkForSnakeCollisionLoop

	// if here, we looked at all snake pieces and none are at the position of the snake head
	// (appart from the snake head)
	// so, return 0= no collision
	mov	returnVal, #0

returnCheckForSnakeCollision:
	
	mov	r0, returnVal

	.unreq	snakePieceNumber
	.unreq	length
	.unreq	i
	.unreq	j
	.unreq	snakeI
	.unreq	snakeJ
	.unreq	returnVal

	pop	{r4-r10, pc}
//------------------------------------------------------------------
/*
input
	none
output
	none
precondition
	none
postcondition
	the number of lives global variable has been decremented and printed to the screen
*/
.globl	decrementNumberOfLives
decrementNumberOfLives:
	push	{r4-r5, lr}

	numLives	.req	r4

	// load lives from memory, decrement, and store back
	ldr	r0, =lives
	ldr	numLives, [r0]	// number of lives in r0
	sub	numLives, #1	// lives--
	str	numLives, [r0]	// store back in memory

	// errase previous lives by printing background color box overtop
	ldr	r0, =0x7497		// color
	push	{r0}
	mov	r0, #120		// x
	mov	r1, #80			// y
	mov	r2, #10			// width
	mov	r3, #20			// height
	bl	printBox	

	// turn integer into ascii characters. put it in memory in memory at label ascii
	ldr	r0, =lives
	ldr	r0, [r0]		// arg 1
	bl	itoa			// branch to function
	mov	r5, r0			// r5 contains length of string
	// store length in memory because printString requires that length is in memory
	ldr	r0, =numInAscii
	strb	r5, [r0]

	// print score to screen
	ldr	r0, =0xFFFF		// arg 5: color
	push	{r0}
	ldr	r0, =ascii		// arg 1: string pointer
	ldr	r1, =numInAscii		// arg 2: we put the string length there
	mov	r2, #120		// arg 3: x
	mov	r3, #80			// arg 4: y
	bl	printString		// branch to function



	.unreq	numLives

	pop	{r4-r5, pc}

//------------------------------------------------------------------
/*
input
	none
output
	none
precondition
	none
postcondition
	score global variable has been incremented and printed to screen
*/
.globl	incrementScore
incrementScore:
	push	{r4, lr}

	// increment score value in memory
	ldr	r0, =score
	ldr	r1, [r0]		// score in r0
	add	r1, #1			// increment
	str	r1, [r0]		// store back to memory

	// errase previous score by printing background color box overtop
	ldr	r0, =0x7497		// color
	push	{r0}
	mov	r0, #120		// x
	mov	r1, #50			// y
	mov	r2, #20			// width
	mov	r3, #20			// height
	bl	printBox	


	// turn integer into ascii characters. put it in memory in memory at label ascii
	ldr	r0, =score
	ldr	r0, [r0]		// arg 1
	bl	itoa			// branch to function
	mov	r4, r0			// r4 contains length of string
	// store length in memory because printString requires that length is in memory
	ldr	r0, =numInAscii
	strb	r4, [r0]


	// print score to screen
	ldr	r0, =0xFFFF		// arg 5: color
	push	{r0}
	ldr	r0, =ascii		// arg 1: string pointer
	ldr	r1, =numInAscii		// arg 2: we put the string length there
	mov	r2, #120		// arg 3: x
	mov	r3, #50			// arg 4: y
	bl	printString		// branch to function

	pop	{r4, pc}

//------------------------------------------------------------------
// void itoa (int n)
// input: an integer n in r0 (must be < 1000)
// output: length of string in memory. returned in r0
// precondition: n is an integer whose decimal representation has a maximum of 3 digits
// postcondition: ascii representation of decimal number is stored in memory at the label ascii. the unused bytes are all 0s.
itoa:
	// r4	integer
	// r5	temporary addresses
	// r6	length of string in memory
	push	{r4-r10}			// protect registers
one:	mov	r0, r0
	mov	r4, r0				// r4 = integer
	ldr	r5, =ascii			// address of place to write characters in r5	

	// figure out how many digits (in decimal representation):
	cmp	r4, #10				// compare integer to 10
	movlo	r6, #1				// if integer<10, we know string will be of length 1
	blo	oneDigit			// if integer<10, it is 1 digit. dont divide by 100 or 10
						// if here, integer > 10
	cmp	r4, #100			// compare integer to 100
	movlo	r6, #2				// string length is 2
	blo	twoDigit			// if integer<100, it is 2 digits. dont divide by 100	
						// if here, the integer is between 100 and 999. (< 1000 was precondition)
	mov	r6, #3				// therefore, 3 digits (string is 3 characters)

threeDigit:	
	// (integer / 100) + 48 = first character ascii value
	mov	r0, r4				// arg 1 (dividend)
	mov	r1, #100			// arg 2 (divisor)
	push	{lr}				// protect lr
	bl	divide				// call divide. r0 = quotient. r1 = remainder.
	pop	{lr}				// retrieve lr
	add	r0, #48				// ascii value of first character in r0
	strb	r0, [r5], #1			// store ascii value of first character in memory. increase address by one byte
	mov	r4, r1				// the remainder is the number we continue to work with
	
twoDigit:
	// (integer / 10) + 48 = second character ascii value
	mov	r0, r4				// arg 1 (dividend)
	mov	r1, #10				// arg 2 (divisor)
	push	{lr}				// protect lr
	bl	divide				// call divide. r0 = quotient. r1 = remainder.
	pop	{lr}				// retrieve lr
	add	r0, #48				// ascii value of second character in r0
	strb	r0, [r5], #1			// store ascii value of second character in memory. increase address by one byte
	mov	r4, r1				// the remainder is the number we continue to work with


oneDigit:
	// (integer / 1) + 48 = second character ascii value
	mov	r0, r4				// number in r0
	add	r0, #48				// ascii value of third character in r0
	strb	r0, [r5], #1			// store ascii value of third character in memory. increase address by one byte

	// return
	mov	r0, r6				// return length of string in r0
	pop	{r4-r10}			// retrieve registers
	mov	pc, lr				// return



//------------------------------------------------------------------
/*
input:
	none
output:
	none
precondition:
	none
postcondition:
	an apple has apeared on the screen on a cell without a wall, border, or snake.
	at the same place in the screen array, the appple sprite has been written
	also, set appleI and appleJ

*/
.globl	spawnApple
spawnApple:
	push	{r4-r9, lr}

	i			.req	r4
	j			.req	r5
	length			.req	r6
	snakePieceNumber	.req	r7
	snakeI			.req	r8
	snakeJ			.req	r9

spawnAppleStart:
	// GET i (number in interval [5, 22] )
	bl	randomNum
	ldr	r2, =0x1F
	and	r0, r0, r2
	mov	i, r0
	// make sure it is [5, 22] by taking a mod 19 result and adding 5
	mov	r0, i		// arg 1: divided
	mov	r1, #18		// arg 2: divisor
	bl	divide		// quotient in r0. remainder in r1 (modular result)
	mov	i, r1
	add	i, #5		// i now contains a random value in [5, 22]


	// GET j (number in interval [1, 30] )
	bl	randomNum
	ldr	r2, =0x1F
	and	r0, r0, r2
	mov	j, r0
	// make sure it is [1, 30] by taking a mod 30 result and adding 1
	mov	r0, i		// arg 1: divided
	mov	r1, #30		// arg 2: divisor
	bl	divide		// quotient in r0. remainder in r1 (modular result)
	mov	j, r1
	add	j, #1		// j now contains a random value in [1, 30]


	// CHECK THAT (i, j) is not a wall (see screen register)
	// calculate offset=(32i+j)*4
	add	r0, j, i, lsl #5	// r0 = offset = 32i + j
	lsl	r0, #2			// r0 = offset = (32i+j)*4
	ldr	r3, =screen
	add	r3, r0			// address of (i, j) in r0
	ldr	r0, [r3]		// address of sprite at (i, j) in r0
	ldr	r1, =wood
	cmp	r1, r0
	beq	spawnAppleStart


	// CHECK THAT (i, j) is not a snake piece

	mov	snakePieceNumber, #0
spawnAppleLoop:
	// get position of snakePiece number
	mov	r0, snakePieceNumber	// arg 1
	bl	getSnakePiecePosition
	mov	snakeI, r0
	mov	snakeJ, r1

	// see if (i,j)==(snakeI, snakeJ). if so,  we have to calculate a new (i,j)
	cmp	i, snakeI
	bne	different
	cmp	j, snakeJ
	bne	different

	// if here, (i,j)==(snakeI, snakeJ). make new apple position (i,j)
	b	spawnAppleStart

different:
	// if the apple is not at that snake piece, check the next piece

	add	snakePieceNumber, #1
	cmp	snakePieceNumber, length
	ble	spawnAppleLoop

	// if here, we lookeed at all the snake pieces and none of them are where we are about to spawn the apple.


validApplePosition:

	// if here, (i, j) is not an wall nor snake
	ldr	r0, =appleI
	str	i, [r0]
	ldr	r0, =appleJ
	str	j, [r0]
	// print to screen
	mov	r0, i
	mov	r1, j
	ldr	r2, =circle
	bl	printCell
	// write to screen array so snake can check when it eats an apple
	mov	r0, i
	mov	r1, j
	ldr	r2, =circle
	bl	writeCell

	.unreq	i
	.unreq	j
	.unreq	length
	.unreq	snakePieceNumber
	.unreq	snakeI
	.unreq	snakeJ

	pop	{r4-r9, pc}

//------------------------------------------------------------------
/*
input
	none
output
	r0 - random number (any size)
*/
.globl	randomNum
randomNum:
	push	{r4-r8,lr}
	
	x	.req	r4
	y	.req	r5
	z	.req	r6
	w	.req	r7
	t	.req	r8

	// get values from memory
	ldr	r1, =x_
	ldr	x, [r1]
	ldr	r1, =y_
	ldr	y, [r1]
	ldr	r1, =z_
	ldr	z, [r1]
	ldr	r1, =w_
	ldr	w, [r1]

	// xorshift algorithm:

	mov	t, x			// t = x;
	eor	t, t, t, lsl #11	// t ^= t << 11;
	eor	t, t, t, lsr #8		// t ^= t >> 8;
	// x = y; y = z; z = w;
	mov	x, y
	mov	y, z
	mov	z, w

	eor	w, w, w, lsr #19	// w ^= w >> 19;
	eor	w, t			// w ^= t;

	mov	r0, w			// return value
	
	// store values to memory
	ldr	r1, =x_
	str	x, [r1]
	ldr	r1, =y_
	str	y, [r1]
	ldr	r1, =z_
	str	z, [r1]
	ldr	r1, =w_
	str	w, [r1]

	.unreq	x
	.unreq	y
	.unreq	z
	.unreq	w
	.unreq	t

	pop	{r4-r8,pc}

//------------------------------------------------------------------
/*
input
	none
outout
	none
precondition
	there is an apple in the screen array. appleI and appleJ contain its (i,j)
postcondition
	apple is errased from the screen and the screen array. ovewritten by background
*/
.globl	erraseApple
erraseApple:
	push	{r4-r5, lr}
	i	.req	r4
	j	.req	r5

	// remove current apple from screen array
	// get i and j
	ldr	r0, =appleI
	ldr	i, [r0]
	ldr	r0, =appleJ
	ldr	j, [r0]	
	// calculate offset=(32i+j)*4
	add	r0, j, i, lsl #5	// r0 = offset = 32i + j
	lsl	r0, #2			// offset = (32i+j)*4
	ldr	r1, =screen
	add	r0, r1
	ldr	r2, =background
	str	r2, [r0]

	// errase current apple from screen (overwrite with background)
	mov	r0, i
	mov	r1, j
	ldr	r2, =background
	bl	printCell


	.unreq	i
	.unreq	j

	pop	{r4-r5, pc}

//------------------------------------------------------------------
/*
input:
	void
output:
	void
precondition:
	none
postcondition:
	a you lose sprite will be printed to the screen. if the user presses any button,
	it returns
*/
.globl	youLost
youLost:
	push	{lr}

	ldr	r0, =325		// x
	ldr	r1, =250		// y
	ldr	r2, =youLoseSprite	// sprite
	bl	printSprite		// comment to get rid of load time

youLostLoop:
	bl	readSNES
	bl	identifyButtonsPressed	// output of read SNES is input to this
	cmp	r0, #5
	beq	youLostLoop


	pop	{pc}

//------------------------------------------------------------------
/*
input:
	void
output:
	void
precondition:
	none
postcondition:
	a you win sprite will be printed to the screen. if the user presses any button,
	it returns
*/
.globl	youWon
youWon:
	push	{lr}

	ldr	r0, =325		// x
	ldr	r1, =250		// y
	ldr	r2, =youWinSprite	// sprite
	bl	printSprite		// comment to get rid of load time

youWonLoop:
	bl	readSNES
	bl	identifyButtonsPressed	// output of read SNES is input to this
	cmp	r0, #5
	beq	youWonLoop


	pop	{pc}


//------------------------------------------------------------------
/*
input:
	void
output:
	none
precondition:
	none
postcondition:
	return if unpause
	branch to quit if quit selected
	branch to start if restart selected
*/
.globl	pauseMenu
pauseMenu:
	push	{r4-r8, lr}

	bl	disableInterrupt


	ldr	r0, =500000
	bl	wait

	input		.req	r4
	x		.req	r5
	y		.req	r6
	i		.req	r7
	j		.req	r8


	bl	printPauseMenu		// print pause menu background

	// wait so that when the user hits start to pause, the same start doesnt unpause
	ldr	r0, =500000
	bl	wait


	ldr	x, =450
	ldr	y, =50	


pauseMenuLoop:

	mov	r0, x
	mov	r1, y
	ldr	r2, =mainArrow		// sprite
	bl	printSprite		// print



	bl	readSNES			// read SNES. buttons register in r0
	bl	identifyButtonsPressed
						// return value in r0 (0, 1, 2, 3, 4, 5, 6)
	mov	input, r0			// put controller input value in r4 (input)

	cmp	input, #1			// see if user pressed up
	beq	pausemoveMainArrowUp			// branch if so
	cmp	input, #3			// see if user pressed down
	beq	pausemoveMainArrowDown		// branch if so
	cmp	input, #6			// see if user pressed A
	beq	pauseselectionMade			// branch if so
	cmp	input, #0			// see if user pressed start
	beq	pauseStartPressed		// branch if so
	b	pausenoNeedMoveMainArrow		// otherwise, branch


pausemoveMainArrowUp:
					// if here, user pressed up
	ldr	r0, =50
	cmp	y, r0			// see if arrow is in the up position
	ble	pausenoNeedMoveMainArrow		// if in the up position, dont do anything
					// if here we have to move arrow down, first errase current arrow

	mov	r0, x
	mov	r1, y
	ldr	r2, =black		// sprite
	bl	printSprite		// print

	sub	y, #28			// move arrow down

	b	pausenoNeedMoveMainArrow

pausemoveMainArrowDown:
				// if here, user pressed down
	ldr	r0, =78
	cmp	y, r0			// see if arrow is in the down position
	bge	pausenoNeedMoveMainArrow		// if in the down position, dont do anything
					// if here we have to move arrow up, first errase current arrow

	mov	r0, x
	mov	r1, y
	ldr	r2, =black		// sprite
	bl	printSprite		// print

	add	y, #28			// move arrow up
	b	pausenoNeedMoveMainArrow

pauseStartPressed:
	b	returnpauseMenu

pausenoNeedMoveMainArrow:
	b	pauseMenuLoop


pauseselectionMade:
	// if here, user wants to restart or quit. regardless, erase apple
	// remove current apple from screen array
	// get i and j
	ldr	r0, =appleI
	ldr	i, [r0]
	ldr	r0, =appleJ
	ldr	j, [r0]	
	// calculate offset=(32i+j)*4
	add	r0, j, i, lsl #5	// r0 = offset = 32i + j
	lsl	r0, #2			// offset = (32i+j)*4
	ldr	r1, =screen
	add	r0, r1
	ldr	r2, =background
	str	r2, [r0]

	// errase current apple from screen (overwrite with background)
	mov	r0, i
	mov	r1, j
	ldr	r2, =background
	bl	printCell

	// return value depends on whether user selected start or quit
	ldr	r0, =70
	cmp	y, r0

	bgt	beginning		// quit
	blt	start		// restart


returnpauseMenu:

	// errase menu by printing a box over it
	ldr	r0, =0x7497		// color
	push	{r0}
	ldr	r0, =450		// x
	mov	r1, #50			// y
	ldr	r2, =120		// width
	mov	r3, #65			// height
	bl	printBox	


	// wait so that when the user hits start to unpause, the same start doesnt pause
	ldr	r0, =500000
	bl	wait


	bl	enableInterrupt



	.unreq	input
	.unreq	x
	.unreq	y
	.unreq	i
	.unreq	j


	pop	{r4-r8, pc}


//------------------------------------------------------------------
.globl	enableInterrupt
enableInterrupt:
	push	{r4-r7, lr}


	//clear cs
	ldr		r4, =0x20003000
	mov		r5, #0x00000008	
	ldr		r7, [r4]
	orr		r7, r5
	str		r7, [r4]



	ldr	r4, =0x2000B210			// Enable IRQs 1
	mov	r5, #0x00000008			// bit 4 set (IRQ 3)
	str	r5, [r4]



	ldr	r4, =0x20003004		//Load clock Value
	ldr	r5, [r4]
	ldr	r7, =ValueWait		//30secs
	ldr	r4, [r7]
	add	r5, r4			//30secs ++ clock val

	ldr	r6, =0x20003018
	str	r5, [r6]		//store in System Timer Compare 3
	

	// Enable IRQ
	mrs		r7, cpsr
	bic		r7, #0x80
	msr		cpsr_c, r7


	pop	{r4-r7, pc}

//------------------------------------------------------------------
.globl	disableInterrupt
disableInterrupt:
	push	{r4, lr}

	// disable IRQ

	mrs		r4, cpsr

	orr		r4, #0x80

	msr		cpsr_c, r4


	pop	{r4, pc}
//------------------------------------------------------------------
/*
input:
	void
output:
	r0 - 1= start was selected, 2 = quit was selected
precondition:
	none
postcondition:
	the correct value is returned
*/
.globl	mainMenu
mainMenu:
	push	{r4-r6, lr}

	input	.req	r4
	x	.req	r5
	y	.req	r6



	bl	disableInterrupt


	bl	printMainMenu		// print main menu background

	ldr	x, =395
	ldr	y, =478	


mainMenuLoop:

	mov	r0, x
	mov	r1, y
	ldr	r2, =mainArrow		// sprite
	bl	printSprite		// print



	bl	readSNES			// read SNES. buttons register in r0
	bl	identifyButtonsPressed
						// return value in r0 (0, 1, 2, 3, 4, 5, 6)
	mov	input, r0			// put controller input value in r4 (input)

	cmp	input, #1			// see if user pressed up
	beq	moveMainArrowUp			// branch if so
	cmp	input, #3			// see if user pressed down
	beq	moveMainArrowDown		// branch if so
	cmp	input, #6			// see if user pressed A
	beq	selectionMade			// branch if so
	b	noNeedMoveMainArrow		// otherwise, branch


moveMainArrowUp:
					// if here, user pressed up
	ldr	r0, =478
	cmp	y, r0			// see if arrow is in the up position
	ble	noNeedMoveMainArrow		// if in the up position, dont do anything
					// if here we have to move arrow down, first errase current arrow

	mov	r0, x
	mov	r1, y
	ldr	r2, =black		// sprite
	bl	printSprite		// print

	sub	y, #73			// move arrow down

	b	noNeedMoveMainArrow

moveMainArrowDown:
				// if here, user pressed down
	ldr	r0, =551
	cmp	y, r0			// see if arrow is in the down position
	bge	noNeedMoveMainArrow		// if in the down position, dont do anything
					// if here we have to move arrow up, first errase current arrow

	mov	r0, x
	mov	r1, y
	ldr	r2, =black		// sprite
	bl	printSprite		// print

	add	y, #73			// move arrow up

noNeedMoveMainArrow:
	b	mainMenuLoop


selectionMade:
	ldr	r0, =500
	cmp	y, r0


	bllt	printInstructions


	bl	enableInterrupt



	// return value depends on whether user selected start or quit
	ldr	r0, =500
	cmp	y, r0


	movlt	r0, #1		// start
	movgt	r0, #2		// quit



	.unreq	input
	.unreq	x
	.unreq	y


	pop	{r4-r6, pc}



//------------------------------------------------------------------
/*
input:
	void
output:
	void
precondition:
	none
postcondition:
	all the walls and borders are set in the screen array
*/
.globl	setMap
setMap:
	push	{r4,lr}
	
	loopCount	.req	r4


	// WRITE BORDER CELLS TO SCREEN ARRAY

	// draw top border (do the 32 cells in a loop)
	mov	loopCount, #0	// initialize loop count

upperBorderLoop:

	mov	r0, #4		// arg 1: i (row)
	mov	r1, r4		// arg 2: j (column)
	ldr	r2, =border	// sprite ptr
	bl	writeCell	// branch to function
	
	add	loopCount, #1	// increment loop count
	cmp	loopCount, #32
	blt	upperBorderLoop	// loop


	// draw bottom border (do the 32 cells in a loop)
	mov	loopCount, #0	// initialize loop count

bottomBorderLoop:

	mov	r0, #23		// arg 1: i (row)
	mov	r1, r4		// arg 2: j (column)
	ldr	r2, =border	// sprite ptr
	bl	writeCell	// branch to function
	
	add	loopCount, #1	// increment loop count
	cmp	loopCount, #32
	blt	bottomBorderLoop	// loop

	// draw very top border (do the 32 cells in a loop). this one is just decorative
	mov	loopCount, #0	// initialize loop count

toptopBorderLoop:

	mov	r0, #0		// arg 1: i (row)
	mov	r1, r4		// arg 2: j (column)
	ldr	r2, =border	// sprite ptr
	bl	writeCell	// branch to function
	
	add	loopCount, #1	// increment loop count
	cmp	loopCount, #32
	blt	toptopBorderLoop	// loop


	// draw left vertical border (do the 32 cells in a loop)
	mov	loopCount, #0	// initialize loop count

leftVerticalBorderLoop:

	mov	r0, r4		// arg 1: i (row)
	mov	r1, #0		// arg 2: j (column)
	ldr	r2, =border	// sprite ptr
	bl	writeCell	// branch to function
	
	add	loopCount, #1	// increment loop count
	cmp	loopCount, #24
	blt	leftVerticalBorderLoop	// loop


	// draw right vertical border (do the 32 cells in a loop)
	mov	loopCount, #0	// initialize loop count

rightVerticalBorderLoop:

	mov	r0, r4		// arg 1: i (row)
	mov	r1, #31		// arg 2: j (column)
	ldr	r2, =border	// sprite ptr
	bl	writeCell	// branch to function
	
	add	loopCount, #1	// increment loop count
	cmp	loopCount, #24
	blt	rightVerticalBorderLoop	// loop



	// WRITE WALLS

	mov	r0, #6		// arg 1: i (row)
	mov	r1, #2		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #6		// arg 1: i (row)
	mov	r1, #3		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #6		// arg 1: i (row)
	mov	r1, #4		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #7		// arg 1: i (row)
	mov	r1, #2		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #8		// arg 1: i (row)
	mov	r1, #2		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #19		// arg 1: i (row)
	mov	r1, #2		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function


	mov	r0, #20		// arg 1: i (row)
	mov	r1, #2		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #21		// arg 1: i (row)
	mov	r1, #2		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #21		// arg 1: i (row)
	mov	r1, #3		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #21		// arg 1: i (row)
	mov	r1, #4		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #6		// arg 1: i (row)
	mov	r1, #27		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #6		// arg 1: i (row)
	mov	r1, #28		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #6		// arg 1: i (row)
	mov	r1, #29		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #7		// arg 1: i (row)
	mov	r1, #29		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #8		// arg 1: i (row)
	mov	r1, #29		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #19		// arg 1: i (row)
	mov	r1, #29		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #20		// arg 1: i (row)
	mov	r1, #29		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #21		// arg 1: i (row)
	mov	r1, #29		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #21		// arg 1: i (row)
	mov	r1, #28		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #21		// arg 1: i (row)
	mov	r1, #27		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #13		// arg 1: i (row)
	mov	r1, #15		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #13		// arg 1: i (row)
	mov	r1, #16		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #13		// arg 1: i (row)
	mov	r1, #17		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #15		// arg 1: i (row)
	mov	r1, #15		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #15		// arg 1: i (row)
	mov	r1, #16		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	mov	r0, #15		// arg 1: i (row)
	mov	r1, #17		// arg 2: j (column)
	ldr	r2, =wood	// sprite ptr
	bl	writeCell	// branch to function

	.unreq	loopCount
	
	pop	{r4,pc}


//-------------------------------------------------------------------

.globl	initializeStartingLives
initializeStartingLives:
	push	{lr}

	// initialize lives global var to 3
	mov	r0, #3
	ldr	r1, =lives
	str	r0, [r1]


	// print starting lives to screen (3)
	mov	r0, #'3'
	ldr	r1, =startingLivesString
	strb	r0, [r1]		// make sure starting lives is 3
	ldr	r0, =0xFFFF		// arg 5: color
	push	{r0}
	ldr	r0, =startingLivesString	// arg 1: string pointer
	ldr	r1, =startingLivesStringLength	// arg 2: we put the string length there
	mov	r2, #120		// arg 3: x
	mov	r3, #80			// arg 4: y
	bl	printString		// branch to function


	pop	{pc}



//-------------------------------------------------------------------

.section	.data



// randomNum
x_:	.int	7064
y_:	.int	10000
z_:	.int	89452
w_:	.int	689387

// spawnApple
.globl	appleI
appleI:	.int	0
.globl	appleJ
appleJ:	.int	0

// spawnDoor
.globl	doorI
doorI:	.int	0
.globl	doorJ
doorJ:	.int	0

// spawnValuePack
.globl	vpI
vpI:		.int	0
.globl	vpJ
vpJ:		.int	0
.globl	vpPresent		// 0 means vp is not present
				// 1 means vp is present (hasnt been eaten yet)
vpPresent:	.int	0

// increment score
.align	4
ascii:				// space for itoa to put its characters
	.rept	3
	.byte	0
	.endr
.align	2
aLength:
	.byte	(. - ascii)

numInAscii:
	.byte	0

// initializeStartingLives
.globl	startingLivesString
startingLivesString:	.int	0
.align	2
startingLivesStringLength:	.byte	.-startingLivesString



instructionLine1:	.ascii	"1. Use the direction pad to control the snake."
.align	2
iL1Length:	.byte	.-instructionLine1

instructionLine2:	.ascii	"2. Eating an apple will earn you one point."
.align	2
iL2Length:	.byte	.-instructionLine2

instructionLine3:	.ascii	"3. Eating a value pack will get you four points,"
.align	2
iL3Length:	.byte	.-instructionLine3

instructionLine4:	.ascii	"   but it will increase the speed of the game for a while."
.align	2
iL4Length:	.byte	.-instructionLine4

instructionLine5:	.ascii	"4. To win the game, exit through the door that will appear at 20 points."
.align	2
iL5Length:	.byte	.-instructionLine5

instructionLine6:	.ascii	"5. You have 3 lives... good luck!"
.align	2
iL6Length:	.byte	.-instructionLine6

instructionLine7:	.ascii	"Press any button to continue."
.align	2
iL7Length:	.byte	.-instructionLine7

