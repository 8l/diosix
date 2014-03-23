/* hardware/pc/io.rs
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

/* provide x86 IO port access to Rust code, it's really a wrapper around 
   assembly routines in locore.s */

#[no_std];
#[crate_type = "lib"];

extern "cdecl"
{
  fn hw_ioport_outb(port: u16, val: u8);
  fn hw_ioport_readb(port: u16);
}

/* io::write_byte
   Write a byte to the given x86 IO port
   => port = port number to access
   => val = byte to write
*/
pub fn write_byte(port: u16, val: u8)
{
  unsafe
  {
    hw_ioport_outb(port, val);
  }
}

/* io::read_byte
   Read a byte from the given x86 IO port
   => port = port number to access
   <= byte read
*/
pub fn read_byte(port: u16)
{
  unsafe
  {
    return hw_ioport_readb(port);
  }
}

