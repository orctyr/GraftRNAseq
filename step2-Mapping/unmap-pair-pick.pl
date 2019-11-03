die "perl unmap-pair-pick.pl unmap.bam outfix\n" if(@ARGV!=2);

my ($line,@inf,%read);
open IN, "samtools view $ARGV[0] |" or die "can not open file: $ARGV[0]\n";
while($line=<IN>){
	chomp $line;
	@inf=split /\t/,$line;
	if(!defined $read{$inf[0]}){
		$read{$inf[0]}=$inf[9];
	}
	else{
		$read{$inf[0]}.="-".$inf[9];
	}
}
close IN;

open OA, ">$ARGV[1]" or die "can not open file: $ARGV[1]\n";
foreach my $i (keys %read){
	next if($read{$i}!~/[-]/);
	@inf=split /-/,$read{$i};
	print OA ">$i/1\n$inf[0]\n";
	print OA ">$i/2\n$inf[1]\n";
}
close OA;

