#!/usr/bin/perl

#     ZZZZZZZZZZZZZZZZZZZZ    8888888888888       00000000000
#   ZZZZZZZZZZZZZZZZZZZZ    88888888888888888    0000000000000
#                ZZZZZ      888           888  0000         0000
#              ZZZZZ        88888888888888888  0000         0000
#            ZZZZZ            8888888888888    0000         0000       AAAAAA         SSSSSSSSSSS   MMMM       MMMM
#          ZZZZZ            88888888888888888  0000         0000      AAAAAAAA      SSSS            MMMMMM   MMMMMM
#        ZZZZZ              8888         8888  0000         0000     AAAA  AAAA     SSSSSSSSSSS     MMMMMMMMMMMMMMM
#      ZZZZZ                8888         8888  0000         0000    AAAAAAAAAAAA      SSSSSSSSSSS   MMMM MMMMM MMMM
#    ZZZZZZZZZZZZZZZZZZZZZ  88888888888888888    0000000000000     AAAA      AAAA           SSSSS   MMMM       MMMM
#  ZZZZZZZZZZZZZZZZZZZZZ      8888888888888       00000000000     AAAA        AAAA  SSSSSSSSSSS     MMMM       MMMM
#
# Copyright (C) Paulo Custodio, 2011-2014
#
# Library of test utilities to test z80asm
#
# $Header: /home/dom/z88dk-git/cvs/z88dk/src/z80asm/t/TestZ80asm.pm,v 1.8 2014-05-29 00:19:37 pauloscustodio Exp $

use Modern::Perl;
use Exporter 'import';
use Test::More;
use Test::Differences; 
use Test::HexDifferences;
use File::Slurp;
use List::AllUtils 'uniq';
use Capture::Tiny::Extended 'capture';

our @EXPORT = qw( z80asm z80emu read_binfile write_binfile );

our $KEEP_FILES;
our $Z80ASM = $ENV{Z80ASM} || "./z80asm";

#------------------------------------------------------------------------------
# startup and cleanup
#------------------------------------------------------------------------------
BEGIN {
	$KEEP_FILES	 = grep {/-keep/} @ARGV; 
}

END {
	unlink_temp();
	done_testing();
}
		
#------------------------------------------------------------------------------
# z80asm - run an assembly session, check results
#	inputs:
#		asm[N] - assembly source, including:
#						;; 3E 00			- binary code of instruction
#						;; note: message	- show note
#						;; error: message	- expect error message in this line
#						;; warn: message	- expect warning message in this line
#						^;; error|warn:		- expect pass2 error at this module
# 		options - assemble options; if not defined, "-b -r0" is used
#		ok => 1 - needed if no binary file is generated (i.e. -x)
#		error - additional error messages not in asm source files
#		bin - result binary code
#------------------------------------------------------------------------------
sub z80asm {
	my(%args) = @_;

	note "Test at ",join(" ", caller);
	
	# test files
	my @asm_files;
	my $bin_file;
	my $bin = $args{bin} || "";
	my $err_text = "";
	my %err_file;
	my %obj_file;
	my $num_errors;
	for (sort keys %args) {
		if (my($id) = /^asm(\d*)$/) {
			# asm[n]
			unlink("test$id.err", "test$id.obj", "test$id.bin");
			
			$bin_file ||=    "test$id.bin";
			push @asm_files, "test$id.asm"
				unless ($args{options} || "") =~ /\@/;
			$obj_file{"test$id.obj"} = 1;
			write_file("test$id.asm", $args{$_});
			
			# parse asm code, build errors and bin
			my $line_nr = 0;
			for (split(/\n/, $args{$_})) {
				$line_nr++;
				if (/;;((\s+[0-9A-F][0-9A-F])+)/) {
					for (split(' ', $1)) {
						$bin .= chr(hex($_));
					}
				}
				if (/\s*;;\s+(error|warn)(\s(\d+))?:\s+(.*)/) {
					my $err = ($1 eq 'error' ? "Error" : "Warning").
							" at file 'test$id.asm' ".
							($3 ? "line $3" : "line $line_nr").
							": $4\n";
					$num_errors++ if $1 eq 'error';
					$err_text .= $err;
					$err_file{"test$id.err"} ||= "";
					$err_file{"test$id.err"} .= $err;		
					delete $obj_file{"test$id.obj"} if $1 eq 'error';
				}
				if (/;;\s+note:\s+(.*)/) {
					note($1);
				}
			}
		}
	}
	for (split(/\n/, $args{error} || "")) {
		$err_text .= "$_\n";
		$num_errors++ if /Error/i;
	}
	$err_text .= "$num_errors errors occurred during assembly\n" if $num_errors;
	
	# assembly command line
	my $z80asm = $Z80ASM." ".
				($args{options} || "-b -r0").
				" @asm_files";

	# assemble
	ok 1, $z80asm;
	my($stdout, $stderr, $return) = capture { system $z80asm; };
	
	# check output
	eq_or_diff_text $stdout, "", "stdout";
	eq_or_diff_text $stderr, $err_text, "stderr";
	my $expected_ok = ($bin ne "") || $args{ok};
	is !$return, !!$expected_ok, "exit";
	
	# check error file
	for (sort keys %err_file) {
		ok -f $_, "$_ exists";
		eq_or_diff scalar(read_file($_)), $err_file{$_}, "$_ contents";
	}
	
	# check object file
	for (sort keys %obj_file) {
		ok -f $_, "$_ exists";
	}
	
	# check binary
	if ($bin ne "") {
		my $bin_test_name = "binary (".length($bin)." bytes)";
		$bin_file ||= "test.bin";
		my $out_bin = read_binfile($bin_file);
		if ($out_bin eq $bin) {
			is $out_bin, $bin, $bin_test_name;
		}
		else {
			# slow - always generates hex dump even if equal
			eq_or_dump_diff $out_bin, $bin, $bin_test_name;
		}
	}
}

#------------------------------------------------------------------------------
# delete test files
#------------------------------------------------------------------------------
sub unlink_temp {
	my(@temp) = @_;
	push @temp, 
		grep { -f $_ }
		grep {/^ test .* \. (?: asm |
								lst |
								inc |
								bin |
								bn\d+ |
								map |
								obj |
								lib |
								sym |
								def |
								err |
								exe |
								c |
								o |
								asmlst |
								prj ) $/ix}
		read_dir(".");
	@temp = uniq(@temp);
	
	if ( ! $KEEP_FILES ) {
		ok unlink(@temp) == @temp, "unlink temp files";
	}
	else {
		note "kept temp files";
	}
}

#------------------------------------------------------------------------------
# Build and return file name of z80emu library
#------------------------------------------------------------------------------
sub z80emu {
	our $done_z80emu;	# only once per session
	my $z80emu_dir = '../../libsrc/z80_crt0s/z80_emu';
	my $z80emu = $z80emu_dir.'/z80mu.lib';
# need to check if legacy changed and compile with -d
#	if ( ! -f $z80emu ) {
	if ( ! $done_z80emu ) {
		z80asm(
			options	=> '-x'.$z80emu.' -Mo -ns '.join(' ', <$z80emu_dir/*.asm>),
			ok		=> 1,
		);
		$done_z80emu++;
	}
#	}
	return $z80emu;
}

#------------------------------------------------------------------------------
sub read_binfile {
	my($file) = @_;
	return scalar read_file($file, binmode => ':raw');
}

#------------------------------------------------------------------------------
sub write_binfile {
	my($file, $data) = @_;
	write_file($file, {binmode => ':raw'}, $data);
}

1;

# $Log: TestZ80asm.pm,v $
# Revision 1.8  2014-05-29 00:19:37  pauloscustodio
# CH_0025: Link-time expression evaluation errors show source filename and line number
# Object file format changed to version 04, to include the source file
# location of expressions in order to give meaningful link-time error messages.
#
# Revision 1.7  2014/05/13 23:42:49  pauloscustodio
# Move opcode testing to t/opcodes.t, add errors and warnings checks, build it by dev/build_opcodes.pl and dev/build_opcodes.asm.
# Remove opcode errors and warnings from t/errors.t.
# Remove t/cpu-opcodes.t, it was too slow - calling z80asm for every single Z80 opcode.
# Remove t/data/z80opcodes*, too complex to maintain.
#
# Revision 1.6  2014/05/09 23:12:35  pauloscustodio
# eq_or_dump_diff is slow - always generates hex dump even if equal;
# call only if different binary
#
# Revision 1.5  2014/05/08 21:57:35  pauloscustodio
# Test::HexDifferences to show differences in hex code
#
# Revision 1.4  2014/05/07 23:09:26  pauloscustodio
# Move tests of BUG_0016 to bugfixes.t
#
# Revision 1.3  2014/05/04 18:46:46  pauloscustodio
# Move tests of BUG_0008 to bugfixes.t
#
# Revision 1.2  2014/05/04 17:36:16  pauloscustodio
# Move tests of BUG_0004 to bugfixes.t
#
# Revision 1.1  2014/05/04 16:48:52  pauloscustodio
# Move tests of BUG_0001 and BUG_0002 to bugfixes.t, using TestZ80asm.pm
#

