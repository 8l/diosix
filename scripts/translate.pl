# Copyright (c) 2014, Chris Williams (diosix.org)
# See LICENCE for usage and distribution conditions

# routines to translate files, thus performing i18n.
# this code will default to using en_US (sorry, Blighty).
# call &translate_init() with the name of the translation file and
# then call &translate() to look up strings from their tokens,
# passing any substrings that should be substituted in. eg:
# calling &translate("foo", "bar") will return the string for
# token 'foo', swapping any instances of %%1 with 'bar'.

# translation file format (spaces around the = is important):
# token = string

use strict;
my $__translate_name, my $__translate_language;
my %__translation;

# translate_init(name, language)
# Load translations/name.language file into memory for on-the-fly i18n
# => name = translation file to locate for given language
#    language = language to use or empty for the user's environment
#
sub translate_init
{
# sanitize the input to stop stupid stuff happening
  my $name = $_[0];
  $name =~ s/([^A-Za-z0-9]+)//g;
  my $language = $_[1];
  $language =~ s/([^A-Za-z_]+)//g;

# if no language was specified then use the environment's lang setting
  if($language eq "")
  {
    $ENV{'LANG'} =~ m/^([a-z]{2})_([A-Z]{2})/;
    $language = $1."_".$2;
  }

# find and open the translations file, defaulting to en_US if need be
  my $translations_base = "translations/".$name.".";

  if(!-e $translations_base.$language)
  {
    $language = "en_US";
  }
  if(!-e $translations_base.$language)
  {
    print "[-] Can't find any translations file for ".$name." environment!\n";
    exit 1;
  }

# stash the initialized translation system's settings in variables
  $__translate_name = $name;
  $__translate_language = $language;

# slurp the lot and stash as an array. skip blank lines and any starting with
# a hash character (a marker for a comment)
  open(TRANSLATIONS_FILE, $translations_base.$language) || die $!."\n";
  while(<TRANSLATIONS_FILE>)
  {
    chomp;
    my ($key, $value) = split / = /;
    if($key ne "" && $key !~ m/^(#{1})/)
    {
      $__translation{$key} = $value;
    }
  }
  close(TRANSLATIONS_FILE)
}

# translate(token, arg1 ... argn)
# return the string corresponding to the token key, replacing %%x with $argx literals
sub translate
{
# clean up the token and locate it in the translation hash
  my $token = $_[0];
  $token =~ s/[^A-Za-z0-9 ]//g;
  my $text = $__translation{$token};

# is the translation missing an entry?
  if($text eq "")
  {
    return "Missing translation for token '".$token."' in ".$__translate_name." (".$__translate_language.")";
  }

# then perform an substitutions necessary
  $text =~ s/%%([0-9]{1})/$_[$1]/g;
  return $text;
}

1;

