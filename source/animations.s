/*
Student:	Nicolas Gonzalez
ID:		10151261
Date:		March 2016
Course:		CPSC 359
Professor:	Jalal Kawash
TA:		Salim Afra
*/

.section .text

//---------------------------------------------------------------------
/*
input
	none
output
	none
precondition
	none
postcondition
	every snake cell is replaces by what it is in the screen array
*/
.globl	eraseSnake
eraseSnake:
	push	{r4-r8, lr}

	i			.req	r4
	j			.req	r5
	spriteToPrint		.req	r6
	length			.req	r7
	snakePieceNumber	.req	r8

	// ERRASE THE HEAD AND REPLACE IT WITH WHATEVER IT RAN INTO
	// get snake head i and j from memory
	mov	r0, #0			// arg 1: snake piece number
	bl	getSnakePiecePosition
	mov	i, r0			// move outputs into permanent places
	mov	j, r1

	// calculate offset=(32i+j)*4
	add	r0, j, i, lsl #5	// r0 = offset = 32i + j
	lsl	r0, #2			// offset = (32i+j)*4

	ldr	r1, =screen
	add	r0, r1			// r0 = address in array screen corresponding to cell (i,j)
	ldr	spriteToPrint, [r0]

	mov	r0, i			// arg1
	mov	r1, j			// arg2
	mov	r2, spriteToPrint	// arg3
	bl	printCell

	// ERRASE THE REST OF THE BODY
	// put snake length in length register
	ldr	r0, =snakeLength
	ldr	length, [r0]


	mov	snakePieceNumber, #1			// start with the second body piece
							// because we already erased the head
eraseSnakeLoop:
	// the the (i,j) of current snake piece so we can overwrite it with background
	mov	r0, snakePieceNumber
	bl	getSnakePiecePosition
	mov	i, r0
	mov	j, r1

	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	ldr	r2, =background		// arg 3
	bl	printCell

	add	snakePieceNumber, #1
	cmp	snakePieceNumber, length
	ble	eraseSnakeLoop
	

	.unreq	i
	.unreq	j
	.unreq	spriteToPrint
	.unreq	length
	.unreq	snakePieceNumber

	pop	{r4-r8, pc}
//---------------------------------------------------------------------
/*
input:
	none
output:
	none
precondition:
	we assume that the snake is supposed to start facing right
postcondition:
	snake is started facing right, of length 3 with the head at (14, 10)
*/
.globl	initSnake
initSnake:
	push	{lr}


	// initialize snake head in memory to (14, 10)
	mov	r0, #0		// arg 1: snake piece number
	mov	r1, #14		// arg 2: i
	mov	r2, #10		// arg 3: j
	bl	setSnakePiecePosition


	// print the snake
	mov	r0, #0			// arg 1: snake piece number
	bl	getSnakePiecePosition
					// i in r0 (arg1)
					// j in r1 (arg2)
	ldr	r2, =frontRight		// arg 3
	bl	printCell

	pop	{pc}

//---------------------------------------------------------------------
/*
input:
	none
output:
	none
precondition:
	we assume that the snake is supposed to start facing right
postcondition:
	snake is started facing right, of length 3 with the head at (14, 10)
*/
.globl	initTail
initTail:
	push	{r4-r6, lr}

	length		.req	r4
	i		.req	r5
	j		.req	r6

	mov	length, #2			// initialize lenth to 2 (length is 3, but what we mean is
						// that the tail (i,j) is at row 2 of snakeArray)
	ldr	r0, =snakeLength
	str	length, [r0]			// store it to the global var

	// find the position of body piece number 2
	mov	r0, #2
	bl	getSnakePiecePosition
	mov	i, r0
	mov	j, r1

	// print the tail
	mov	r0, i
	mov	r1, j
	ldr	r2, =endRight
	bl	printCell

	// fill in the cell between the tail and the head
	mov	r0, #14
	mov	r1, #9
	ldr	r2, =horizontal
	bl	printCell
	

	.unreq	length
	.unreq	i
	.unreq	j

	pop	{r4-r6, pc}

//---------------------------------------------------------------------
/*
input:
	none
output:
	none
precondition:
	we assume that the snake is supposed to start facing right
postcondition:
	the positions of the snakeArray are set in the way that we want the snake to reset each
	time it loses a life.
*/
.globl	initSnakeArray
initSnakeArray:
	push	{lr}

	// head:
	mov	r0, #0		// arg 1: snake piece number
	mov	r1, #14		// arg 2: i
	mov	r2, #10		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #1		// arg 1: snake piece number
	mov	r1, #14		// arg 2: i
	mov	r2, #9		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #2		// arg 1: snake piece number
	mov	r1, #14		// arg 2: i
	mov	r2, #8		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #3		// arg 1: snake piece number
	mov	r1, #14		// arg 2: i
	mov	r2, #7		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #4		// arg 1: snake piece number
	mov	r1, #13		// arg 2: i
	mov	r2, #7		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #5		// arg 1: snake piece number
	mov	r1, #12		// arg 2: i
	mov	r2, #7		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #6		// arg 1: snake piece number
	mov	r1, #11		// arg 2: i
	mov	r2, #7		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #7		// arg 1: snake piece number
	mov	r1, #10		// arg 2: i
	mov	r2, #7		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #8		// arg 1: snake piece number
	mov	r1, #9		// arg 2: i
	mov	r2, #7		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #9		// arg 1: snake piece number
	mov	r1, #9		// arg 2: i
	mov	r2, #6		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #10		// arg 1: snake piece number
	mov	r1, #10		// arg 2: i
	mov	r2, #6		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #11		// arg 1: snake piece number
	mov	r1, #11		// arg 2: i
	mov	r2, #6		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #12		// arg 1: snake piece number
	mov	r1, #12		// arg 2: i
	mov	r2, #6		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #13		// arg 1: snake piece number
	mov	r1, #13		// arg 2: i
	mov	r2, #6		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #14		// arg 1: snake piece number
	mov	r1, #14		// arg 2: i
	mov	r2, #6		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #15		// arg 1: snake piece number
	mov	r1, #15		// arg 2: i
	mov	r2, #6		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #16		// arg 1: snake piece number
	mov	r1, #16		// arg 2: i
	mov	r2, #6		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #17		// arg 1: snake piece number
	mov	r1, #17		// arg 2: i
	mov	r2, #6		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #18		// arg 1: snake piece number
	mov	r1, #18		// arg 2: i
	mov	r2, #6		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #19		// arg 1: snake piece number
	mov	r1, #18		// arg 2: i
	mov	r2, #5		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #20		// arg 1: snake piece number
	mov	r1, #17		// arg 2: i
	mov	r2, #5		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #21		// arg 1: snake piece number
	mov	r1, #16		// arg 2: i
	mov	r2, #5		// arg 3: j
	bl	setSnakePiecePosition

	mov	r0, #22		// arg 1: snake piece number
	mov	r1, #15		// arg 2: i
	mov	r2, #5		// arg 3: j
	bl	setSnakePiecePosition


	pop	{pc}
//---------------------------------------------------------------------
/*
input:
	none
output:
	none
precondition:
	we assume that the snake is supposed to start facing right
postcondition:
	the positions of the snakeArray are set in the way that we want the snake to reset each
	time it loses a life.
*/
.globl	initStateArray
initStateArray:
	push	{lr}

	// head:
	mov	r0, #0		// arg 1: snake piece number
	mov	r1, #2		// arg 2: state
	bl	setState

	mov	r0, #1		// arg 1: snake piece number
	mov	r1, #2		// arg 2
	bl	setState

	mov	r0, #2		// arg 1: snake piece number
	mov	r1, #2		// arg 2

	bl	setState

	mov	r0, #3		// arg 1: snake piece number
	mov	r1, #2		// arg 2
	bl	setState

	mov	r0, #4		// arg 1: snake piece number
	mov	r1, #3		// arg 2
	bl	setState

	mov	r0, #5		// arg 1: snake piece number
	mov	r1, #3		// arg 2
	bl	setState

	mov	r0, #6		// arg 1: snake piece number
	mov	r1, #3		// arg 2
	bl	setState

	mov	r0, #7		// arg 1: snake piece number
	mov	r1, #3		// arg 2
	bl	setState

	mov	r0, #8		// arg 1: snake piece number
	mov	r1, #3		// arg 2
	bl	setState

	mov	r0, #9		// arg 1: snake piece number
	mov	r1, #1		// arg 2
	bl	setState

	mov	r0, #10		// arg 1: snake piece number
	mov	r1, #1		// arg 2
	bl	setState

	mov	r0, #11		// arg 1: snake piece number
	mov	r1, #1		// arg 2
	bl	setState

	mov	r0, #12		// arg 1: snake piece number
	mov	r1, #1		// arg 2
	bl	setState

	mov	r0, #13		// arg 1: snake piece number
	mov	r1, #1		// arg 2
	bl	setState

	mov	r0, #14		// arg 1: snake piece number
	mov	r1, #1		// arg 2
	bl	setState

	mov	r0, #15		// arg 1: snake piece number
	mov	r1, #1		// arg 2
	bl	setState

	mov	r0, #16		// arg 1: snake piece number
	mov	r1, #1		// arg 2
	bl	setState

	mov	r0, #17		// arg 1: snake piece number
	mov	r1, #1		// arg 2
	bl	setState

	mov	r0, #18		// arg 1: snake piece number
	mov	r1, #1		// arg 2
	bl	setState

	mov	r0, #19		// arg 1: snake piece number
	mov	r1, #2		// arg 2
	bl	setState

	mov	r0, #20		// arg 1: snake piece number
	mov	r1, #3		// arg 2
	bl	setState

	mov	r0, #21		// arg 1: snake piece number
	mov	r1, #3		// arg 2
	bl	setState

	mov	r0, #22		// arg 1: snake piece number
	mov	r1, #3		// arg 2
	bl	setState


	pop	{pc}

//---------------------------------------------------------------------
/*
input:
	none
output:
	none
precondition:
	we assume that the snakeArray and the stateArray are in their standard position (have just been initialized)
postcondition:
	snake drawn in standard position without changing its current length
*/

.globl	snakeStandardPosition
snakeStandardPosition:
	push	{r4-r10, lr}

	i			.req	r4
	j			.req	r5
	spriteToPrint		.req	r6
	length			.req	r7
	snakePieceNumber	.req	r8
	spriteArrayBaseAddress	.req	r9
	state			.req	r10


	ldr	spriteArrayBaseAddress, =spriteArray

	// initialize snake head in memory to (14, 10)
	mov	r0, #14			// arg 1: 1
	mov	r1, #10			// arg 2: j
	ldr	r2, =frontRight		// arg 3
	bl	printCell


	// DRAW THE REST OF THE BODY
	// put snake length in length register
	ldr	r0, =snakeLength
	ldr	length, [r0]


	mov	snakePieceNumber, #1			// start with the second body piece
							// because we already erased the head
snakeStandardPositionLoop:
	// get position of snakePiece number
	mov	r0, snakePieceNumber	// arg 1
	bl	getSnakePiecePosition
	mov	i, r0
	mov	j, r1

	// print the sprite in the sprite array at that position
	lsl	r0, snakePieceNumber, #2	// r0 = 4*snakePieceNumber
	add	r0, spriteArrayBaseAddress
	ldr	r2, [r0]
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	bl	printCell


	add	snakePieceNumber, #1
	sub	r0, length, #1
	cmp	snakePieceNumber, r0
	ble	snakeStandardPositionLoop


	// DRAW THE TAIL
	mov	r0, length		// arg 1: body piece number. length means the last one. the tail
	bl	getSnakePiecePosition
	mov	i, r0
	mov	j, r1

	mov	r0, length		// arg 1
	bl	getState
	mov	state, r0

	cmp	state, #1
	beq	up2			// branch to up if state is 1
	cmp	state, #2
	beq	right2			// branch to right if state is 2
	cmp	state, #3
	beq	down2			// branch to down if state is 3
	cmp	state, #4
	beq	left2			// branch to left if state is 4
	b	returnSnakeStandardPosition
up2:
	mov	r0, i
	mov	r1, j
	ldr	r2, =endUp
	bl	printCell
	b	returnSnakeStandardPosition
right2:
	mov	r0, i
	mov	r1, j
	ldr	r2, =endRight
	bl	printCell
	b	returnSnakeStandardPosition
down2:
	mov	r0, i
	mov	r1, j
	ldr	r2, =endDown
	bl	printCell
	b	returnSnakeStandardPosition
left2:
	mov	r0, i
	mov	r1, j
	ldr	r2, =endLeft
	bl	printCell
	b	returnSnakeStandardPosition

	
	


returnSnakeStandardPosition:
	.unreq	i
	.unreq	j
	.unreq	spriteToPrint
	.unreq	length
	.unreq	snakePieceNumber
	.unreq	spriteArrayBaseAddress
	.unreq	state

	pop	{r4-r10, pc}

//---------------------------------------------------------------------
/*
input:
	r0 - state ( 1=up, 2=right, 3=down, 4=left )
	r1 - previous state
output:
	r0 - 0 = you didnt lose. 1 = ran into something (you lose)
precondition:
	snake is initialized, state is valid
postcondition:
	snake is moved by one cell in the direction of the state
	i and j values of head in snakeArray are updated and the whole array is shifted down. the tail is also updated.
*/
.globl	updateSnake
updateSnake:
	push	{r4-r8, lr}
	state		.req	r4
	i		.req	r5
	j		.req	r6
	returnVal	.req	r7
	temp		.req	r8
	previousState	.req	r9


	mov	state, r0		// put arg1 in state
	mov	previousState, r1	// put arg2 in previous state

	mov	r0, #0			// arg 1: snake piece number
	bl	getSnakePiecePosition
	mov	i, r0			// move outputs into permanent places
	mov	j, r1



	// check if cell (i, j) in the screen array is wall or border. if so, you lose. return 1.
	// if cell (i,j) is an apple, do corresponding things for when you eat an apple:
	// calculate offset
	add	r3, j, i, lsl #5	// r3=offset = 32i + j
	lsl	r3, #2			// offset = (32i+j)*4
	// load cell (i,j) from screen array	
	ldr	r0, =screen		// r0 = address of screen array
	add	r0, r0, r3		// r0 = address of word corresponding to cell (i,j)
	ldr	temp, [r0]		// temp = address of sprite at cell (i,j)
	ldr	r1, =wood		// r1 = address of wood/wall sprite
	cmp	temp, r1		// compare see if the cell the snake is moving in to is a wall cell
	moveq	returnVal, #1		// if wood, you lose. set you lose value, and return.
	beq	returnUpdateSnake
	ldr	r1, =border		// r1 = address of border sprite
	cmp	temp, r1		// compare see if the cell the snake is moving in to is a border cell
	moveq	returnVal, #1		// if border, you lose. set you lose value, and return.
	beq	returnUpdateSnake
	// now check if we are moving into a cell that contains a snake piece
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	bl	checkForSnakeCollision
	cmp	r0, #1			// see if collision flag is set
	moveq	returnVal, #1
	beq	returnUpdateSnake

	// if here, the cell we are moving into is either an apple or just background. see if its an apple
	ldr	r1, =circle		// r1 = address of circle/apple sprite
	cmp	temp, r1		// compare see if the cell the snake is moving in to is an apple cell
	bne	movingIntoBackgroundCell	// if not an apple, it must be just a backgound cell
	// if here, its an apple we are moving into
	// increment score, spawn apple, and overwrite apple in screen array with background.
	// and increment the global length array
	ldr	r0, =snakeLength
	ldr	r1, [r0]	// load length from memory
	add	r1, #1		// increment
	str	r1, [r0]	// store back in memory
	// increment score
	bl	incrementScore
	// overwrite apple in screen array with background
	mov	r0, i
	mov	r1, j
	ldr	r2, =background
	bl	writeCell
	// spawn apple if the score is less than 20
	ldr	r0, =score
	ldr	r1, [r0]	// score in r1
	cmp	r1, #20
	bllt	spawnApple

movingIntoBackgroundCell:
	// if here, the cell we are moving into is allowed (it is currently background or apple)
	// before we draw the new head, replace the current head with the correct body piece
	mov	r0, state		// arg 1
	mov	r1, previousState	// arg 2
	mov	r2, i			// arg 3
	mov	r3, j			// arg 4
	bl	drawBodyPiece
	// also, we are about to change the head (i,j) in the snakeArray
	// so before we do that, shift the whole array down
	bl	shiftSnakeArrayDown
	// draw new head
	cmp	state, #1
	beq	up			// branch to up if state is 1
	cmp	state, #2
	beq	right			// branch to right if state is 2
	cmp	state, #3
	beq	down			// branch to down if state is 3
	cmp	state, #4
	beq	left			// branch to left if state is 4
	b	returnUpdateSnake	
up:

	// update i in memory:
	sub	i, #1			// update i
	mov	r0, #0			// arg 1: body piece number
	mov	r1, i			// arg 2
	mov	r2, j			// arg 3
	bl	setSnakePiecePosition

	// write head in new location
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	mov	r2, state		// arg 3
	bl	printHead		// call function

	mov	returnVal, #0			// return value
	b	returnUpdateSnake	
right:

	// update i in memory:
	add	j, #1			// update i
	mov	r0, #0			// arg 1: body piece number
	mov	r1, i			// arg 2
	mov	r2, j			// arg 3
	bl	setSnakePiecePosition

	// write head in new location
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	mov	r2, state		// arg 3
	bl	printHead		// call function

	mov	returnVal, #0			// return value
	b	returnUpdateSnake	
down:

	// update i in memory:
	add	i, #1			// update i
	mov	r0, #0			// arg 1: body piece number
	mov	r1, i			// arg 2
	mov	r2, j			// arg 3
	bl	setSnakePiecePosition

	// write head in new location
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	mov	r2, state		// arg 3
	bl	printHead		// call function

	mov	returnVal, #0			// return value
	b	returnUpdateSnake	
left:

	// update i in memory:
	sub	j, #1			// update i
	mov	r0, #0			// arg 1: body piece number
	mov	r1, i			// arg 2
	mov	r2, j			// arg 3
	bl	setSnakePiecePosition

	// write head in new location
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	mov	r2, state		// arg 3
	bl	printHead		// call function

	mov	returnVal, #0			// return value
	b	returnUpdateSnake	


returnUpdateSnake:
	.unreq	state
	.unreq	i
	.unreq	j
	.unreq	returnVal
	.unreq	temp
	.unreq	previousState

	mov	r0, r7		// return value

	pop	{r4-r8, pc}

//-------------------------------------------------------------------------
/*
input
	none (but this subroutine will read and use the global variable length)
output
	none
precondition
	snakeArray is properly set
postcondition
	snake cleans up after the body
*/
.globl	updateTail
updateTail:
	push	{r4-r7, lr}
	length		.req	r4
	i		.req	r5
	j		.req	r6
	state		.req	r7

	// get length from memory
	ldr	r0, =snakeLength
	ldr	length, [r0]

	// print background in the position specified by length+1
	add	r0, length, #1		// r0 = length+1
	bl	getSnakePiecePosition
	mov	i, r0
	mov	j, r1
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	ldr	r2, =background
	bl	printCell

	// get position specified in the snakeArray
	mov	r0, length
	bl	getSnakePiecePosition
	mov	i, r0
	mov	j, r1

	// print the tail at the position specified in the snakeArray in row length
	// but to know which tail to draw, we need to know what the state of that body piece is
	mov	r0, length		// arg 1: body piece number
	bl	getState
	mov	state, r0		// out the output in state

	// now depending on what the state of the snake was at that point, we print the correct tail
	cmp	state, #1		// see if state is up
	beq	up1
	cmp	state, #2		// see if state is right
	beq	right1
	cmp	state, #3		// see if state is down
	beq	down1
	cmp	state, #4		// see if state is left
	beq	left1
	b	returnUpdateTail

up1:
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	ldr	r2, =endUp		// arg 3
	bl	printCell
	b	returnUpdateTail
right1:
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	ldr	r2, =endRight		// arg 3
	bl	printCell
	b	returnUpdateTail
down1:
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	ldr	r2, =endDown		// arg 3
	bl	printCell
	b	returnUpdateTail
left1:
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	ldr	r2, =endLeft		// arg 3
	bl	printCell
	b	returnUpdateTail



returnUpdateTail:
	.unreq	length
	.unreq	i
	.unreq	j
	.unreq	state

	pop	{r4-r7, pc}

//-------------------------------------------------------------------------
/*
input:
	r0 - state ( 1=up, 2=right, 3=down, 4=left )
	r1 - previous state
	r2 - i (row to draw body piece)
	r3 - j (column to draw body piece)
output:
	none
precondition:
	state and previous state are correct.
	i and j (r2 and r3) specify the place to draw the body piece
postcondition:
	the correct body piece according to previous and current state is drawn
*/
.globl	drawBodyPiece
drawBodyPiece:

	push	{r4-r7, lr}

	state		.req	r4
	previousState	.req	r5
	i		.req	r6
	j		.req	r7

	// put args in their place
	mov	state, r0
	mov	previousState, r1
	mov	i, r2
	mov	j, r3


	cmp	state, #1
	beq	stateIsUp			// branch to up if state is 1
	cmp	state, #2
	beq	stateIsRight			// branch to right if state is 2
	cmp	state, #3
	beq	stateIsDown			// branch to down if state is 3
	cmp	state, #4
	beq	stateIsLeft			// branch to left if state is 4
	b	returnDrawBodyPiece
	
stateIsUp:
	cmp	previousState, #1
	beq	drawVertical
	cmp	previousState, #2
	beq	drawUpLeft
	cmp	previousState, #3
	beq	returnDrawBodyPiece
	cmp	previousState, #4
	beq	drawUpRight
	b	returnDrawBodyPiece


stateIsRight:
	cmp	previousState, #1
	beq	drawDownRight
	cmp	previousState, #2
	beq	drawHorizontal
	cmp	previousState, #3
	beq	drawUpRight
	cmp	previousState, #4
	beq	returnDrawBodyPiece
	b	returnDrawBodyPiece


stateIsDown:
	cmp	previousState, #1
	beq	returnDrawBodyPiece
	cmp	previousState, #2
	beq	drawDownLeft
	cmp	previousState, #3
	beq	drawVertical
	cmp	previousState, #4
	beq	drawDownRight
	b	returnDrawBodyPiece


stateIsLeft:
	cmp	previousState, #1
	beq	drawDownLeft
	cmp	previousState, #2
	beq	returnDrawBodyPiece
	cmp	previousState, #3
	beq	drawUpLeft
	cmp	previousState, #4
	beq	drawHorizontal
	b	returnDrawBodyPiece


	b	returnDrawBodyPiece

drawVertical:
	mov	r0, i				// arg 1
	mov	r1, j				// arg 2
	ldr	r2, =vertical			// arg 3
	bl	printCell
	b	returnDrawBodyPiece
drawUpRight:
	mov	r0, i				// arg 1
	mov	r1, j				// arg 2
	ldr	r2, =upRight			// arg 3
	bl	printCell
	b	returnDrawBodyPiece
drawUpLeft:
	mov	r0, i				// arg 1
	mov	r1, j				// arg 2
	ldr	r2, =upLeft			// arg 3
	bl	printCell
	b	returnDrawBodyPiece
drawHorizontal:
	mov	r0, i				// arg 1
	mov	r1, j				// arg 2
	ldr	r2, =horizontal			// arg 3
	bl	printCell
	b	returnDrawBodyPiece
drawDownLeft:
	mov	r0, i				// arg 1
	mov	r1, j				// arg 2
	ldr	r2, =downLeft			// arg 3
	bl	printCell
	b	returnDrawBodyPiece
drawDownRight:
	mov	r0, i				// arg 1
	mov	r1, j				// arg 2
	ldr	r2, =downRight			// arg 3
	bl	printCell
	b	returnDrawBodyPiece




returnDrawBodyPiece:

	.unreq	state
	.unreq	previousState
	.unreq	i
	.unreq	j

	pop	{r4-r7, pc}
//-------------------------------------------------------------------------

.section	.data

