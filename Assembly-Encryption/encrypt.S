#ifndef MYENCRYPT_S
#else
// version 1.0 11/12/2022
    .arch armv6
    .arm
    .fpu vfp
    .syntax unified

    #include "cipher.h"

    .text     // start of text segment

    //////////////////////////////////////////////////
    // int encrypt(char *iobuf, char *bookbuf, int cnt)
    // encrypts  iobuf with bookbuf; updating iobuf
    //////////////////////////////////////////////////
    .global encrypt
    .type   encrypt, %function
    .equ    FP_OFF, 28

encrypt:
    push    {r4-r9, fp, lr}
    add     fp, sp, FP_OFF
    // do not alter anything above this line
    // r0 contains char *iobuf
    // r1 contains char *bookbuf
    // r2 contains cnt
    // r3 is ok to use
    // r4-r9 preserved registers are ok to use

    cmp     r2, 0               // if buffer empty we are done
    ble     .Ldone

    // your code here
    mov r3, #0  // counter
.Lwhile:
    ldrb r4, [r0] //load a byte from iobuf into a different register
    ldrb r5, [r1] //load a byte from bookbuf into a different register
    eor r6, r4, r5 //exlusive or the bytes and store into a different register
    strb r6, [r0] //put the exlusive or'd bytes back into iobuf
    add r0, r0, #1 //increment iobuf
    add r1, r1, #1 //increment bookbuf
    add r3, r3, #1 //increment counter
    cmp r3, r2 //if counter is less than count continue while loop, else done
    blt .Lwhile
    // do not alter anything below this line
.Ldone:
    mov     r0, r2              // return cnt processed
    sub     sp, fp, FP_OFF
    pop     {r4-r9, fp, lr}
    bx      lr

    .size encrypt, (. - encrypt)
    .section .note.GNU-stack,"",%progbits
.end
#endif
