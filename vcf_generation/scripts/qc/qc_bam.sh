#!/bin/bash

set -euo pipefail

##### SET-UP -------------------------------------------------------------------
## Software
SOFTWARE=/datacommons/yoderlab/programs
EAUTILS_SAMSTATS=$SOFTWARE/ExpressionAnalysis-ea-utils-bd148d4/clipper/sam-stats

## Command-line args
ID=$1
SUFFIX=sort.MQ30.dedup.real
INPUT=/datacommons/yoderlab/users/hkania/cheiro/results/bam/intermed/$ID$SUFFIX
OUTDIR=$3
REF=$4
MEM=$5
UNSORTED=$6

## Report
echo "## Starting script qc_bam.sh"
date
echo
echo "## ID:                $ID"
echo "## Input:             $INPUT"
echo "## Outdir:            $OUTDIR"
echo "## Reference fasta:   $REF"
echo "## Mem:               $MEM"


# PREP BAMFILE -----------------------------------------------------------------
export PATH=/opt/apps/modulefiles/samtools/1.10:$PATH
module load samtools/1.10
if [ "$UNSORTED" = TRUE ]; then
	
    echo -e "\n## Sorting bam file..."
	BAM_ID=$(basename -s .bam "$INPUT")
	BAM_DIR=$(dirname "$INPUT")
	SORTED_FILE="$BAM_DIR"/"$BAM_ID".sort.bam
	
    samtools sort -@ 1 -m 4G -T tmp -O bam "$INPUT" > "$SORTED_FILE"
	
    INPUT="$SORTED_FILE"
	echo "## Input is now: $INPUT"
fi

[[ ! -f "$INPUT".bai ]] && samtools index -b "$INPUT.bam"

echo -e "## Bam input file:"
ls -lh "$INPUT.bam"


# RUN QC -----------------------------------------------------------------------
## Depth/coverage
echo -e "## Checking coverage..."

samtools depth "$INPUT.bam" > "$OUTDIR"/"$ID".depth_samtools.txt
MEANDEPTH=$(awk '{sum+=$3} END {print sum/NR}' "$OUTDIR"/"$ID".depth_samtools.txt)

echo "## Coverage for $ID is: $MEANDEPTH"
echo "$ID $MEANDEPTH" > "$OUTDIR"/"$ID".meandepth_samtools.txt

rm -f "$OUTDIR"/"$ID".depth_samtools.txt

## Samtools flagstat
echo -e "\n## Running samtools flagstat..."
samtools flagstat "$INPUT.bam" > "$OUTDIR"/"$ID".samtools-flagstat.txt

echo -e "## samtools flagstat output file:..."
ls -lh "$OUTDIR"/"$ID".samtools-flagstat.txt

module unload samtools/1.10

## ea-utils samstats
echo -e "## Running ea-utils samstats..."
$EAUTILS_SAMSTATS -D -B "$INPUT.bam" > "$OUTDIR"/"$ID".ea-utils-samstats.txt

echo -e "## ea-utils output file:..."
ls -lh "$OUTDIR"/"$ID".ea-utils-samstats.txt

## Report
echo -e "\n## Done with script qc_bam.sh"
date
echo
