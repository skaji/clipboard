#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.014;
use FindBin;
use lib "$FindBin::Bin/../lib";
use ClipBoard;
use Digest::MD5 qw(md5_hex);

my $db = ClipBoard->bootstrap->db;

my ($name, $pass) = @ARGV;
$pass or die "usage: $0 name pass\n";

$db->single('user', {name => $name})
    and die "ERROR already exists $name!\n";

$db->insert('user', {name => $name, pass => md5_hex("$name$pass")});



