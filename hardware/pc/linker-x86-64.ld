/* Linker script for x86-64 PC hardware kernels

   Cribbed from: http://wiki.osdev.org/64-bit_Higher_Half_Kernel_with_GRUB_2 */

ENTRY(start)

VIRT_BASE = 0xFFFFFFFF80000000;

SECTIONS
{
	. = 0x100000;

	.boot :
	{
		*(.multibootheader)
		*(.boot)
		. = ALIGN(4096);
	}

	. += VIRT_BASE;

	.text ALIGN(0x1000) : AT(ADDR(.text) - VIRT_BASE)
	{
		*(.text)
		*(.gnu.linkonce.t*)
	}
	
	.data ALIGN(0x1000) : AT(ADDR(.data) - VIRT_BASE)
	{
		*(.data)
		*(.gnu.linkonce.d*)
	}
	
	.rodata ALIGN(0x1000) : AT(ADDR(.rodata) - VIRT_BASE)
	{
		*(.rodata*)
		*(.gnu.linkonce.r*)
	}
	
	.bss ALIGN(0x1000) : AT(ADDR(.bss) - VIRT_BASE)
	{
		*(COMMON)
		*(.bss)
		*(.gnu.linkonce.b*)
	}
	
	/DISCARD/ :
	{
		*(.comment)
		*(.eh_frame)
	}
}

