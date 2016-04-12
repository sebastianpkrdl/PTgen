#!/usr/bin/perl

# Print the paths generated by an FST produced by "fstrandgen."

$argerr = 0;
$id = "";
$relabel_eps = 0;
$eps_symbol = "@";
while ((@ARGV) && ($argerr == 0)) {
	if($ARGV[0] eq "--relabel-eps") {
		shift @ARGV;
		$relabel_eps = 1;
	} elsif ($ARGV[0] eq "--eps-symbol") {
		shift @ARGV;
		$eps_symbol = shift @ARGV;
	} elsif ($id eq "") {
		$id = shift @ARGV;
	} else {
		$argerr = 1;
	}
}
$argerr = 1 if ($id eq "");

if($argerr == 1) {
	print "Usage: reverse_randgenfstpaths.pl [--relabel-eps]  [--eps-symbol <eps symbol>] <utterance id>\n";
	print "Input: from fstrandgen\n";
	print "Output: sequence of FST paths\n";
	exit(1);
}

%arcmap = ();
%startstate_map = ();
while(<STDIN>) {
	chomp;
	@fields = split(/\s+/);
	if($fields[0] == 0) {
		die "Only one path may start from a given state" if(exists $startstate_map{$fields[1]});
		$startstate_map{$fields[1]} = $fields[3];
	} elsif($#fields > 2) {
		# arc
		if(exists $startstate_map{$fields[0]}) {
			print "$id";
			if($startstate_map{$fields[0]} ne "-") { 
				print " $startstate_map{$fields[0]}";
			}
		}
		print " $eps_symbol" if ($relabel_eps == 1 && $fields[3] eq "-"); 
		print " $fields[3]" if  $fields[3] ne "-"; 
	} else {
		# final state
		print "\n";
	}
}
