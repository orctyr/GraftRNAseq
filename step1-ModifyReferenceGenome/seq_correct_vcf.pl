#!/usr/bin/perl -w
#explanation:this program is edited to correct sequences by vcf file
#edit by taoye;   2013 07 19
use strict;
use Getopt::Long;

sub usage{
    print STDERR <<USAGE;
    Version 1.0 2013-7-19 taoye
    Correct sequences by vcf file 
	
    Options 
        -input    <s> : fasta file 
        -vcf      <s> : VCF file (version 4.1)
        -output   <s> : fasta file
        -type     <s> : homo or heter or all, default: homo
        -Qual     <n> : minimum genotype quality for variation, default:10 
        -mindepth <n> : minimum depth for variation, default: 5
        -maxdepth <n> : maximum depth for variation, default: 1000000
        -GQ       <n> : minmum genotype quality, default: 10
        -help         : show this help
USAGE
}

my ($input,$output,$vcf,$type,$Qual,$mdepth,$Mdepth,$GQ,$help);
GetOptions(
	"input:s"=>\$input,
	"output:s"=>\$output,
	"vcf:s"=>\$vcf,
	"type:s"=>\$type,
	"Qual:n"=>\$Qual,
	"mindepth:n"=>\$mdepth,
	"maxdepth:n"=>\$Mdepth,
	"GQ:n"=>\$GQ,
	"help"=>\$help,
);

if($help || !(defined $input) || !(defined $vcf)){
	usage;
	exit;
}

$Qual||=10;
$type||="homo";
$mdepth||=5;
$Mdepth||=1000000;
$GQ||=10;

my ($line,@inf,%seq,%vcf_info,%id);
open IN, "$input" or die "can not open file: $input\n";
$/=">";<IN>;
my $n=0;
while($line=<IN>){
	chomp $line;
	@inf=split /\n/,$line;
	my @temp=split /\s/,$inf[0];
	my $s="";
	for(my $i=1;$i<=$#inf;$i++){
		$s.=$inf[$i];
	}
	$seq{$temp[0]}=$s;
	$id{++$n}=$temp[0];
}
close IN;
print "$n sequences have been read\n";
$/="\n";

open IN, "$vcf" or die "can not open file: $vcf\n";
while($line=<IN>){
	next if($line=~/^#/);
	@inf=split /\t/,$line;
	my @ele1=split /[;=]/,$inf[7];
	my @ele2=split /[:]/,$inf[9];
	my $DP=$ele1[1];
	if($ele1[0] eq "INDEL"){
		$DP=$ele1[2];
	}
	next if($inf[5]<$Qual || $DP<$mdepth || $DP>$Mdepth || $ele2[2]<$GQ);
	if($type eq "homo"){
		if($ele2[0] eq "1/1"){
			$vcf_info{$inf[0]}.=$line;
		}
	}
	elsif($type eq "heter"){
		if($ele2[0] ne "1/1"){
			$vcf_info{$inf[0]}.=$line;
		}
	}
	else{
		$vcf_info{$inf[0]}.=$line;
	}
}
close IN;

#check vcf file (coordinate overlap or not)
foreach my $i (keys %vcf_info){
	@inf=split /\n/,$vcf_info{$i};
	for(my $j=0;$j<$#inf;$j++){
		my @ele1=split /\t/,$inf[$j];
		my @ele2=split /\t/,$inf[$j+1];
		if(($ele1[1]+length($ele1[3]))>$ele2[1]){
			if($ele1[5]>$ele2[5]){
				$ele2[4]=$ele2[3];
				my $temp=join("\t",@ele2[0..$#ele1]);
				$inf[$j+1]=$temp;
			}
			else{
				$ele1[4]=$ele1[3];
				my $temp=join("\t",@ele1[0..$#ele1]);
				$inf[$j]=$temp;
			}
		}
	}
}

#correct SNP & Indel 
foreach my $i (keys %vcf_info){
	@inf=split /\n/,$vcf_info{$i};
	for(my $j=$#inf;$j>=0;$j--){
		my @ele=split /\t/,$inf[$j];
		next if($ele[4] eq $ele[3]);
		my $ss=substr($seq{$i},0,$ele[1]-1);
		my $ee=substr($seq{$i},$ele[1]+length($ele[3])-1,(length($seq{$i})-$ele[1]-length($ele[3])+1));
		my @TG=split /[,]/,$ele[4];
		$seq{$i}=$ss.$TG[0].$ee;
	}
}

#write the results
open OA, ">$output" or die "can not open file: $output\n";
foreach my $i (sort {$a<=>$b} keys %id){
	print OA ">$id{$i}\n$seq{$id{$i}}\n";
} 
close OA;
