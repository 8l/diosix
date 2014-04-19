/* kernel/debug.rs
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

use serial;

/* describe UTF-8/ASCII-compatible characters */
static ascii_numeral_base: u8  = 0x30; /* ASCII for '0' */
static ascii_question_mark: u8 = 0x3f; /* ASCII for '?' */
static ascii_lc_alpha_base: u8 = 0x61; /* ASCII for 'a' */

/* provide some routines to send debugging information to the physical
   world - the default is the machine's RS232-style serial port */

pub fn init()
{
  serial::init();
}

/* debug::write_string
   Send a string to the defined debugging output channel.
   => s = string to write out to the channel
*/
pub fn write_string(s: &str)
{
  /* we'll probably map debug's output to something else later,
     or provide the option to, so keep things generic for now */
  serial::write_string(s);
}

/* debug::write_newline
   Send a newline, as you'd expect... */
pub fn write_newline()
{
  write_string("\n");
}

/* debug::write_hex
   Write a 64-bit hex number in ASCII to the debug channel, including
   the preceeding '0x' sequence.
   => value = number to write out as an ASCII string
*/
pub fn write_hex(value: u64)
{
  write_string("0x");

  let mut index = 16;
  while index > 0
  {
    let mut shift_value = value;
    let mut shift_index = index - 1;

    while shift_index > 0
    {
      shift_value = shift_value >> 4;
      shift_index = shift_index - 1;
    }

    serial::write_byte(match (shift_value & 0xf) as u8
    {
       0 ..  9 => (shift_value & 0xf) as u8 + ascii_numeral_base,
      10 .. 15 => (shift_value & 0xf) as u8 + ascii_lc_alpha_base - 10,
             _ => ascii_question_mark
    });

    index = index - 1;
  }
}

/* debug::write_variable
   Write a label and a value to the serial port, no \n character included
   => label = string to describe the variable
       value = value to write out
*/
pub fn write_variable(label: &str, value: u64)
{
  write_string(label);
  write_string(" = ");
  write_hex(value);
}

