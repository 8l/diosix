; hardware/pc/locore.s
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

; --------------------------------------------------------------------------
;  Provide low-level routines for the x86 PC architecture
;  follows x86-64 cdecl: http://www.x86-64.org/documentation/abi.pdf
; --------------------------------------------------------------------------

section .text
bits 64

global __morestack
; __morestack - Rust's magic stack overflow handling. For now, assume the
; kernel has enough stack space for each thread.
; See: https://github.com/mozilla/rust/blob/master/src/rt/arch/i386/morestack.S
__morestack:
    ret

; ----- IO routines --------------------------------------------------------

global hw_ioport_outb
; hw_ioport_outb - write a byte to an x86 IO port
; => rdi = port number (16-bit)
;    rsi = byte to write
hw_ioport_outb:
    mov  rdx, rdi       ; it's ok to trash rdx, rax
    mov  rax, rsi
    out  dx, al
    ret

global hw_ioport_readb
; hw_ioport_readb - read a byte from an x86 IO port
; => rdi = port number (16-bit)
; <= rax = byte read
hw_ioport_readb:
    xor  rax, rax       ; clear out rax in case of garbage
    mov  rdx, rdi       ; it's ok to trash edx
    in   al, dx
    ret


; ----- low-level memory management routines -------------------------------
;
; this assumes the kernel boot section is within the kernel image loaded
; into physical memory by the bootloader. the boot section could be
; recycled back into the pool of available memory once the kernel is running

extern __kernel_phys_start
extern __kernel_phys_end

extern __kernel_boot_phys_start
extern __kernel_boot_phys_end

global hw_get_kernel_phys_start
; hw_find_kernel_start - get the start address of the loaded kernel
; <= rax = pointer to the start of the loaded kernel (phys RAM addr)
hw_get_kernel_phys_start:
    mov rax, __kernel_phys_start
    ret

global hw_get_kernel_size
; hw_get_kernel_size - return the size of the loaded kernel in bytes
; <= rax = number of bytes of kernel
hw_get_kernel_size:
    mov rax, __kernel_phys_end
    sub rax, __kernel_phys_start
    ret

extern __kernel_boot_phys_start
global hw_get_kernel_boot_phys_start
; hw_find_kernel_start - get the start address of the kernel's boot section
; <= rax = pointer to the start of the kernel's boot section (phys RAM addr)
hw_get_kernel_boot_phys_start:
    mov  rax, __kernel_boot_phys_start
    ret

global hw_get_kernel_boot_size
; hw_get_kernel_size - return the size of the loaded kernel in bytes
; <= rax = number of bytes of kernel
hw_get_kernel_boot_size:
    mov rax, __kernel_boot_phys_end
    sub rax, __kernel_boot_phys_start
    ret

