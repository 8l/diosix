/* hardware/pc/boot.rs
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

#[no_std];
#[feature(asm)];
#[path="../../kernel/lang.rs"]
mod lang;
mod io;

/* hardware_boot
   Called from start.s when the Rust environment has been set up. This function
   gradually brings the system up until we can start running userspace
   threads. This function shouldn't return unless something went wrong in the
   kernel boot sequence.
   <= Returns to trigger a low-level panic halt.
*/
#[no_mangle]
pub fn hardware_boot()
{
  let s: &str = "this is diosix!\n\0";
  let mut index = 0;
  while s[index] != '\0' as u8
  {
    io::write_byte(0x3f8, s[index]);
    index += 1;
  }
}

