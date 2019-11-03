#Reference Genome Mapping and Variations Calling
bwa index ReferenceGenome.fa
samtools faidx ReferenceGenome.fa
bwa aln -o 1 -k 2 -e 10 -t 16 ReferenceGenome.fa R1.fastq.gz -f R1.fastq.gz.sai
bwa aln -o 1 -k 2 -e 10 -t 16 ReferenceGenome.fa R2.fastq.gz -f R2.fastq.gz.sai
bwa sampe -a 800 -r '@RG\tID:XX\tSM:XX\tLB:XX\tPU:run barcode\tPL:Illumina\tDS:resequencing\tCN:Biozeron' ReferenceGenome.fa R1.fastq.gz.sai R2.fastq.gz.sai R1.fastq.gz R2.fastq.gz | samtools view -S -b -t ReferenceGenome.fa.fai - > XX.unsort.bam
samtools sort  -m 4960000000 XX.unsort.bam XX.sort
samtools rmdup XX.sort.bam XX.bam
samtools index XX.bam
samtools mpileup -d 1000 -gSDf ReferenceGenome.fa XX.bam |bcftools view -cvNg – > XX.vcf
perl seq_correct_vcf.pl -input ReferenceGenome.fa -vcf XX.vcf -output     ReferenceGenome.fa2 -type homo -Qual 20 -mindepth 5 

#Unmapped Reads Picking and denovo
perl unmap-pair-pick.pl unmap.bam XX-unmap
SOAPdenovo2-63mer all -s XX-unmap-soap.config -d 1 -D 1 -F -K 23 -o XX
cat ReferenceGenome.fa2 XX.scaf > ReferenceGenome-revised.fa
