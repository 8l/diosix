/* hardware/pc/serial/mod.rs
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

/* provide a tidy interface to the underlying serial port hardware,
   for kernel debugging purposes */

use core;
use core::slice::iter;
use core::iter::Iterator;
use core::option::{Some, None};

use io;

/* assume this is the default port for COM1 */
static com1_io_base: u16 = 0x3f8;

/* line status bit to indicate port is ready to transmit */
static com1_tx_ready: u8 = 0x20;

/* describe registers */
enum Registers
{
  Data = 0,
  Irq = 1,
  Status = 5,
}

/* serial::init
   Initialize the serial port COM1 for debug in and out
*/
pub fn init()
{
  /* disable interrupts for sake of simplicity.
     use the firmware's defaults for other settings */
  io::write_byte(com1_io_base + Irq as u16, 0 as u8);
}

/* serial::write_byte
   Write an 8-bit character to the serial port
   => ch = byte to write when the port is ready
*/
pub fn write_byte(ch: u8)
{
  /* spin until the port is ready to transmit */
  loop
  {
    let tx_status: u8 = io::read_byte(com1_io_base + Status as u16);
    if (tx_status & com1_tx_ready) != 0
    {
      break;
    }
  }

  io::write_byte(com1_io_base + Data as u16, ch);
}

/* serial::write_string
   Write the given string out to the serial port
   => s = pointer to string
*/
pub fn write_string(s: &str)
{
  /* Rust stores strings with a length, so let's
     do this properly rather than scan for a \0 */
  let byte_stream: &[u8] = core::str::as_bytes(s);
  for byte in core::slice::iter(byte_stream)
  {
    write_byte(*byte);
  }
}

