
.global _start
.type _start, STT_FUNC
_start:
    ldr     x0, =stack_end
    mov     sp, x0

    ldr     w1, =hello
    movz    w0, #0x04    /* SWI: write0   */
    hlt     #0xf000
    movz    w0, #0x18    /* SWI: Exit     */
    hlt     #0xf000
    b       .            /* Infinite loop */

hello:
    .ascii "Hello, world!\n"

.bss
   .align 4
.global stack
.type stack, STT_OBJECT
stack:
   .skip 0x2000

.global stack_end
.type stack_end, STT_OBJECT
stack_end:

