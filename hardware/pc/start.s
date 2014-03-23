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

; -------------------------------------------------------------------
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

; -------------------------------------------------------------------
section .boot
bits 32
align 8
; kernel entry point from the multiboot bootloader
; 32bit protected mode using bootloader GDT
; 
; => eax = multiboot magic number
;    ebx = phys addr of multiboot data
start:

; debug: clear the textmode screen
clear_screen:
    mov  eax, 0x000b8000
    xor  ebx, ebx
clear_screen_loop:
    mov  [eax], bl
    add  eax, 2
    cmp  eax, 0x000b8000 + (2 * (80 * 25))
    jl   clear_screen_loop

    ; load our GDT, discarding the bootloader's
    lgdt [boot_32bit_gdt_ptr]
    mov  dx, boot_32bit_gdt_kernel_data - boot_32bit_gdt
    mov  ds, dx
    mov  es, dx
    mov  ss, dx
    mov  fs, dx
    mov  gs, dx
    jmp  (boot_32bit_gdt_kernel_code - boot_32bit_gdt):fixup_stack
    
fixup_stack:
    nop
    nop
    jmp  print_and_halt

; -------------------------------------------------------------------
;   mov  ecx, (boot_32bit_gdt_kernel_code - boot_32bit_gdt)

dump_hex_and_halt:
; => ecx = value to write
; <= doesn't return: will power off (or at least halt)
    mov  ebx, 8
    mov  dx, 0x3f8
dump_hex_and_halt_hexloop:
    mov  eax, ecx
    shr  eax, 28
    and  eax, 0xf
    cmp  eax, 9
    jle  dump_hex_and_halt_isanumber
    add  eax, 0x41 - 10     ; character code for 'A'
    jmp  dump_hex_and_halt_hexoutput
dump_hex_and_halt_isanumber:
    add  eax, 0x30          ; character code for '0'
dump_hex_and_halt_hexoutput:
    out  dx, al
    shl  ecx, 4
    sub  ebx, 1
    cmp  ebx, 0
    jne  dump_hex_and_halt_hexloop
    mov  al, 0xa
    out  dx, al

; debug: attempt to force a power shutdown or halt the system
force_dirty_power_off:
    mov  dx, 0xb004
    mov  ax, 0x2000
    out  dx, ax
    hlt
    jmp $

; debug: write a line to the textmode screen
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
    hlt
    jmp $

teststring:
    db 'I survived the GDT reload!'
    db 0

; -------------------------------------------------------------------
; boot gdt structures
align 16
boot_32bit_gdt:
    ; null descriptor
    dw 0      ; limit 15:0
    dw 0      ; base 15:0
    db 0      ; base 23:16
    db 0      ; type
    db 0      ; limit 19:16, flags
    db 0      ; base 31:24

boot_32bit_gdt_kernel_data:
    dw 0xffff
    dw 0
    db 0
    db 0x92   ; present, ring 0, data, expand-up, writable
    db 0xcf   ; page-granular (4 gig limit), 32-bit
    db 0

boot_32bit_gdt_kernel_code:
    dw 0xffff
    dw 0
    db 0
    db 0x9a   ; present, ring 0, code, non-conforming, readable
    db 0xcf   ; page-granular (4 gig limit), 32-bit
    db 0
boot_32bit_gdt_end:

boot_32bit_gdt_ptr:
    dw boot_32bit_gdt_end - boot_32bit_gdt - 1 ; size of gdt - 1
    dd boot_32bit_gdt


