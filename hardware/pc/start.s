; hardware/pc/start.s
; 
; Copyright (c) 2014, Chris Williams (diosix.org)
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

; ----------------------------------------------------------------------------
;  Bring up a standard PC system ready for the main microkernel
; ----------------------------------------------------------------------------

global start
extern hardware_boot

; define numbers for multiboot header, see this PDF for the full spec
; http://download-mirror.savannah.gnu.org/releases/grub/phcoder/multiboot.pdf
MULTIBOOT_MAGIC     equ 0xe85250d6

bits 32

; include necessary messy magic to keep Grub2 bootloader happy. we're loaded
; as a 32-bit x86 ELF executable, then we quickly switch to 64-bit mode
section .multibootheader
align 8
multibootheader:
    dd MULTIBOOT_MAGIC                       ; magic number
    dd 0                                     ; architecture (Intel ia32)
    dd multibootheader_end - multibootheader ; length
    ; checksum of the contents of the header
    dd -(MULTIBOOT_MAGIC + 0 + (multibootheader_end - multibootheader))

    ; next, we include a series of tags for Grub2 to parse
    dw 1    ; type 1 tag (request information from bootloader)
    dw 1    ; set bit 0 of flag word to indicate requested info is optional
    dd 8 + (4 * 4) ; size of this tag in bytes
    dd 3    ; request type 3: modules loaded with this kernel
    dd 4    ; request type 4: basic RAM size
    dd 6    ; request type 6: memory map
    dd 10   ; request type 10: advance power mngt (APM) table

    ; align modules to page boundaries by including this tag
    dw 6, 0 ; type 6 tag (module alignment) with zero'd flag word
    dd 8    ; this tag is 8 bytes in size (spec PDF is wrong)

    ; last tag
    dw 0, 0 ; type 0 tag (terminating tag) with zero'd flag word
    dd 8    ; this tag is 8 bytes in size
multibootheader_end:

section .boot
bits 32
align 8
start:

clear_screen:
    mov  eax, 0x000b8000
    xor  ebx, ebx
clear_screen_loop:
    mov  [eax], bl
    add  eax, 2
    cmp  eax, 0x000b8000 + (2 * (80 * 25))
    jl   clear_screen_loop


print_and_halt:
    mov  eax, 0x000b8000
    mov  ebx, teststring
    xor  ecx, ecx
    xor  edx, edx
print_loop:
    mov  dl, [ebx]
    cmp  dl, 0
    je   do_halt
    mov  [eax], dl
    add  eax, 2
    inc  ebx
    jmp  print_loop
do_halt:
    jmp $

teststring:
    db 'hello, world!'
    db 0
