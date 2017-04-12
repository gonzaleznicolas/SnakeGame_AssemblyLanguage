/*
Student:	Nicolas Gonzalez
ID:		10151261
Date:		March 2016
Course:		CPSC 359
Professor:	Jalal Kawash
TA:		Salim Afra
*/

.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
	//mov     sp, #0x8000
	bl	InstallIntTable			// *** MUST COME FIRST, sets the stack pointer	
	bl	EnableJTAG

	bl	InitFrameBuffer			// get the address of the frameBuffer

	bl	enableInterrupt


	bl	initSNES			// Initialize clock, data, and latch pins to correct functions (I/O)



.globl	beginning
beginning:


	bl	mainMenu
	teq	r0, #2				// see if user selected quit
	beq	quit				// if so, branch to end
	teq	r0, #1				// see if user selected start
	beq	start				// is so, start



.globl	start
start:

	bl	enableInterrupt

	bl	setMap				// sets the borders and walls in the screen array

	bl	printScreen			// print screen array to the screen

	// indicate that the door has not been spawned. 
	ldr	r0, =doorSpawned
	mov	r1, #0
	str	r1, [r0]			// set doorSpawned flag to 0

	// indicate that the value pack is not present
	ldr	r0, =vpPresent
	mov	r1, #0
	str	r1, [r0]


	// print "Score:" and "Lives:" and author
	bl	printDetails

	bl	initializeStartingLives
	bl	initializeStartingScore

	bl	initSnakeArray			// set snakeArray positions to starting position
	bl	initSnake			// put snake in starting position
	bl	initTail


	input		.req	r4		// 0=start, 1=up, 2=right, 3=down, 4=left, 5=nothing relevant
	state		.req	r5		// 1=up, 2=right, 3=down, 4=left
	lose		.req	r6		// lose flag. 0 = not set, 1 = set
	win		.req	r7		// win flag. 0 = not set, 1 = set
	quit		.req	r8		// quit flag. 0 = not set, 1 = set
	previousState	.req	r9		// 1=up, 2=right, 3=down, 4=left


	mov	state, #2			// start snake moving right
	mov	previousState, #2		// assume previous state was right
	mov	lose, #0			// initialize lose flag to 0
	mov	win, #0				// initialize win flag to 0
	mov	quit, #0			// initialize quit flag to 0

	// set non value pack game speed
	ldr	r0, =amountOfTimeToWait
	ldr	r1, =150000
	str	r1, [r0]

	// set the value pack key value to 21
	// the way this works is that when the vpKey ==20, the amountOfTimeToWait is
	// set to the default value of 150000. 
	// when a value pack is eaten, the amountOfTimeToWait is set to 80000
	// and the vpKey is set to 0.
	// every loop iteration the vpKey is incremented.
	// and when vpKey gets to 20, the amountOfTimeToWait is reverted to 150000
	ldr	r0, =vpKey
	mov	r1, #101
	str	r1, [r0]


savedByLives:
	ldr	r0, =doorSpawned
	ldr	r1, [r0]			// doorSpawned flag in r1
	cmp	r1, #0
	bleq	spawnApple			// spawn first apple

gameLoop:
	mov	previousState, state		// set previous state to be state we are about to change

	bl	readSNES			// read SNES. buttons register in r0
						// input for identifyButtonsPressed is in r0 (output of readSNES)
	bl	identifyButtonsPressed
						// return value in r0 (0, 1, 2, 3, 4, 5, 6)
	mov	input, r0			// put controller input value in r4 (input)

	//check if the input is opposite to the current state. if so, ignore input.
	// e.g. snake is going right and user presses left. ignore input.
	// also check if the input is start button

	cmp	input, #0			// see if input is start
	bleq	pauseMenu

	
	cmp	input, #1			// see if input is "up"
	beq	iup
	cmp	input, #2			// see if input is "right"
	beq	iright
	cmp	input, #3			// see if input is "down"
	beq	idown
	cmp	input, #4			// see if input is "left"
	beq	ileft

	b	stateUpdated			// if here, input is not 1,2,3,4 therefore the state does not
						// need updating
// check if user is trying to go in direction opposite to the current direction. if so, ignore input.
iup:
	cmp	state, #3			// see if state is down
	beq	stateUpdated			// if equal, dont update state
	b	updateState			// if here, the input is a direction not opposite
						// to the current one
iright:
	cmp	state, #4			// see if state is left
	beq	stateUpdated			// if equal, dont update state
	b	updateState			// if here, the input is a direction not opposite
						// to the current one
idown:
	cmp	state, #1			// see if state is up
	beq	stateUpdated			// if equal, dont update state
	b	updateState			// if here, the input is a direction not opposite
						// to the current one
ileft:
	cmp	state, #2			// see if state is right
	beq	stateUpdated			// if equal, dont update state
	b	updateState			// if here, the input is a direction not opposite
						// to the current one

updateState:
	// if here, the input is a direction, so update the state
	mov	state, input			// current state is the input

stateUpdated:
	// before we write a new state to the state array, shift it down
	bl	shiftStateArrayDown
	// set the state of the head in the stateArray
	mov	r0, #0				// arg 1: body piece number = 0 (head)
	mov	r1, state			// arg 2: state
	bl	setState

	bl	updateTail
	mov	r0, state			// arg1
	mov	r1, previousState		// arg2
	bl	updateSnake			// update snake. you lose flag in r0.
	mov	lose, r0			// move return value to lose flag

	
	// see if the score >= 20. if so, disable interrupts and spawn door
	ldr	r0, =score
	ldr	r1, [r0]			// score in r1
	cmp	r1, #20				// compare score to 20
	blt	doorNotSpawnedYet


	// if here, the player has reached score 20
	// disable interrupts
	bl	disableInterrupt

	// also, see if the door has already been spawned
	ldr	r0, =doorSpawned
	ldr	r1, [r0]					// doorSpawned flag in r0
	cmp	r1, #1						// see if the door has been spawned
	beq	doorSpawnedAlready				// if it has been spawned, dont spawn it again

	// if here, we have reached score 20 and the door hasnt been spawned, so spawn it.
	bl	spawnDoor
	// and update the doorSpawned flag
	ldr	r0, =doorSpawned
	mov	r1, #1
	str	r1, [r0]					// pit 1 in doorSpawned flag


doorSpawnedAlready:

	// if here, the door has been spawned

	bl	seeIfDoorFound
	cmp	r0, #1					// equal if door found
	moveq	win, #1					// if equal, set win flag

	

doorNotSpawnedYet:



	// see if a value pack was picked up
	// but before calling seeIfVPFound, make sure there is a vp present. if not, dont even call seeIfVPFound
	ldr	r0, =vpPresent
	ldr	r0, [r0]		// vpPresent flag in r0. 
						// 0 means vp is not present
						// 1 means vp is present (hasnt been eaten yet)
	cmp	r0, #1			// see if vpPresent is set
	bne	vpNotPresent

	// if here, vp is present
	bl	seeIfVPFound




vpNotPresent:


	// inrement vpKey
	ldr	r0, =vpKey
	ldr	r1, [r0]
	add	r1, #1
	str	r1, [r0]

	// if vpKey==20, set amountOfTimeToWait to 150000
	ldr	r0, =vpKey
	ldr	r0, [r0]		// vpKey in r0
	cmp	r0, #100		// see if vpKey==200
	bne	vpKeyNotTwenty

	// if here, vpKey is 2000 so amountOfTimeToWait must be set to 150000
	ldr	r0, =amountOfTimeToWait
	ldr	r1, =150000
	str	r1, [r0]
	


vpKeyNotTwenty:


	// wait so the game is not super fast
	ldr	r0, =amountOfTimeToWait
	ldr	r0, [r0]
	bl	wait



	cmp	lose, #1			// see if player has lost
	beq	youLose
	cmp	win, #1				// see if player has won
	beq	youWin
	cmp	quit, #1			// see if player has quit
	beq	youQuit

	bal	gameLoop


youLose:
	bl	erraseApple
	
	// if here, the snake ran into a wall, border, or itself.
	bl	decrementNumberOfLives		// decrement global var and decrement on screen
	ldr	r0, =lives			// load global var number of lives
	ldr	r0, [r0]
	cmp	r0, #0				// see if 0 lives left
	ble	youFullyLost			// if 0 or fewer lives, you lost
	// if here, you had lives left
	mov	lose, #0			// un-set lose flag
	bl	eraseSnake			// erase snake from screen without deleting information
						// about how long it currently is
	bl	initSnakeArray
	bl	initStateArray
	bl	snakeStandardPosition		// draw snake back in its starting position without changing its length
	// print message saying you lost a life
	ldr	r0, =0xF8A4
	push	{r0}				// arg 5: color
	ldr	r0, =lostLife			// arg 1
	ldr	r1, =lLLength			// arg 2
	ldr	r2, =300			// arg 3: x
	ldr	r3, =350			// arg 4: y
	bl	printString
	// wait to give the player time to read
	ldr	r0, =3000000
	bl	wait
	// erase "you lost a life" sign
	ldr	r0, =0x7497			// color
	push	{r0}
	ldr	r0, =300			// x
	ldr	r1, =350			// y
	ldr	r2, =500			// width
	mov	r3, #20				// height
	bl	printBox

	mov	state, #2			// resume going right
	b	savedByLives
	
youFullyLost:
	// if here, we had zero lives left. you lost
	bl	youLost
	b	beginning

youWin:
	bl	erraseApple
	bl	youWon
	bl	eraseDoor
	b	beginning

youQuit:
	mov	r0, r0


.globl	quit
quit:
	ldr	r0, =black
	bl	coverScreen

	.unreq	input
	.unreq	state
	.unreq	lose
	.unreq	win
	.unreq	quit

.globl	haltLoop$
haltLoop$:
	b	haltLoop$
.globl	hang
hang:
	b		hang


//-------------------------------------------------------------------------
.globl	irq
irq:
	push	{r0-r12, lr}

	// test if there is an interrupt pending in IRQ Pending 1
	ldr		r0, =0x2000B200
	ldr		r1, [r0]
	tst		r1, #0x100		// bit 8
	beq		irqEnd

	// test that at least one GPIO IRQ line caused the interrupt
	ldr		r0, =0x2000B204		// IRQ Pending 1 register
	ldr		r1, [r0]
	tst		r1, #0x00000008
	beq		irqEnd

	//spawn ValuePack
	bl	spawnValuePack

	// clear CS
	ldr		r0, =0x20003000
	mov		r1, #0x00000008	
	ldr		r3, [r0]
	orr		r3, r1
	str		r3, [r0]

	ldr		r0, =0x20003018
	mov		r1, #0x0	
	str		r1, [r0]	

	// disable IRQ
	bl	disableInterrupt

	// enable IRQ
	bl	enableInterrupt
	
irqEnd:
	pop		{r0-r12, lr}
	subs	pc, lr, #4


//-------------------------------------------------------------------------

.globl InstallIntTable
InstallIntTable:
	
	ldr		r0, =IntTable
	mov		r1, #0x00000000

	// load the first 8 words and store at the 0 address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// load the second 8 words and store at the next address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// switch to IRQ mode and set stack pointer
	mov		r0, #0xD2
	msr		cpsr_c, r0
	mov		sp, #0x8000

	// switch back to Supervisor mode, set the stack pointer
	mov		r0, #0xD3
	msr		cpsr_c, r0
	mov		sp, #0x8000000

	bx		lr	

//-------------------------------------------------------------------------




.section	.data





.globl	score
score:	.int	0

.globl	lives
lives:	.int	0

.globl	snakeLength
snakeLength:	.int	0

.globl	doorSpawned			// 0= door has not been spawned. 1=door has been spawned
doorSpawned:	.int	0

.globl	amountOfTimeToWait
amountOfTimeToWait:	.int	0

.globl	vpKey
vpKey:	.int	0



.globl	lostLife
lostLife:	.ascii	"You lost a life! Game continuting in 3...2...1..."
.globl	lLLength
.align	2
lLLength:	.byte	.-lostLife

.globl	creatorName
creatorName:	.ascii	"Created By: Nicolas Gonzalez"
.globl	cNLength
.align	2
cNLength:	.byte	.-creatorName

.globl	scoreString
scoreString:	.ascii	"SCORE:"
.globl	sSLength
.align	2
sSLength:	.byte	.-scoreString

.globl	livesString
livesString:	.ascii	"LIVES:"
.globl	lSLength
.align	2
lSLength:	.byte	.-livesString

.align	4
.global	ValueAmount
ValueAmount:
	.word	0
.global	ValueWait
ValueWait:
	.word	30000000		//30000000 = 30sec
