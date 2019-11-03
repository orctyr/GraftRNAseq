die "perl $0 *.m8 *.m8.out\n" if(@ARGV!=2);
open IN, "$ARGV[0]" or die "can not open file: $ARGV[0]\n";
open OA, ">$ARGV[1]" or die "can not open file: $ARGV[1]\n";

my ($line,@inf,%score_data,%m8_data,%order);
my $n=1;
while($line=<IN>){
	chomp $line;
	@inf=split /\t/,$line;
	if($inf[11]>$score_data{$inf[0]}){
		$score_data{$inf[0]}=$inf[11];
		$m8_data{$inf[0]}=$line;
	}
	else{
		next;
	}	
	$order{$line}=$n++;
}
foreach my $i (sort {$order{$a}<=>$order{$b}} keys %order){
	@inf=split /\t/,$i;
	if(exists $m8_data{$inf[0]}){
		print OA "$m8_data{$inf[0]}\n";
	}
}
close IN;
close OA;
