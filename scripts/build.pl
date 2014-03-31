#!/usr/bin/perl

# Copyright (c) 2014, Chris Williams (diosix.org)
# See LICENCE for usage and distribution conditions

# USERSPACE // NOPRIVS // POSIX
# this script does NOT require privileges to run

use strict;
use File::Path;
use Getopt::Long;
use XML::Simple qw(:strict);
require 'scripts/translate.pl';   # provides interantionalisation
require 'scripts/formatting.pl';  # proves print_error,info,warning

# -------------------------------------------------------------------------
# build.pl - build part of diosix from a config file
#
# syntax: ./build.pl --arch <arch> --hardware <hardware> --component <component>
#
# Locate the config file for the given parameters and build it. 
# <arch>      = CPU architecture to target. possible options are:
#               - armv7-a (32-bit ARM, Aarch32)
#               - armv8-a (64-bit ARM, Aarch64, ARM64)
#	        - x86-64  (64-bit Intel x86, AMD64)
# <hardware>  = hardware platform to compile for. Possible options:
#               - foundation (ARM's AArch64 Cortex-A5x platform) 
#               - pc (x86 computer platform)
#               - versatileexpress (ARM's Aarch32 Cortex-Axx platforms) 
# <component> = what to build. possible options are:
# 		- kernel (the microkernel)

# prepare internationalization
&translate_init("build");

# -------------------------------------------------------------------------
# stop us from scrambling around for files that don't exist
my @supported_architectures = ("armv7-a", "armv8-a", "x86-64");
my @supported_hardware = ("foundation", "pc", "versatileexpress");
my @supported_components = ("kernel"); 

my $cmdline_arch;
my $cmdline_hardware;
my $cmdline_component;
my $cmdline_submodules;

Getopt::Long::Configure('bundling');
GetOptions('arch=s' => \$cmdline_arch,
	   'hardware=s' => \$cmdline_hardware,
	   'component=s' => \$cmdline_component,
           'update-submodules' => \$cmdline_submodules);

# Sanitize command line options
$cmdline_arch       =~ s/[^A-Za-z0-9\-]//g;
$cmdline_hardware   =~ s/[^A-Za-z0-9\-]//g;
$cmdline_component  =~ s/[^A-Za-z0-9\-]//g;
$cmdline_submodules =~ s/[^01]//g;

# if we've been given nothing then print the syntax and bail
if($cmdline_arch eq "" && $cmdline_hardware eq "" && $cmdline_component eq "")
{
  &print_error(&translate("syntax")."\n");
  exit 1;
}

# It's showtime
my $banner = " D I O S I X  ".&translate("banner")." v1.00 - www.diosix.org ";
&print_horizontal_rule(length $banner);
print $banner."\n";
&print_horizontal_rule(length $banner);

# -------------------------------------------------------------------------
# Make sure we're targeting something we support
my $match_architecture = 0;
foreach (@supported_architectures)
{
  if($_ eq $cmdline_arch)
  {
    $match_architecture = 1;
    last;
  }
}

my $match_hardware = 0;
foreach (@supported_hardware)
{
  if($_ eq $cmdline_hardware)
  {
    $match_hardware = 1;
    last;
  }
}

my $match_component = 0;
foreach (@supported_components)
{
  if($_ eq $cmdline_component)
  {
    $match_component = 1;
    last;
  }
}

# Warn (or bail) if any command line options are missing or wrong
if($cmdline_hardware eq "")
{
  &print_error(&translate("no hardware selected")." ".&translate("exiting")."\n");
  exit 1;
}

if($match_hardware != 1)
{
  &print_error(&translate("hardware not recognized",$cmdline_hardware)." ".&translate("exiting")."\n");
  exit 1;
}

if($cmdline_component eq "")
{
  &print_error(&translate("no component selected")." ".&translate("exiting")."\n");
  exit 1;
}

if($match_component != 1)
{
  &print_error(&translate("component not recognized",$cmdline_component)." ".&translate("exiting")."\n");
  exit 1;
}

if($cmdline_arch eq "")
{
  &print_warning(&translate("using default CPU")."\n");
}

if($match_architecture != 1 && $cmdline_arch ne "")
{
  &print_error(&translate("CPU not recognized",$cmdline_component)." ".&translate("exiting")."\n");
  exit 1;
}

# -------------------------------------------------------------------------
# generate config file location
my $config_base = "configs/";

# load config file
my $config_filename = $config_base.$cmdline_hardware.".xml";
my $config_default_filename = $config_base.$cmdline_hardware.".default.xml";

# check if there's a config file available, if not, then use the default
if(!-e $config_filename)
{
  $config_filename = $config_default_filename;
}
if(!-e $config_filename)
{
  &print_error(&translate("build config file not found", $config_filename)." ".&translate("exiting")."\n");
  exit 1;
}

# -------------------------------------------------------------------------
# get busy with the XML parsing. if you don't like XML, I'm sorry.

my $config = XMLin($config_filename,
                   KeyAttr => {hardware => 'name',
                               architecture => 'name',
                               component => 'name'},
                   ForceArray => ['hardware', 'architecture', 'component']);

# check we're looking at the right config file
if($config->{name} ne $cmdline_hardware)
{
  &print_error(&translate("build config file mismatch", $config_filename, $config->{name})." ");
  print &translate("exiting")."\n";
  exit 1;
}

# pin down a CPU architecture to target or give up
if($cmdline_arch eq "")
{
  $cmdline_arch = $config->{default};
  if($cmdline_arch eq "")
  {
    &print_error(&translate("build config has no default arch")." ".&translate("exiting")."\n");
    exit 1;
  }
}

if($config->{architecture}->{$cmdline_arch}->{description} eq "")
{
  &print_error(&translate("build config has no matching arch", $cmdline_arch)." ".&translate("exiting")."\n");
  exit 1;
}

&print_info(&translate("building for",
                       $config->{architecture}->{$cmdline_arch}->{component}->{$cmdline_component}->{description},
                       $config->{description},
                       $config->{architecture}->{$cmdline_arch}->{description})."\n");

# set up the build environment from the XML config file
$ENV{'BUILD_ARCH'} = $cmdline_arch;
$ENV{'BUILD_HARDWARE'} = $cmdline_hardware;
$ENV{'BUILD_FEATURES'} = $config->{architecture}->{$cmdline_arch}->{component}->{$cmdline_component}->{features};
$ENV{'BUILD_RUST'} = $config->{architecture}->{$cmdline_arch}->{toolchain}->{rust};
$ENV{'BUILD_CC'} = $config->{architecture}->{$cmdline_arch}->{toolchain}->{cc};
$ENV{'BUILD_LINKER'} = $config->{architecture}->{$cmdline_arch}->{toolchain}->{linker};
$ENV{'BUILD_ASM'} = $config->{architecture}->{$cmdline_arch}->{toolchain}->{assembler};

# generate the on-the-fly variables
$ENV{'BUILD_TIMESTAMP'} = `date -u`;
$ENV{'BUILD_REVISION'} = `git rev-list --count HEAD`;

# -------------------------------------------------------------------------
# pull the kernel versioning from its XML file
my $kernel = XMLin($config_base."kernel.xml", KeyAttr => {}, ForceArray => ['kernel']);
$ENV{'KERNEL_RELEASE_MAJOR'} = $kernel->{major};
$ENV{'KERNEL_RELEASE_MINOR'} = $kernel->{minor};
$ENV{'KERNEL_IDENTIFIER'} = $kernel->{codename};
$ENV{'DKERNEL_API_REVISION'} = $kernel->{api};

# -------------------------------------------------------------------------
# ensure we have build and release directories
my $builder_dir = $config->{architecture}->{$cmdline_arch}->{component}->{$cmdline_component}->{paths}->{build};
mkpath($builder_dir);
$ENV{'BUILD_OBJS_DIR'} = $builder_dir;

my $release_dir = $config->{architecture}->{$cmdline_arch}->{component}->{$cmdline_component}->{paths}->{release};
mkpath($release_dir);
$ENV{'RELEASE_DIR'} = $release_dir;

# -------------------------------------------------------------------------
# check our modules are up to date
if($cmdline_submodules == 1)
{
  &print_info(&translate("updating submodules")."\n");
  system("git submodule update --init --recursive");
  system("git submodule foreach git pull origin master");
}

# -------------------------------------------------------------------------
# call into the makefile
my $hardware_src_dir = $config->{architecture}->{$cmdline_arch}->{component}->{$cmdline_component}->{paths}->{source};
$ENV{'BUILD_HARDWARE_SRC_DIR'} = $hardware_src_dir;
$ENV{'BUILD_KERNEL_SRC_DIR'} = $config->{architecture}->{$cmdline_arch}->{component}->{$cmdline_component}->{paths}->{core};

my $makefile = $config->{architecture}->{$cmdline_arch}->{component}->{$cmdline_component}->{scripts}->{makefile};
my $linkerfile = $config->{architecture}->{$cmdline_arch}->{component}->{$cmdline_component}->{scripts}->{linkerfile};
$ENV{'BUILD_MAKEFILE'} = $makefile;
$ENV{'BUILD_LINKERFILE'} = $linkerfile;

system("make -f ".$makefile);

# -------------------------------------------------------------------------
exit 0;

