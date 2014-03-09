# Copyright (c) 2014, Chris Williams (diosix.org)
# See LICENCE for usage and distribution conditions

# routines to output text in a pretty way

use strict;

# call print_info, print_error, print_warning with a 
# string to send to stdout.

sub print_info
{
  print "[+] ".$_[0];
}

sub print_error
{
  print "[-] ".$_[0];
}

sub print_warning
{
  print "[!] ".$_[0];
}

# ------------------------------------------------------------------
# print_horizontal_rule(x)
# print x number of - characters to rule off a section
sub print_horizontal_rule
{
  my $max = $_[0];
  $max =~ s/[^0-9]//g;
  while($max > 0)
  {
    print "-";
    $max--;
  }
  print "\n";
}

1;

