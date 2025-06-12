// === file header ===
	.arch armv6               // armv6 architecture
	.cpu cortex-a72           // our CPU model
	.arm                      // arm 32-bit IS
	.fpu vfp                  // floating point co-processor
	.syntax unified           // modern syntax
// === definitions applying to the entire source file ===
	// you could put the bit count of certain fields or masks here, for example
	// .equ EXAMPLE_DEF, 0xff
	// .data                  // uncomment if you need the data segment
	.text                     // start of text segment

// === convert_infinity ===
// Returns a 32-bit IEEE +Inf or -Inf.
	.global convert_infinity
	.type convert_infinity, %function
	.equ FP_OFFSET, 32 	       // (# of saved regs - 1) * 4 rounded up to multiples of 8
convert_infinity:
// you should not depend on the values of r1-r3 because convert_infinity takes no arguments
	mov r1, 28
	mov r2, 61
	mov r3, 5
// function prologue (do not edit)
	push {r4-r10, fp, lr}    // save regs
	add fp, sp, FP_OFFSET
// you can use any of r0-r10 inclusive
// R0 is the parameter to the function
// the last value of R0 is the value
// returned from the function
// r4-r10 are local to this function
// changes to these values will not be reflected
// in the main function.

// YOUR CODE BEGINS

	// get sign bit move it to correct spot
	mov r10, r0
	lsr r10, #14
	and r10, r10, #1
	lsl r10, #31

	// make exponent infinity
	ldr r9, =0x7f800000
	ldr r8, =0x00000000

	// get correct sign bit and put it into r0
	and r0, r0, r8
	orr r0, r10, r9

// === convert_infinity function body ===
	// TODO implement; here's one example for the recommended style:
	// instruction operands   // equivalent C code         ; human readable explanation
	// add r0, r1, EQU        // r0 = r1 + EQU             ; add EQU to r0 from r1
// === end convert_infinity function body ===
// YOUR CODE ENDS

// function epilogue (do not edit)
	sub	sp, fp, FP_OFFSET
	pop {r4-r10, fp, lr}       // restore regs
	bx lr                      // return
// function footer
	.size convert_infinity, (. - convert_infinity)

// === file footer ===
	.section .note.GNU-stack, "", %progbits // stack/data non-exec (linker)
	.end
