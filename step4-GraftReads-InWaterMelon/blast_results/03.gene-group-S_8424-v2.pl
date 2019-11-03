die "per 03.pl *.filter *gff *out\n" if(@ARGV!=3);
my ($line,@inf,%gene);
open IN, "$ARGV[1]" or die "can not open file: $ARGV[1]\n";
while($line=<IN>){
	chomp $line;
	@inf=split /\t/,$line;
	if($inf[2] eq "mRNA"){
		$inf[8]=~s/ID=//;
		$inf[8]=~s/\;//;
		$gene{$inf[0]}.=$inf[8]."\t".$inf[3]."\t".$inf[4]."\n";
	}
}
close IN;

open IN, "$ARGV[0]" or die "can not open file: $ARGV[0]\n";
my %gene_num=();
my ($total,$hits)=(0,0);
while($line=<IN>){
	chomp $line;
	@inf=split /\t/,$line;
	$total++;
	print "$total\n";
	my @ele=split /\n/,$gene{$inf[1]};
	for(my $i=0;$i<=$#ele;$i++){
		my @temp=split /\t/,$ele[$i];
		if($inf[5] >= $temp[1] && $inf[5] <= $temp[2]){
			$gene_num{$temp[0]}++;
			$hits++;
			last;
		}
		if($inf[6] >= $temp[1] && $inf[6] <= $temp[2]){
			$gene_num{$temp[0]}++;
			$hits++;
			last;
		}
	}
}
close IN;

open OA, ">$ARGV[2]"  or die "can not open file: $ARGV[2]\n";
foreach my $i (sort {$gene_num{$b}<=>$gene_num{$a}} keys %gene_num){
	print OA "$i\t$gene_num{$i}\n";
}
print OA "Total Reads:\t$total\n";
print OA "Hits Reads:\t$hits\n";
printf OA "Reads in Gene Region Percent:\t%.4f\n",$hits/$total;
close OA;
