ENTRY(_Reset)

phys = 0x80000000;
virt = 0xc0000000;

SECTIONS
{
   . = 0xc0010000;
   _knlstart = .;

   .startup . :
   {
      ../../build/armv7-a_versatileexpress/kernel/startup.o(.text)
   }

   .text : 
   { 
      *(.text)
   }

   .data : 
   { 
      *(.data)
   }

   .bss : 
   {
      _sbss = .;
      *(.bss)
      . = . + 4096; /* 4kB of stack memory */
      _ebss = .;
      KernelBootStackBase = .;
   }
}
