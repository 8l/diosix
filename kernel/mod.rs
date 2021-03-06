/* kernel/mod.rs
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

static kernel_banner: &'static str = "diosix (x86-64 pc) now running\n";

pub mod debug;
pub mod heap;
pub mod cast;

fn owned_ptr(val: u64) -> ~u64
{
  let ptr: ~u64 = ~val;
  return ptr;
}

/* ---- kernel entry point for Rust ----------------------------------------- */

/* kernel_start
   Called from start.s when the Rust environment has been set up. This function
   gradually brings the system up until we can start running userspace
   threads. This function shouldn't return unless something went wrong in the
   kernel boot sequence.
   <= Returns to trigger a low-level panic halt.
*/
#[no_mangle] /* don't mangle the function name, it's being called from asm */
pub fn kernel_start()
{
  debug::init(); /* prepare the serial port for debug output */
  debug::write_string(kernel_banner);

  let i: ~u64 = owned_ptr(10);
  let x: u64 = cast::ktransmute::<_, u64>(&*i);

  debug::write_variable("i (value)", *i);
  debug::write_newline();
  debug::write_variable("i (pointer)", x);
  debug::write_newline();
}

