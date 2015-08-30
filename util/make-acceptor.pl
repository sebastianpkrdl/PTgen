#!/usr/bin/perl
#
# Make an OpenFST acceptor out of a space-delimited string

while(<STDIN>){
	chomp;
	next if($_ =~ /^\s*$/);
	@lets = split(/\s+/);
	$state = 0;
	for($l = 0; $l <= $#lets; $l++) {
		print "$state\t",$state+1,"\t$lets[$l]\n";
		$state++;
	}
	print "$state\n";
	exit (0);
}

