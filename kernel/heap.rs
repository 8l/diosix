/* kernel/heap.rs
 *
 * Copyright (c) 2014, Chris Williams (diosix.org)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

use physmem;
pub mod debug;

/* kernel heap allocation routines */

#[lang = "exchange_malloc"]
pub unsafe fn alloc(size: uint) -> *mut u8
{
  let (kstart, ksize) = physmem::describe_kernel();
  let (kbstart, kbsize) = physmem::describe_kernel_boot();


  debug::write_variable("start of kernel", kstart as u64);
  debug::write_newline();
  debug::write_variable("size of kernel", ksize);
  debug::write_newline();
  debug::write_newline();
  
  debug::write_variable("start of kernel boot", kbstart as u64);
  debug::write_newline();
  debug::write_variable("size of kernel boot", kbsize);
  debug::write_newline();
  debug::write_newline();

  (0xffffffff80000000 + (64 * 1024 * 1024)) as *mut u8
}

#[lang = "exchange_free"]
pub unsafe fn free(ptr: *mut u8)
{

}

