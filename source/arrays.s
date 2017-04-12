/*
Student:	Nicolas Gonzalez
ID:		10151261
Date:		March 2016
Course:		CPSC 359
Professor:	Jalal Kawash
TA:		Salim Afra
*/


.section	.data


// screen is 32 cells wide and 24 cells vertically.
// make a subroutine that looks at the screen array and prints all of them to the screen.

// for each of the 768 cells, allocate a word which will hold the address of the sprite that goes there
.globl	screen
screen:
	.rept	768
	.word	background
	.endr


/*
the snake can be up to 23 cells long. have a 2D array of words to represent the
position of each body piece of the snake.
[row][0] contains the i of the row'th snake piece
[row][1] contains the j of the row'th snake piece.

eg. the 2nd body piece is at (i=4, j=5)
so,
[1][0]=4
[1][1]=5

think of the array like this:

		0					1		
  -----------------------------------------------------------------------
0 |	    i of head		 	|	   j of head		|
  -----------------------------------------------------------------------
1 |	 i of second body piece	 	|	j of second body piece	|
  -----------------------------------------------------------------------
2 |					|				|
  -----------------------------------------------------------------------
3 |					|				|
  ----------------------------------------------------------------------
..|		...			|	...			|
   ---------------------------------------------------------------------|	
22|i of tail when snake is full length	|j of tail when full length	|
  ----------------------------------------------------------------------

so the array size should be width*height*size of element = 2*24*4 = 192 // do 24 instead of 23 for good measure
*/
.globl	snakeArray
snakeArray:
	.rept	192
	.word	0
	.endr


/*
this is a 1D array goes hand in hand with the snakeArray. the row number will represent the state of that body piece.
in other words, stateArray[index] contains the state that the snake was in when the head was at the position specified
in row index of the snakeArray. states are integers. 4 bytes.
the snake can be length at most 23 so let this array have 24 entries.
array size in bytes = 24*(4bytes) = 96
*/
.globl	stateArray
stateArray:
	.rept	96
	.word	0
	.endr

/*
the snake can be up to 23 cells long.
when it loses a life, we want to put it back in standard position. this array, at index "index" has a pointer to
the sprite that the body piece should be when in standard position.
one word for each snake piece. have 24 entries for safety.
*/
.globl	spriteArray
spriteArray:
	.word	frontRight	// 0
	.word	horizontal	// 1
	.word	horizontal	// 2
	.word	upRight		// 3
	.word	vertical	// 4
	.word	vertical	// 5
	.word	vertical	// 6
	.word	vertical	// 7
	.word	downLeft	// 8
	.word	downRight	// 9
	.word	vertical	// 10
	.word	vertical	// 11
	.word	vertical	// 12
	.word	vertical	// 13
	.word	vertical	// 14
	.word	vertical	// 15
	.word	vertical	// 16
	.word	vertical	// 17
	.word	upLeft		// 18
	.word	upRight		// 19
	.word	vertical	// 20
	.word	vertical	// 21
	.word	vertical	// 22
	.word	vertical	// 23
//--------------------------------------------------------
/*
input:
	r0 - body piece number (index)
	r1 - state to write
output
	void
precondition
	none
postcondition
	the state specified is written to the stateArray in row body piece number
*/
.globl	setState
setState:
	push	{r4-r7, lr}

	index		.req	r4
	address		.req	r5
	bodyPieceNumber	.req	r6
	state		.req	r7

	mov	bodyPieceNumber, r0
	mov	state, r1

	// put state in stateArray[bodyPieceNumber]
	// offset = bodyPieceNumber*4
	lsl	address, bodyPieceNumber, #2	// address = bodyPieceNumber*4
	ldr	r0, =stateArray
	add	address, r0			// address = address where we need to write state
	str	state, [address]


	.unreq	address
	.unreq	index
	.unreq	bodyPieceNumber
	.unreq	state

	pop	{r4-r7, pc}
//--------------------------------------------------------
/*
input:
	r0 - body piece number
output
	r0 - state
precondition
	none
postcondition
	the stateArray is unchanged. the entry index=body piece number is returned in r0
*/
.globl	getState
getState:
	push	{r4-r7, lr}

	index		.req	r4
	address		.req	r5
	bodyPieceNumber	.req	r6
	state		.req	r7

	mov	bodyPieceNumber, r0

	// get state from stateArray[bodyPieceNumber]
	// offset = bodyPieceNumber*4
	lsl	address, bodyPieceNumber, #2	// address = bodyPieceNumber*4
	ldr	r0, =stateArray
	add	address, r0			// address = address where we need to write state
	ldr	state, [address]

	mov	r0, state		// return value

	.unreq	address
	.unreq	index
	.unreq	bodyPieceNumber
	.unreq	state

	pop	{r4-r7, pc}
//--------------------------------------------------------
/*
input:
	none
output
	none
precondition
	none
postcondition
	the state array has been shifted down.
	i.e. stateArray[0] moved to stateArray[1] etc.
	stateArray[22] moved to stateArray[23]
*/
.globl	shiftStateArrayDown
shiftStateArrayDown:
	push	{r4-r5,lr}

	bodyPieceNumber		.req	r4
	state			.req	r5

	mov	bodyPieceNumber, #22
shiftArrayLoop1:

	// get state of body piece bodyPieceNumber
	mov	r0, bodyPieceNumber
	bl	getState
	mov	state, r0

	// put state in the array for bodyPieceNumber+1
	add	r0, bodyPieceNumber, #1
	mov	r1, state
	bl	setState
	
	sub	bodyPieceNumber, #1			// increment loopCount
	cmp	bodyPieceNumber, #0
	bge	shiftArrayLoop1

	.unreq	bodyPieceNumber
	.unreq	state

	pop	{r4-r5, pc}
//--------------------------------------------------------
/*
input:
	r0 - body piece numer (0=head, etc)
	r1 - i of snake piece
	r2 - j of snake piece
output:
	void
precondition:
	none
postcondition:
	the i and j of that snake piece have been set in the array
*/
.globl	setSnakePiecePosition
setSnakePiecePosition:
	push	{r4-r7,lr}

	bodyPieceNumber	.req	r4
	i		.req	r5
	j		.req	r6
	address		.req	r7

	mov	bodyPieceNumber, r0
	mov	i, r1
	mov	j, r2


	// put i in row=bodyPieceNumber, column=0
	// calculate offset=(2row+col)*4
	// offset = [ 2*(bodyPieceNumber)+0 ]*4
	// offset = 8*bodyPieceNumber
	lsl	address, bodyPieceNumber, #3
	ldr	r0, =snakeArray
	add	address, r0			// address = address of snakeArrayEntry where we want to store i
	str	i, [address]

	// put j in row=bodyPieceNumber, column=1
	// calculate offset=(2row+col)*4
	// offset = [ 2*(bodyPieceNumber)+1 ]*4
	lsl	address, bodyPieceNumber, #1	// address = 2*bodyPieceNumber
	add	address, #1			// address = 2*(bodyPieceNumber)+1
	lsl	address, #2			// address = [ 2*(bodyPieceNumber)+1 ]*4	
	ldr	r0, =snakeArray
	add	address, r0			// address = address of snakeArrayEntry where we want to store j
	str	j, [address]


	.unreq	bodyPieceNumber
	.unreq	i
	.unreq	j
	.unreq	address

	pop	{r4-r7,pc}
//----------------------------------------------------
/*
input:
	r0 - body piece numer (0=head, etc)
output:
	r0 - i
	r1 - j
precondition:
	the body piece i and j are set in the array
postcondition:
	the array is unchanged. the i and j at those positions has been read
*/
.globl	getSnakePiecePosition
getSnakePiecePosition:
	push	{r4-r7,lr}

	bodyPieceNumber	.req	r4
	i		.req	r5
	j		.req	r6
	address		.req	r7

	mov	bodyPieceNumber, r0


	// load i from row=bodyPieceNumber, column=0
	// calculate offset=(2row+col)*4
	// offset = [ 2*(bodyPieceNumber)+0 ]*4
	// offset = 8*bodyPieceNumber
	lsl	address, bodyPieceNumber, #3
	ldr	r0, =snakeArray
	add	address, r0			// address = address of snakeArrayEntry where we want to read i
	ldr	i, [address]

	// put j in row=bodyPieceNumber, column=1
	// calculate offset=(2row+col)*4
	// offset = [ 2*(bodyPieceNumber)+1 ]*4
	lsl	address, bodyPieceNumber, #1	// address = 2*bodyPieceNumber
	add	address, #1			// address = 2*(bodyPieceNumber)+1
	lsl	address, #2			// address = [ 2*(bodyPieceNumber)+1 ]*4	
	ldr	r0, =snakeArray
	add	address, r0			// address = address of snakeArrayEntry where we want to read j
	ldr	j, [address]

	// return values
	mov	r0, i
	mov	r1, j


	.unreq	bodyPieceNumber
	.unreq	i
	.unreq	j
	.unreq	address

	pop	{r4-r7,pc}
//----------------------------------------------------
/*
input:
	void
output:
	void
precondition:
	none
postcondition:
	considering the 2d view of the array, all entries have been shifted one row down
	i.e. the position of snake piece 1 becomes the position of snake piece 2
*/
.globl	shiftSnakeArrayDown
shiftSnakeArrayDown:
	push	{r4-r6,lr}

	bodyPieceNumber		.req	r4
	i			.req	r5
	j			.req	r6

	mov	bodyPieceNumber, #22
shiftArrayLoop:

	// get i and j of body piece bodyPieceNumber
	mov	r0, bodyPieceNumber
	bl	getSnakePiecePosition
	mov	i, r0
	mov	j, r1

	// put that i and j in the array for bodyPieceNumber+1
	add	r0, bodyPieceNumber, #1
	mov	r1, i
	mov	r2, j
	bl	setSnakePiecePosition

	
	sub	bodyPieceNumber, #1			// increment loopCount
	cmp	bodyPieceNumber, #0
	bge	shiftArrayLoop

	.unreq	bodyPieceNumber
	.unreq	i
	.unreq	j

	pop	{r4-r6, pc}
//----------------------------------------------------

