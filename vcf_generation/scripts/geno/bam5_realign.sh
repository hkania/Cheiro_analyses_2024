#!/bin/bash

set -eo pipefail

echo -e "\n## Starting script bam5_realign.sh"
date
echo

# SET-UP -----------------------------------------------------------------------
## Software
SOFTWARE=/datacommons/yoderlab/programs
PYTHON3=$SOFTWARE/Python-3.6.3/python
JAVA=$SOFTWARE/java_1.8.0/jre1.8.0_144/bin/java
PICARD=$SOFTWARE/picard_2.13.2/picard.jar
GATK=$SOFTWARE/gatk-3.8-0/GenomeAnalysisTK.jar

## Command-line args
id=$1
indir=$2
outdir=$3
prefix_in=sort.MQ30.dedup
prefix_out=sort.MQ30.dedup.real
ref=/cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19.fasta
mem=12

## Process args
input=$indir/$id$prefix_in.bam
output=$outdir/$id$prefix_out.bam

## Report:
echo "## id:                 $id"
echo "## Indir:              $indir"
echo "## Outdir:             $outdir"
echo "## Prefix_in:          $prefix_in"
echo "## Prefix_out:         $prefix_out"
echo "## Reference fasta:    $ref"
echo "## Mem:                $mem"
echo

## Index bam if necessary:
source /hpc/home/hpk4/miniconda3/etc/profile.d/conda.sh
conda activate mapping_calling
[[ ! -f $indir/$id.$prefix_in*bai ]] && echo "## Indexing bam file..." && samtools index -b $input
conda deactivate

# LOCAL REALIGNMENT ------------------------------------------------------------
echo -e "\n## Performing local realignment - Step 1 - RealignerTargetCreator..."
$JAVA -Xmx"$mem"G -jar "$GATK" -T RealignerTargetCreator \
    -R "$ref" -I "$input" -o "$outdir"/"$id".intervals

echo -e "\n\n## Performing local realignment - Step 2 - IndelRealigner..."
$JAVA -Xmx"$mem"G -jar "$GATK" -T IndelRealigner \
    -R "$ref" -I "$input" --targetIntervals "$outdir"/"$id".intervals -o "$output"

## Report:
echo -e "\n## Listing output file:"
ls -lh "$output"
echo -e "\n## Done with script."
date
echo
