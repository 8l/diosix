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

static ascii_numeral_base: u8  = 0x30;
static ascii_question_mark: u8 = 0x3f;
static ascii_lc_alpha_base: u8 = 0x61;

pub fn init()
{
  serial::init();
}

/* provide some routines to write to the serial port until Rust gets a
   freestanding printf equivalent */

pub fn write_string(s: &str)
{
  serial::write_string(s);
}

pub fn write_hex(mut value: u64)
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

