#build genome index for bowtie2
bowtie2-build ReferenceGenome-Revised.fa ReferenceGenome-Revised

#Map Reads 
bowtie2 -p 8 --sensitive-local -1 R1.fastq.gz -2 R2.fastq.gz -S XX.bam --un XX.unmap
perl unmap-pair-pick.pl XX.unmap.bam XX-unmap

