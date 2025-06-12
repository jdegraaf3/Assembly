// === file header ===
	.arch armv6               // armv6 architecture
	.cpu cortex-a72           // our CPU model
	.arm                      // arm 32-bit IS
	.fpu vfp                  // floating point co-processor
	.syntax unified           // modern syntax
// === definitions applying to the entire source file ===
	// you could put the bit count of certain fields or masks here, for example
	// .equ EXAMPLE_DEF, 0xff
	.equ CLEAR, 0x00000000
	.equ SUB_NORM, 0x00800000
	.equ CLEAR_SIGN, 0x007fffff
	// .data                  // uncomment if you need the data segment
	.text                     // start of text segment

// === fpconvert ===
	.global fpconvert         // make fpconvert global so the linker knows about it
	.type fpconvert, %function // define fpconvert to be a function
	.equ FP_OFFSET, 32 	      // (# of saved regs - 1) * 4 rounded up to multiples of 8
fpconvert:
// function prologue (do not edit)
	push {r4-r10, fp, lr}     // save registers to stack
	add fp, sp, FP_OFFSET     // set frame pointer to frame base
// you can use any of r0-r10 inclusive
// r0 is the parameter to the function
// the value of r0 upon bx lr is the value returned from the function

// YOUR CODE BEGINS
// === fpconvert function body ===

	//extracting fields from input
	// storing sign in r10
	mov r10, r0
	lsr r10, #14
	and r10, #1
	// storing exp in r9
	mov r9, r0
	lsr r9, #8
	and r9, 0x3f
	// storing Mantissa in r8
	mov r8, r0
	and r8, 0xff

	// Check if exp represents infinity
	cmp r9, 0x3f
	beq .Linf

	// get correct bias number
	add r9, r9, #96
	// check if exp was equal to 0, branch to exp_zero options if so, if not branch to normal options
	cmp r9, #96
	beq .Lexp_zero
	bne .Lnorm

.Linf:
	bl convert_infinity
	b .Lend

	// Clear r9 of 96, then check if subnormal number by checking mantissa, branch to subnormal branches if so
	// branch to normal ranches if not
.Lexp_zero:
	and r9, r9, CLEAR
	cmp r8, #0
	bne .Lsub_norm
	beq .Lnorm

	// Make r9 15 and shift it to correct location because we need an exponent of 38 if the least bit is 1, it would take
	// 23 moves to shift to the right position. We then call .LmoveMantissa to get the mantissa to the right position.
.Lsub_norm:
	mov r9, #15
	lsl r10, #31
	ldr r7, =SUB_NORM
	ldr r4, =CLEAR_SIGN // used to clear the sign and exp bits later as shifted mantissa will affect it
	b .Lmove_mantissa

	// move normal numbers to 32bit position, then branches to combine the fields
.Lnorm:
	lsl r10, #31
	//lsl r9, #23
	lsl r8, #15
	b .Lcombine

	// A loop that moves the mantissa to the correct position for a subnormal number, once mantissa is in right spot,
	// I subtract 127 from whatever our calculated exponent is and save it, I then clear the mantissa register as it will
	// have a one in the sign position, so I need to get rid of it for cor future comination, then branch to .Lcombine
.Lmove_mantissa:
	lsl r8, #1
	and r6, r7, r8
	add r9, r9, #1
	cmp r7, r6
	bne .Lmove_mantissa
	mov r5, #127
        sub r9, r5, r9
	and r8, r8, r4
	beq .Lcombine

	// Combines the sign, exp, and mantissa into r0
.Lcombine:
	lsl r9, #23
	orr r1, r10, r9
	orr r0, r8, r1
	b .Lend

	// End of function
.Lend:
	// TODO implement; here's one example for the recommended style:
	// instruction operands   // equivalent C code         ; human readable explanation
	// add r0, r1, EQU        // r0 = r1 + EQU             ; add EQU to r0 from r1
// === end fpconvert function body ===
// YOUR CODE ENDS

// function epilogue - do not edit
	sub sp, fp, FP_OFFSET
	pop {r4-r10, fp, lr}      // must match list in prolog's push
	bx lr                     // return
// function footer
	.size fpconvert, (. - fpconvert) // set size for function

// === file footer ===
	.section .note.GNU-stack, "", %progbits // stack/data non-exec (linker)
	.end
