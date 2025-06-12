    // version 1.1 10/29/2022 //
#ifndef MYMAIN_S
#else
    .arch   armv6
    .arm
    .fpu    vfp
    .syntax unified

    // imports
    #include "main.h"
    #include "rdbuf.h"
    #include "setup.h"
    #include "cipher.h"
    .extern fwrite
    .extern stdin
    .extern stdout
    .extern stderr

    .section .rodata
    // do not change these error messages
.Lbdrd:  .string "%s: read failed\n"
.Lbdwr:  .string "%s: write failed\n"

    .text

    //
    // encrypter -b bookfile
    //
    // int main(int argc, char **argv)
    // int main(r0=argc, r1=argv)

    .global main
    .type   main, %function

    //
    // stack frame layout
    //
    // TODO Part 2: complete the following stack frame design
    // You can change or delete any comments in this file
    //
    .equ    FP_OFF,     32          // fp offset in main stack frame
    .equ    FPBOOK,     4 + FP_OFF            // FILE * to book file
    .equ    IOBUF,      BUFSZ + FPBOOK            // buffer for input file
    .equ    BOOKBUF,    BUFSZ + IOBUF            // buffer for book file
    .equ    ARGV0,      4 + BOOKBUF            // save argv[0] for error printing
    //
    // add your local variables here if you need them:
    // NOTICE: Adjust PAD so FRMADD + FP_OFF + 4 divides by 8 EVENLY!
    //
    .equ    PAD,        8 + ARGV0             // Stack frame PAD
    .equ    OARG5,      4 + PAD            // output arg5 must be at bottom
    .equ    FRMADD,    OARG5-FP_OFF // space in frame for locals+passed args

    // TODO Part 2: list how you are using the preserved registers
    // preserved register use
    // r4
    // r5
    // r6
    // r7
    // r8
    // r9
    // r10

main:
    push    {r4-r10, fp, lr}        // push all the usable preserved registers
    add     fp, sp, FP_OFF          // set frame pointer to frame base
    ldr     r3, =FRMADD             // get space needed for locals+passed args
    sub     sp, sp, r3              // allocate space for locals and passed args

    // save argv[0] in argv0 at the entry to main() argc is in r0 and argv is in r1.
    // call int setup(r0=argc, r1=argv, r2=*FPBOOK)
    // r2 is output parameter. Get the addresses of where
    // FPBOOK is located on main()'s stack and put this in r2
    // so setup can fill it in (passing a pointer to a local variable in r2)
    // if setup fails, put EXIT_FAILURE in r0 and then branch to .Lexit
    ldr r3, =ARGV0
    str r1, [fp, -r3]
    ldr r2, =FPBOOK
    sub r2, fp, r2
    bl setup
    cmp r0, #0
    bne .LsetEXITFAILURE

    // set up for main loop
    // save the variables you need in the preserved registers as you will be making
    // function calls in the loop body below and r0-r3 will be used for that
    mov r4, r0 // r4 = argc
    ldr r5, =ARGV0 // r5 = argv[0]
    ldr r5, [fp, -r5]
    ldr r5, [r5]
    mov r6, #0 // r6 = cnt
    ldr r7, =stderr
    ldr r7, [r7] // r7 = stderr
    ldr r8, =stdin
    ldr r8, [r8] // r8 = stdin
    ldr r9, =.Lbdrd
    //ldr r9, [r9] // r9 = bad read string
    ldr r10, =.Lbdwr
    //ldr r10, [r10] // r10 = bad write string

.Lloop:
    // this is a loop that runs until rdbuf indicates the EOF on stdin
    // was reached or there was an error.
    // int rdbuf(r0=stdin, r1=fpbook, r2=BUFSZ, r3=iobuf,OARG5=bookbuf)
    // NOTICE that the 5th arg is on the stack so you need to str the
    // address of bookbuf at offset OARG5 on the stack
    // if r0 on return from rdbuf has a 0 in r0 we are done,
    // branch to .Ldone (EXIT_SUCCESS is a 0)
    // if return less than 0, error print to stderr .Lbdrd,
    // Put EXIT_FAILURE in r0 and go to .Ldone

    ldr r2, =BUFSZ
    ldr r3, =IOBUF
    //ldrb r3, [fp, -r3]
    sub r3, fp, r3
    ldr r0, =BOOKBUF
    //ldrb r0, [fp, -r0]
    sub r0, fp, r0
    ldr r1, =OARG5
    str r0, [fp, -r1]
    ldr r1, =FPBOOK
    ldr r1, [fp, -r1]
    //sub r1, fp, r1
    mov r0, r8
    bl rdbuf
    mov r6, r0
    cmp r6, #0
    ble .Ldone
    //cmp r0, #0
    //blt .Lfprintf
    //mov r6, r0

    // call either encrypt
    // int encrypt(r0=char *iobuf, r1=char *bookbuf, r2=int cnt)
    // returns cnt
    ldr r0, =IOBUF
    sub r0, fp, r0
    ldr r1, =BOOKBUF
    sub r1, fp, r1
    mov r2, r6
    bl encrypt
    mov r6, r0

    // make sure to save cnt so we can check that fwrite wrote cnt characters
    // fwrite returns number of characters it wrote.
    // fwrite(r0=iobuf, r1=1, r2=cnt, r3=*stdout)
    ldr r0, =IOBUF
    sub r0, fp, r0
    mov r1, #1
    mov r2, r6
    ldr r3, =stdout
    //sub r3, fp, r3
    ldr r3, [r3]
    bl fwrite

    // if cnt characters written go to .Lloop (write is ok)
    // othewise error, print to stderr .Lbdwr, put EXIT_FAILURE in r0
    // and fall through to .Ldone
    cmp r0, r6
    beq .Lloop

.Lfprintf:
    mov r0, r7
    mov r1, r10
    mov r2, r5
    bl fprintf
    ldr r0, =FPBOOK
    ldr r0, [fp, -r0]
    bl fclose

.LsetEXITFAILURE:
    ldr r0, =EXIT_FAILURE
    b .Lexit

.Ldone:
    ldr r0, =FPBOOK
    ldr r0, [fp, -r0]
    bl fclose
    cmp r6, #0
    bge .Lexit
    mov r0, r7
    mov r1, r9
    mov r2, r5
    bl fprintf
    ldr r0, =EXIT_FAILURE

.Lexit:
    sub     sp, fp, FP_OFF
    pop     {r4-r10, fp, lr}
    bx      lr

    .size   main, (. - main)
    .section .note.GNU-stack,"",%progbits
.end
#endif
