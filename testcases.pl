#!/usr/bin/env perl
use strict;
use warnings;

=head1 NAME

testcases.pl

=head1 DESCRIPTION

Generates a data set to test the ruby bitwise string operations against
Perl's implementation in a brute force manner.

This doesn't really prove anything, it just a little confidence booster.

=cut

#sub OPERAND_MAX()  { 1024 }
sub OPERAND_MAX()  { 4096 }
sub TESTS_PER_OP() { 256  }

for my $i (1..TESTS_PER_OP) {
    my ($left,$right) = (operand(),operand());
    dump_testcase('|', $left | $right, $left, $right);
    dump_testcase('&', $left & $right, $left, $right);
    dump_testcase('^', $left ^ $right, $left, $right);
    dump_testcase('~', ~$left, $left);
}

sub randchr {
    our $_pool ||= ['A'..'Z','a'..'z',0..9];
    return $_pool->[rand @$_pool];
}

sub operand {
    join('', map { randchr() } (0..rand(OPERAND_MAX)));
}

sub dump_testcase {
    my ($op,$out,@args) = @_;
    print map { str2bin($_) } ($op,$out,@args);
}

sub str2bin {
    my ($str) = @_;
    pack('N', length($str)) . $str;
}

