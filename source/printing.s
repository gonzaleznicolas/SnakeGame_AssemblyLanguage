/*
Student:	Nicolas Gonzalez
ID:		10151261
Date:		March 2016
Course:		CPSC 359
Professor:	Jalal Kawash
TA:		Salim Afra
*/

.section	.text
//-----------------------------------------------------------------------------
/*
input
	none
output
	none
precondition
	none
postcondition
	"Score:" and "Lives:" and "Created by: .." are printed to the screen
*/
.globl	printDetails
printDetails:
	push	{lr}

	// "SCORE:"
	ldr	r0, =0xFFFF		// arg 5: color
	push	{r0}
	ldr	r0, =scoreString	// arg 1: string pointer
	ldr	r1, =sSLength		// arg 2: string length pointer
	mov	r2, #50			// arg 3: x
	mov	r3, #50			// arg 4: y
	bl	printString

	// "LIVES:"
	ldr	r0, =0xFFFF		// arg 5: color
	push	{r0}
	ldr	r0, =livesString	// arg 1: string pointer
	ldr	r1, =lSLength		// arg 2: string length pointer
	mov	r2, #50			// arg 3: x
	mov	r3, #80			// arg 4: y
	bl	printString

	// "Created by: .."
	ldr	r0, =0xFFFF		// arg 5: color
	push	{r0}
	ldr	r0, =creatorName	// arg 1: string pointer
	ldr	r1, =cNLength		// arg 2: string length pointer
	ldr	r2, =700		// arg 3: x
	mov	r3, #50			// arg 4: y
	bl	printString

	pop	{pc}


//-----------------------------------------------------------------------------
/*
input:
	r0 - i
	r1 - j
	r2 - state (1, 2, 3, 4)
output: 
	void
precondition
	inputs are correct
output:
	snake head is printed in the indicated cell in the correct direction
*/
.globl	printHead
printHead:
	push	{r4-r6,lr}

	i	.req	r4
	j	.req	r5
	state	.req	r6

	mov	i, r0
	mov	j, r1
	mov	state, r2

	cmp	state, #1		// see if state is up
	beq	pHUp
	cmp	state, #2		// see if state is right
	beq	pHRight
	cmp	state, #3		// see if state is down
	beq	pHDown
	cmp	state, #4		// see if state is left
	beq	pHLeft
	b	returnPrintHead

pHUp:
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	ldr	r2, =frontUp		// arg 3
	bl	printCell		// call function

	b	returnPrintHead
pHRight:
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	ldr	r2, =frontRight		// arg 3
	bl	printCell		// call function

	b	returnPrintHead
pHDown:
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	ldr	r2, =frontDown		// arg 3
	bl	printCell		// call function

	b	returnPrintHead
pHLeft:
	mov	r0, i			// arg 1
	mov	r1, j			// arg 2
	ldr	r2, =frontLeft		// arg 3
	bl	printCell		// call function

	b	returnPrintHead

returnPrintHead:
	.unreq	i
	.unreq	j
	.unreq	state

	pop	{r4-r6,pc}
//-----------------------------------------------------------------------------
/*
input
	void
output
	void
precondition
	none
postcondition
	start menu printed to screen
*/
.globl	printMainMenu
printMainMenu:
	push	{lr}

	ldr	r0, =black
	bl	coverScreen


	ldr	r0, =0xFFFF
	push	{r0}				// arg 5: color
	ldr	r0, =mainMenuInstruction	// arg 1
	ldr	r1, =mMILength			// arg 2
	ldr	r2, =275			// arg 3: x
	ldr	r3, =625			// arg 4: y
	bl	printString
	

	mov	r0, #150
	mov	r1, #150
	ldr	r2, =mainMenuSprite
	bl	printSprite		// comment to get rid of load time

	pop	{pc}

//-----------------------------------------------------------------------------

/*
input
	void
output
	void
precondition
	none
postcondition
	pause menu printed to screen
*/
.globl	printPauseMenu
printPauseMenu:
	push	{lr}


	ldr	r0, =450
	ldr	r1, =50
	ldr	r2, =pauseMenuSprite
	bl	printSprite

	pop	{pc}


//-----------------------------------------------------------------------------
/*
the screen has 768 32x32px cells. 32 columns, 24 rows.
give each cell a pair (row, column) or (vertical, horizontal) or (i, j).
top left: (0,0)
top right: (0, 31)
bottom left: (23, 0)
bottom right: (23, 31)


input:
	r0 - i (row)
	r1 - j (column)
	r2 - pointer to 32x32px sprite
output:
	void
precondition:
	0<=i<=23, 0<=j<=31
	r2 points to a 32x32px sprite
postcondition:
	the sprite is written to the screen array
*/
.globl	writeCell
writeCell:
	push	{r4-r7, lr}

	i		.req	r4
	j		.req	r5
	offset		.req	r6
	spritePtr	.req	r7
	
	mov	i, r0
	mov	j, r1
	mov	spritePtr, r2
	

	// calculate offset=(32i+j)*4
	add	offset, j, i, lsl #5	// offset = 32i + j
	lsl	offset, #2		// offset = (32i+j)*4
	
	// write sprite to screen array

	ldr	r0, =screen		// ptr to screen array base address in r0
	str	spritePtr, [r0, offset]	// write to array


	.unreq	i
	.unreq	j
	.unreq	offset
	.unreq	spritePtr

	pop	{r4-r7,pc}

//-----------------------------------------------------------------------------
/*
the screen has 768 32x32px cells. 32 columns, 24 rows.
give each cell a pair (row, column) or (vertical, horizontal) or (i, j).
top left: (0,0)
top right: (0, 31)
bottom left: (23, 0)
bottom right: (23, 31)


input:
	r0 - i (row)
	r1 - j (column)
	r2 - pointer to 32x32px sprite
output:
	void
precondition:
	0<=i<=23, 0<=j<=31
	r2 points to a 32x32px sprite
postcondition:
	the sprite is printed to the correct position
*/
.globl	printCell
printCell:
	push	{lr}
	mov	r3, r0		// put i in temp
	lsl	r0, r1, #5	// arg 1: 32*j
	lsl	r1, r3, #5	// arg 2: 32*i
	bl	printSprite

	pop	{pc}

//-----------------------------------------------------------------------------
/*
input
	null
output
	null
precondition
	there is a global section of memory with a label "screen" which is 768 words long.
	at each word, there is the address of a 32x32 pixel sprite
postcondition
	the sprites are printed to the screen
*/
/*
-there are 768 cells on the screen (32x32 pixel cells).
-there are 24 rows of cells and 32 columns of cells.
-each cell can be labeled as [row][column] or [i][j] (where rows and columns start at 0).
-the the bottom right cell is [23][31]
-to draw a 32x32 pixel sprite to a cell, you need the (x,y) coordinate of the top right pixel of the cell.
	x-coordinate = j * 32
	y-coordinate = i * 32
-the screen 1D array has a word for each cell. the word is a pointer to the sprite.
- we can arrive at the memory location with the offset=(32*i + j)*4
*/
.globl printScreen
printScreen:
	push	{r4-r6,lr}


	i		.req	r4
	j		.req	r5
	offset		.req	r6
	
	mov	i, #0		// initialize outer loop count

i_loop:
	
	mov	j, #0		// initialize inner loop count
j_loop:
	
	// calculate offset=(32i+j)*4
	
	
	add	offset, j, i, lsl #5	// offset = 32i + j
	lsl	offset, #2		// offset = (32i+j)*4


	ldr	r0, =screen		// get screen pointer
	ldr	r2, [r0, offset]	// 3rd arg of printSprite pointer. load it into r2
	
	lsl	r0, j, #5		// 1st arg: x-coordinate = j * 32
	lsl	r1, i, #5		// 2nd arg: y-coordinate = i * 32

	bl	printSprite

	
	add	j, #1		// increment inner loop count
	cmp	j, #32		// compare loop count to 32
	blt	j_loop		// loop on <


	add	i, #1		// increment outer loop count
	cmp	i, #24		// compare loop count to 24
	blt	i_loop		// loop on <



	

	.unreq	i
	.unreq	j
	.unreq	offset
	

	pop	{r4-r6,pc}

//-----------------------------------------------------------------------------
/*
input
	none
output
	none
precondition
	none
postcondition
	score global variable is set to 0
	0 is printed to the screen
*/
.globl	initializeStartingScore
initializeStartingScore:
	push	{lr}

	// initialize starting score global var to 0
	ldr	r1, =score
	mov	r0, #0
	str	r0, [r1]


	// print starting score to screen (0)
	mov	r0, #'0'
	ldr	r1, =startingScore
	strb	r0, [r1]		// make sure starting score is 0
	ldr	r0, =0xFFFF		// arg 5: color
	push	{r0}
	ldr	r0, =startingScore		// arg 1: string pointer
	ldr	r1, =startingScoreLength	// arg 2: we put the string length there
	mov	r2, #120		// arg 3: x
	mov	r3, #50			// arg 4: y
	bl	printString		// branch to function

	pop	{pc}



//-----------------------------------------------------------------------------
/*
input
	r0 - sprite pointer
output
	null
precondition
	r0 holds pointer to srite pointer
postcondition
	the screen is covered in sprites of the one passed in
*/
.globl coverScreen
coverScreen:
	push	{r4-r6,lr}
	
	
	i		.req	r4
	j		.req	r5
	spritePointer	.req	r6

	mov	spritePointer, r0
	
	mov	i, #0		// initialize outer loop count

i_loop1:
	
	mov	j, #0		// initialize inner loop count
j_loop1:

	
	lsl	r0, j, #5		// 1st arg: x-coordinate = j * 32
	lsl	r1, i, #5		// 2nd arg: y-coordinate = i * 32
	mov	r2, spritePointer
	bl	printSprite

	
	add	j, #1		// increment inner loop count
	cmp	j, #32		// compare loop count to 32
	blt	j_loop1		// loop on <


	add	i, #1		// increment outer loop count
	cmp	i, #24		// compare loop count to 24
	blt	i_loop1		// loop on <
	

	.unreq	i
	.unreq	j
	.unreq	spritePointer
	

	pop	{r4-r6,pc}

//-----------------------------------------------------------------------------
/*
input
	r0 - pointer to string
	r1 - pointer to where string length is stored
	r2 - x coordinate
	r3 - y coordinate
	on stack - color
output
	void
precondition
	inputs are properly satisfied
postcondition
	string is printed on screen at coordinates specified
*/
.globl printString
printString:
	pop	{r4}		// color in r4
	push	{r4-r9, lr}
	
	color		.req	r4
	stringPointer	.req	r5
	stringLength	.req	r6
	x		.req	r7
	y		.req	r8
	loopCount	.req	r9
	
	mov	stringPointer, r0		// string pointer in r5
	ldrb	stringLength, [r1]		// string length in r6
	mov	x, r2
	mov	y, r3

	mov	loopCount, #0		// initialize loop count
stringLoop:
	

	ldrb	r0, [stringPointer]	// arg 1
	add	stringPointer, #1

	mov	r1, x			// arg 2
	add	x, #10			// move x coordinate over by 10 pixels for next character

	mov	r2, y			// arg 3
	mov	r3, color		// arg 4

	bl	DrawChar

	add	loopCount, #1			// increment loop count
	cmp	loopCount, stringLength		// compare loop count with stringLength
	blt	stringLoop			// loop if loop count < string length


	.unreq	color
	.unreq	stringPointer
	.unreq	stringLength
	.unreq	x
	.unreq	y
	.unreq	loopCount

	pop	{r4-r9, pc}


//-----------------------------------------------------------------------------

/*
input:
	r0 - x coordinate where top left corner of sprite will go
	r1 - y coordinate where top left corner of sprite will go
	r2 - sprite pointer
output: void
precondition:
	at r2, there is a sprite of the dimensions specified.
	at address r2-8, there is the .int horizontal dimension of the sprite
	at address r2-4, there is the .int vertical dimension of the sprite
postcondition:
	sprite is printed at the coordinates specified
*/
.globl printSprite
printSprite:
	push	{r4-r10, lr}
	
	spritePointer		.req	r4
	xcoordinate		.req	r5
	ycoordinate		.req	r6
	xoffset			.req	r7
	yoffset			.req	r8
	spritePointerPermanent	.req	r9
	temp			.req	r10
	
	// put args in safe registers
	mov	xcoordinate, r0
	mov	ycoordinate, r1
	mov	spritePointer, r2
	mov	spritePointerPermanent, r2
	
	// initialize offsets to 0
	mov	xoffset, #0
	mov	yoffset, #0

printSpriteLoop:
	add	r0, xcoordinate, xoffset	// arg 1
	add	r1, ycoordinate, yoffset	// arg 2
	ldr	r2, [spritePointer], #2		// arg 3. increment spritePointer by 2 bytes
						// since each collor is a halfword
	
	bl	DrawPixel
	add	xoffset, #1

	// compare x offset to sprite's x dimension
	ldr	temp, [spritePointerPermanent, #-8]
	cmp	xoffset, temp
	blt	printSpriteLoop			// loop if we are not done drawing this line of pixels
						// dont loop if we are done this line of pixels
	// new line of pixels (increment yoffset, xoffset=0)
	mov	xoffset, #0
	add	yoffset, #1
	
	// compare y offset to sprite's y dimension
	ldr	temp, [spritePointerPermanent, #-4]
	cmp	yoffset, temp
	blt	printSpriteLoop			// loop if we are not done drawing this line of pixels
						// dont loop if we are done this line of pixels

	
	.unreq	spritePointer
	.unreq	xcoordinate
	.unreq	ycoordinate
	.unreq	xoffset
	.unreq	yoffset
	.unreq	spritePointerPermanent
	.unreq	temp
		
	pop	{r4-r10, pc}


//-----------------------------------------------------------------------------

/*
input:
	r0 - x coordinate where top left corner of sprite will go
	r1 - y coordinate where top left corner of sprite will go
	r2 - width (in pixels)
	r3 - height (in pixels)
	on stack: color
output: void
precondition:
	none
postcondition:
	box with input characteristics is printed to the screen
*/
.globl printBox
printBox:
	pop	{r8}		// put color in r8
	push	{r4-r10, lr}
	x	.req	r4
	y	.req	r5
	width	.req	r6
	height	.req	r7
	color	.req	r8
	loop11Count	.req	r9
	loop22Count	.req	r10

	mov	x, r0
	mov	y, r1
	mov	width, r2
	mov	height, r3

	mov	loop11Count, #0
loop11:


	mov	loop22Count, #0
loop22:
	add	r0, x, loop22Count
	add	r1, y, loop11Count
	mov	r2, color
	bl	DrawPixel
	
	add	loop22Count, #1		// increment
	cmp	loop22Count, width
	blt	loop22


	add	loop11Count, #1		// increment
	cmp	loop11Count, height
	blt	loop11


	.unreq	x
	.unreq	y
	.unreq	width
	.unreq	height
	.unreq	color
	.unreq	loop11Count
	.unreq	loop22Count

		
	pop	{r4-r10, pc}


//-----------------------------------------------------------------------------

/*
 input:
	r0 - character to write
	r1 - px (x coordinate)
	r2 - py (y coordinate)
	r3 - color
 output:
	void
precondition: inputs are properly set
postconditon: character is printed to the screen	
 */
.globl DrawChar
DrawChar:
	push	{r4-r9, lr}

	chAdr		.req	r4
	px		.req	r5
	py		.req	r6
	row		.req	r7
	mask		.req	r8
	character	.req	r9
	color		.req	r10

	mov	r9, r0			// character in r9
	mov	r10, r3			// color in r10
	
	// put parameters px and py in memory since we dont have enough registers
	ldr	r0, =pxDrawChar
	str	r1, [r0]
	ldr	r0, =pyDrawChar
	str	r2, [r0]
	
	
	ldr	chAdr, =font		// load the address of the font map
	mov	r0, r9			// load the character into r0
	add	chAdr, r0, lsl #4	// char address = font base + (char * 16)


	ldr	r0, =pyDrawChar		// init the Y coordinate (pixel coordinate)
	ldr	py, [r0]
charLoop$:

	ldr	r0, =pxDrawChar		// init the X coordinate
	ldr	px, [r0]

	mov	mask, #0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row, [chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst	row, mask		// test row byte against the bitmask
	beq	noPixel$

	mov	r0, px
	mov	r1, py
	mov	r2, color		// color
	push	{lr}
	bl	DrawPixel		// draw red pixel at (px, py)
	pop	{lr}

noPixel$:
	add	px, #1			// increment x coordinate by 1
	lsl	mask, #1		// shift bitmask left by 1

	tst	mask, #0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq	rowLoop$

	add	py, #1			// increment y coordinate by 1

	tst	chAdr, #0xF
	bne	charLoop$		// loop back to charLoop$, unless address evenly divisible
					// by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop	{r4-r9, pc}



//-----------------------------------------------------------------------------


/* Draw Pixel
 *  r0 - x
 *  r1 - y
 *  r2 - color
 */
.globl DrawPixel
DrawPixel:
	push	{r4}


	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add	offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl	offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	pop	{r4}
	bx	lr



//-----------------------------------------------------------------------------




.section .data

.align 4
font:	.incbin	"font.bin"

pxDrawChar: .int 0
pyDrawChar: .int 0

.globl	mainMenuInstruction
mainMenuInstruction:	.ascii	"USE THE 'UP', 'DOWN', AND 'A' BUTTONS TO SELECT"
.globl	mMILength
.align	2
mMILength:	.byte	.-mainMenuInstruction

// printScreen

.globl	startingScore
startingScore:	.int	0
.align	2
startingScoreLength:	.byte	.-startingScore
