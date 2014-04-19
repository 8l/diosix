/* kernel/cast.rs
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

/* cast types for the rust system. Oh wait, I'm supposed to use transmute?
   OK, you go implement that for me in a freestanding environment and I'll
   await your patch. BTW at time of writing, transmute() is not documented.
*/

/* glue ourselves to the hardware layer - functions to be implemented */
extern "cdecl"
{
  fn hw_pointer_to_u64(ptr: ~u64) -> u64;
}

/* pointer_to_u64
   Turn a pointer into a 64-bit unsigned integer.
   => ptr = pointer to convert
*/
#[inline]
pub fn pointer_to_u64(ptr: ~u64) -> u64
{
  unsafe
  {
    return hw_pointer_to_u64(ptr);
  }
}

