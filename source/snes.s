/*
Student:	Nicolas Gonzalez
ID:		10151261
Date:		March 2016
Course:		CPSC 359
Professor:	Jalal Kawash
TA:		Salim Afra
*/
    
.section .text


//-----------------------------------------------------------------------

// void identifyButtonsPressed( buttons register)
// input:
//	r0 - buttons register (output of readSNES)
// output:
//	r0 - number code for what button is pressed.
//		0=start, 1=up, 2=right, 3=down, 4=left, 5= nothing relevant, 6=A, for others, see subroutine code
// precondition:
//	input is a properly formed buttons register
// postcondition:
//	in r0 we have returned one of 0=start, 1=up, 2=right, 3=down, 4=left, 5= nothing relevant, 6=A
//	the check if those buttons are pressed in that order.
.globl	identifyButtonsPressed
identifyButtonsPressed:
	push	{r4-r7}	
	//r4	buttons register
	//r5	0x1
	//r6	bit mask
	//r7	value to be returned
	
	mov	r7,	#5			// initialize value to be returned to 5 = nothing relevant is pressed	
	mov	r4,	r0			// put buttons in r4
	mov	r5, 	#1


	// check if start is pressed
	lsl	r6, r5, #12			// bit mask in r6
	and	r6, r6, r4			// and bit mask with buttons register
	cmp	r6, #0				// see if r6 == 0
	moveq	r7, #0				// if start is pressed, return 0
	beq	returnidentifyButtonsPressed	// return
	

	// check if up joy stick is pressed
	lsl	r6, r5, #11			// bit mask in r6
	and	r6, r6, r4			// and bit mask with buttons register
	cmp	r6, #0				// see if r6 == 0
	moveq	r7, #1				// if start is pressed, return 1
	beq	returnidentifyButtonsPressed	// return


	// check if right joy stick is pressed
	lsl	r6, r5, #8			// bit mask in r6
	and	r6, r6, r4			// and bit mask with buttons register
	cmp	r6, #0				// see if r6 == 0
	moveq	r7, #2				// if start is pressed, return 2
	beq	returnidentifyButtonsPressed	// return


	// check if down joy stick is pressed
	lsl	r6, r5, #10			// bit mask in r6
	and	r6, r6, r4			// and bit mask with buttons register
	cmp	r6, #0				// see if r6 == 0
	moveq	r7, #3				// if start is pressed, return 3
	beq	returnidentifyButtonsPressed	// return


	// check if left joy stick is pressed
	lsl	r6, r5, #9			// bit mask in r6
	and	r6, r6, r4			// and bit mask with buttons register
	cmp	r6, #0				// see if r6 == 0
	moveq	r7, #4				// if start is pressed, return 4
	beq	returnidentifyButtonsPressed	// return


	// check if A is pressed
	lsl	r6, r5, #7			// bit mask in r6
	and	r6, r6, r4			// and bit mask with buttons register
	cmp	r6, #0				// see if r6 == 0
	moveq	r7, #6
	beq	returnidentifyButtonsPressed	// return

	// check if RIGHT bumper is pressed
	lsl	r6, r5, #4			// bit mask in r6
	and	r6, r6, r4			// and bit mask with buttons register
	cmp	r6, #0				// see if r6 == 0 (if RIGHT is pressed)
	moveq	r7, #7
	beq	returnidentifyButtonsPressed	// return

	// check if LEFT bumper is pressed
	lsl	r6, r5, #5			// bit mask in r6
	and	r6, r6, r4			// and bit mask with buttons register
	cmp	r6, #0				// see if r6 == 0
	moveq	r7, #7
	beq	returnidentifyButtonsPressed	// return

	// check if X is pressed
	lsl	r6, r5, #6			// bit mask in r6
	and	r6, r6, r4			// and bit mask with buttons register
	cmp	r6, #0				// see if r6 == 0
	moveq	r7, #7
	beq	returnidentifyButtonsPressed	// return


	// check if select is pressed
	lsl	r6, r5, #13			// bit mask in r6
	and	r6, r6, r4			// and bit mask with buttons register
	cmp	r6, #0				// see if r6 == 0
	moveq	r7, #7
	beq	returnidentifyButtonsPressed	// return

	// check if Y is pressed
	lsl	r6, r5, #14			// bit mask in r6
	and	r6, r6, r4			// and bit mask with buttons register
	cmp	r6, #0				// see if r6 == 0
	moveq	r7, #7
	beq	returnidentifyButtonsPressed	// return

	// check if B is pressed
	lsl	r6, r5, #15			// bit mask in r6
	and	r6, r6, r4			// and bit mask with buttons register
	cmp	r6, #0				// see if r6 == 0
	moveq	r7, #7
	beq	returnidentifyButtonsPressed	// return
	
returnidentifyButtonsPressed:
	mov	r0, r7
	pop	{r4-r7}
	mov	pc,	lr			// return




//-----------------------------------------------------------------------

// void readSNES()
// input:
//	void
// output:
//	r0 - buttons register
// precondition:
//	initSNES has been called
// postcondition:
//	r0 contains button data:
//		bits 0-3: always set. have no meaning
//		bits 4-15: button pressed if 0. button not pressed if 1
//			4	Right
//			5	Left
//			6	X
//			7	A
//			8	Joy_Pad Right
//			9	Joy_Pad Left
//			10	Joy_Pad Down
//			11	Joy_Pad Up
//			12	Start
//			13	Select
//			14	Y
//			15	B
//		bits 16-31: have no meaning.
.globl	readSNES
readSNES:
	push	{r4, r12}
	//r12 is buttons

	mov	r12,	#0			//clear register for buttons
	mov	r0,	#1			//write 1 to clock (upper edge)
	push	{lr}
	bl	write_clock			//write to clock
	pop	{lr}
	mov	r0,	#1
	push	{lr}
	bl	write_latch			//write to latch
	pop	{lr}
	mov	r0,	#12			//# microseconds to wait
	push	{lr}
	bl	wait				//wait 12 microseconds
	pop	{lr}
	mov	r0,	#0			//write 0 to latch
	push	{lr}
	bl	write_latch			//write to latch
	pop	{lr}
	
	//r4 is i
	mov	r4,	#0			//clear i
pulseLoop:
	
	mov	r0,	#6			//# microseconds to wait
	push	{lr}
	bl	wait				//wait 6 microseconds
	pop	{lr}
	mov	r0,	#0			//write to clock
	push	{lr}
	bl	write_clock			//write to clock
	pop	{lr}
	mov	r0,	#6			//# microseconds to wait
	push	{lr}
	bl	wait				//wait 6 microseconds
	pop	{lr}
	push	{lr}
	bl	read_data			//read bit from snes
	pop	{lr}
	lsl	r12,	#1			//shift r12 by one bit
	orr	r12,	r0			//concatenate the bit at the end
	mov	r0,	#1			//rising edge for clock
	push	{lr}
	bl	write_clock			//write to the clock
	pop	{lr}
	add	r4,	#1			//i++
	cmp	r4,	#16
	blt	pulseLoop
	
	mov	r0,	r12			//move button data to r0
	pop	{r4, r12}			//restore
	mov	pc,	lr			// return



//------------------------------------------------------------------------

// void write_latch(int bit)
// input:
//	r0: bit to write
// output:
//	void
// precondition:
//	r0 contains 1 or 0
// postcondition:
//	input has been written to latch line
.globl	write_latch
write_latch:

	mov	r1,	r0			//move bit ro write to r1 (needed in writeGPIO)
	mov	r0,	#9			//latch is pin 9
	push	{lr}
	bl	writeGPIO			//call the write
	pop	{lr}
	
	mov	pc,	lr			//return


//------------------------------------------------------------------------


// void write_clock(int bit)
// input:
//	r0: bit to write
// output:
//	void
// precondition:
//	r0 contains 1 or 0
// postcondition:
//	input has been written to clock line
.globl	write_clock
write_clock:
	
	mov	r1,	r0			//move bit to write to r1 (needed in writeGPIO
	mov	r0,	#11			//clock is pin 11
	push	{lr}
	bl	writeGPIO			//call the write
	pop	{lr}
	
	mov	pc,	lr			//return


//------------------------------------------------------------------------


// void read_data()
// input:
//	void
// output:
//	r0 - bit read
// precondition:
//	none
// postcondition:
//	bit read in r0. 0 or 1.
.globl	read_data
read_data:
	mov	r0,	#10
	push	{lr}
	bl	readGPIO
	pop	{lr}
	
	mov	pc,	lr			//return



//------------------------------------------------------------------------


//void initSNES()
// input: void
// output: void
//precondition: void
//postcondition: 
//		pin 9 (Latch) is set to output (1)
//		pin 10 (Data) is set to input (0)
//		pin 11 (clock) is set to output (1)
.globl	initSNES
initSNES:
	
	// set latch to output
	mov	r0,	#9			//pin number
	mov	r1,	#1			//output function is 1
	push 	{lr}
	bl	init_GPIO			//set the pin
	pop	{lr}
	
	// set clock to output
	mov	r0,	#11			//pin number
	mov	r1,	#1			//output function is 1
	push	{lr}
	bl	init_GPIO			//set pin
	pop	{lr}

	// set data to input
	mov	r0,	#10			//pin number
	mov	r1,	#0			//input function is 0
	push	{lr}
	bl	init_GPIO			//set pin
	pop	{lr}

	mov	pc,	lr			//return

//---------------------------------------------------------------------

// void init_GPIO(pin number, function code)
// input:
//		r0 - pin number (0 to 53)
//		r1 - 3 bit function code in the rightmost 3 bits of r1
// output:
//		void
// precondition:
//		- r0 contains an integer between 0 and 53
//		- r1 contains a valid function code in bits 0,1,2. bits 3-31 are cleared.
// postcondition:
//		- pin number indicated in r0 is set to the function indicated in r1
.globl	init_GPIO
init_GPIO:
	push	{r4-r7}					// protect register we will use
	
	// r3	copy of GPFSEL register
	// r4	pin number
	// r5	3 bit function code in rightmost 3 bits
	// r6	address of GPIO function select register
	// r8	value of GPIO function select register copy	

	mov	r4,	r0				// pin number in r4
	mov	r5,	r1				// function code in r5
	
	// separate pin number into 1st and 2nd digit
	mov	r0,	r4				// arg 1: pin number (numerator)
	mov	r1,	#10				// arg 2: denominator
	push	{lr}					// protect lr
	bl	divide					// call divide
	pop	{lr}					// restore lr
							// ten's digit in r0 (pin# div 10). one's digit in r1 (remainder)
	// load copy of correct GPFSEL register
	mov	r7,	#4				// number to multiply
	mul	r0,	r7				// r0 = offset = (pin# div 10) * 4
	ldr	r6,	=0x20200000			// load base register address
	add	r6,	r0				// add offset to base address
	ldr	r3,	[r6]				// load correct GPFSEL register into r

	// clear the 3 bits representing specified
	mov	r0,	#7				// bit mask for clearing bits
	mov	r7,	#3				// number to multiply
	mul	r1,	r7				// calculate number of bits to shift (3 * one's digit of pin#)
	lsl	r0,	r1				// shift bit mask
	bic	r3,	r0				// clear function select bits

	// set the function in GPFSEL register
	lsl	r5,	r1				// shift function code bits by same amount
	orr	r3,	r5				// orr to update function code
	str	r3,	[r6]				// store updated GPFSEL register

	// return
	pop	{r4-r7}					// restore registers used
	mov		pc, lr				// return





//------------------------------------------------------------------------



// void writeGPIO(pin number, value to write)
// input:
//		r0 - pin number (0 to 53)
//		r1 - value to write (0 or 1)
// output:
//		void
// precondition:
//		- r0 contains an integer between 0 and 53
//		- r1 contains either 0x1 or 0x0
// postcondition:
//		- pin number indicated in r0 is either set or cleared (set if r1==1, cleared if r1==0)
.globl	writeGPIO
writeGPIO:

	cmp	r1,	#0					// check for write or clear
	beq	clearGPIO					// branch to clear GPIO

	
	cmp	r0,	#32					// compare with 32 to select proper register
	bge	writeRegisterOne

writeRegisterZero:
	mov	r1,	#1					// clear and put 1 in LSB position
	lsl	r1,	r0					// shift to align bit
	ldr	r0,	=0x2020001C				// get address of setRegister
	str	r1,	[r0]					// write bit to register
	b	returnWriteGPIO					// return
	

writeRegisterOne:
	
	mov	r1,	#1					// clear and put 1 in LSB position
	sub	r0,	#32					// correct bit offset (register already chosen)
	lsl	r1,	r0					// shift to align bit
	ldr	r0,	=0x20200020				// get address of setRegister
	str	r1,	[r0]					// write bit to register
	b	returnWriteGPIO					// return
	
clearGPIO:

	cmp	r0,	#32					// compare with 32 to select proper register
	bge	clearRegisterOne

clearRegisterZero:
	mov	r1,	#1					// clear and put 1 in LSB position
	lsl	r1,	r0					// shift to align bit
	ldr	r0,	=0x20200028				// get address of setRegister
	str	r1,	[r0]					// write bit to register
	b	returnWriteGPIO					// return

clearRegisterOne:
	mov	r1,	#1					// clear and put 1 in LSB position
	sub	r0,	#32					// correct bit offset (register already chosen)
	lsl	r1,	r0					// shift to align bit
	ldr	r0,	=0x2020002C				// get address of setRegister
	str	r1,	[r0]					// write bit to register

returnWriteGPIO:
	mov	pc,	lr					// return



//------------------------------------------------------------------------



// int readGPIO( int pinNumber)

//in RPi only gplev0 is used (one register, not two)
// input:
//		r0 - pin number (0 to 31)
// output:
//		r0 - value read. either 0x0 or 0x1
// precondition:
//		- r0 contains an integer between 0 and 31
// postcondition:
//		- value read from pin indicated in r0 is returned in r0
.globl	readGPIO
readGPIO:
	ldr	r1,	=0x20200034				//address of gplev0
	ldr	r3,	[r1]					//load value of gplev0
	mov	r2,	#1					//just one
	lsl	r2,	r0					//shift to align with bit to read
	and	r2,	r3					//mask everything else but aligned bit
	teq	r2,	#0					//test if bit is 0
	moveq	r0,	#0					//mov 0 to output if pin is 0
	movne	r0,	#1					//mov 1 to output if pin is 1

returnRead:
	mov		pc, lr					//return



//------------------------------------------------------------------------


// void wait(number of microseconds)
// input:
//		r0 - integer representation of number of microseconds to wait
// output:
//		void
// precondition:
//		- r0 contains integer representation of number of microseconds to wait
// postcondition:
//		- the subroutine returns after having waited r0 microseconds
.globl	wait
wait:

	//r0 = address of clo
	//r1 = CLO end number
	//r2 = microseconds to wait
	//r3 = end time

	mov	r2,	r0			// move seconds to wait to r1
	ldr	r0,	=0x20003004		// address of CLO register
	ldr	r1,	[r0]			// read CLO register
	add 	r1,	r2			// add # microseconds to wait
waitLoop:
	ldr	r3,	[r0]				// load current CLO value
	cmp	r1,	r3				// stop when CLO >= r1
	bhi	waitLoop
	mov	pc,	lr				// return



//------------------------------------------------------------------------


// int, int divide(int dividend, int divisor)
// input:
	// r0: divided
	// r1: divisor
// output:
	// r0: quotient
	// r1: remainder
.globl	divide
divide:
	push	{r4, r5}			// protect registers
	cmp	r1,	#0			// compare divisor to 0
	beq	return_div			// exit if trying to divide by 0
	mov	r4,	r0			// initialize r4 to dividend
	mov	r5,	r1			// initialize r5 to divisor
	mov	r0,	#0			// quotient starts as 0
	mov	r1,	#0			// remainder starts as 0
divide_loop:
	cmp	r4,	r5			// compare dividend and divisor
	blo	end_div				// if dividend < divisor, branch
	add	r0,	r0,	#1		// add one to the quotient
	sub	r4,	r4,	r5		// subtract divisor from dividend
	b	divide_loop			// loop
end_div:
	mov	r1,	r4			// set remainder to what is left in r4
return_div:
	pop	{r4,	r5}			// restore registers
	mov	pc,	lr			// return



//--------------------------------------------------------------------------








