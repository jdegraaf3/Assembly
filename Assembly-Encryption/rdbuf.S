#ifndef MYRDBUF_S
#else
// version 1.1 11/29/2022 //
    .arch   armv6
    .arm
    .fpu    vfp
    .syntax unified

    // global constants
    #include "cipher.h"

    .extern fread
    .extern feof
    .extern ferror
    .text

    // int rdbuf(r0=FILE *in, r1=FILE *fpbook, r2=int cnt, r3=char *iobuf,
    //            on the stack at ARG5 offset=char *bookbuf)
    // returns number of bytes read EXIT_FAIL otherwise
    // you can change or remove any comments in this file

    .type   rdbuf, %function
    .global rdbuf
    .equ    ARG5,  4
    .equ    FP_OFF, 28

rdbuf:
    push    {r4-r9, fp, lr}
    add     fp, sp, FP_OFF

    // save the register args (r0-r3) into preserved registers
    // as there are many function calls
    mov r5, r0 // r5 = in
    mov r6, r1 // r6 = fpbook
    mov r7, r2 // r7 = cnt
    mov r8, r3 // r8 = iobuf
    //ldr r9, [fp, ARG5] // r9 = bookbuf

    // check for end of file feof(in)
    // if r0 is not zero at EOF, set r0 to 0 and return
    bl feof
    cmp r0, #0
    beq .Lcheck_read
.Lset_zero:
    mov r0, #0
    b .Ldone

    // otherwise check for read errors
    // check for error ferror(in)
    // if r0 is zero, no errors, do the reads
    // if r0 is not zero, set r0 to EXIT_FAIL and return
.Lcheck_read:
    mov r0, r5
    bl ferror
    cmp r0, #0
    beq .Lbytes

.Lset_EF:
    ldr r0, =EXIT_FAIL
    b .Ldone

    // bytes = fread(r0=iobuf, r1=1, r2=cnt, r3=in)
    // save bytes so we can check that we read same bytes from bookfile
    // if r0 <= 0 return with r0 = 0
.Lbytes:
    mov r0, r8 // r0 = iobuf
    mov r1, #1
    mov r2, r7 // r2 = cnt
    mov r3, r5 // r3 = in
    bl fread
    mov r9, r0 // save bytes
    cmp r0, #0
    ble .Lset_zero

    // r0 = fread(r0=bookbuf, r1=1, r2=bytes, r3=fpbook)
    // the pointer to bookbuf is passed on the stack so
    // you need to do a ldr from ARG5 offset to get the address
    // to pass to the fread
    // if r0 on the return from fread is not equal to bytes
    // (bytes is the value returned in r0 from the fread into iobuf above),
    // then return EXIT fail
    // otherwise set r0 = bytes and return
.Lbookbuf:
    ldr r0, [fp, ARG5] // ptr is 4 bytes
    mov r1, #1
    mov r2, r9 // r2 = bytes from .Lbytes
    mov r3, r6 // r3 = fpbook
    bl fread
    cmp r0, r9
    bne .Lset_EF
    mov r0, r9 // r0 = bytes if equal

.Ldone:
    sub     sp, fp, FP_OFF
    pop     {r4-r9, fp, lr}
    bx      lr

    .size   rdbuf, (. - rdbuf)
    .section .note.GNU-stack,"",%progbits
.end
#endif
