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

/* allow the kernel to recast variables */

/* grab the compiler's built-in functions */
extern "rust-intrinsic"
{
  pub fn forget<T>(_: T) -> ();
  pub fn transmute<T,U>(e: T) -> U;
}

/* cast::kforget
   Take ownership of a variable but do not trigger any cleanup or memory
   management tasks – literally allow the system to forget about it.
   => var = variable to discard
*/
#[inline]
pub fn kforget<T>(var: T)
{
  unsafe
  {
    forget(var);
  }
}

/* cast::ktransmute::<L, G>
   Convert a variable from one type to another.
   => var = variable of type L to convert
   <= returns variable as type G
*/
#[inline]
pub fn ktransmute<L, G>(var: L) -> G
{
  unsafe
  {
    transmute(var)
  }
}

