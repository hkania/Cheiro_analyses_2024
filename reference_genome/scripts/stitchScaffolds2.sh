#!/bin/bash

set -euo pipefail

# SET-UP -----------------------------------------------------------------------
echo "## Starting script: stitchScaffolds.sh"
date
echo


## Software and scripts
SOFTWARE=/datacommons/yoderlab/programs
PYTHON3=$SOFTWARE/Python-3.6.3/python
JAVA=$SOFTWARE/java_1.8.0/jre1.8.0_144/bin/java
PICARD=$SOFTWARE/picard_2.13.2/picard.jar
SCAFFOLD_STITCHER=$SOFTWARE/scaffoldStitcher/ScaffoldStitcher.py # https://bitbucket.org/dholab/scaffoldstitcher/src
SCRIPT_LOOKUP=/datacommons/yoderlab/users/hkania/cheiro/scripts/cheiro_stitched_genome/stitchScaffolds_extract2.R

## Command-line args
ID_IN=/cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19
ID_OUT=/cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19_merged
NR_N=1000
SCAF_EXCLUDE_INFILE=/datacommons/yoderlab/users/hkania/cheiro/reference_genome/scaffolds.nonAutosomal.txt
SCAF_SIZES_INFILE=/datacommons/yoderlab/users/hkania/cheiro/reference_genome/cheiro_scaff_lengths.txt

## Process args:
SCAF_INDEX_INFILE=/cwork/hpk4/cheiro_refgenome/fasta/joint_index.txt # Created by scaffoldStitcher
SCAF_INDEX_OUTFILE=$ID_OUT.scaffoldIndexLookup.txt # Created by stitchScaffolds_extract.R
SCAF_EXCLUDE_OUTFILE=$ID_OUT.nonAutosomalCoords.bed # Created by stitchScaffolds_extract.R
SCAFLIST_FILE=$ID_OUT.scaffoldList.txt # Created by stitchScaffolds_extract.R

## Report:
echo "## ID in: $ID_IN"
echo "## ID out: $ID_OUT"
echo "## Nr Ns between scaffolds: $NR_N"
echo
echo
echo "## Infile with scaffold sizes: $SCAF_SIZES_INFILE"
echo "## Infile with index of superscaffolds-to-scaffolds: $SCAF_INDEX_INFILE"
echo "## Infile with scaffolds to exclude: $SCAF_EXCLUDE_INFILE"
echo "## Outfile with lookup for superscaffolds-to-scaffolds $SCAF_INDEX_OUTFILE"
echo "## Outfile (bed) with regions to exclude from bam: $SCAF_EXCLUDE_OUTFILE"
echo "## Outfile with list of scaffolds: $SCAFLIST_FILE"
echo "## picard location : $PICARD"

echo -e "-----------------\n"

# INDEX NEW FASTA --------------------------------------------------------------
## Index new fasta with samtools, picard, and bwa:
echo -e "\n## Indexing ref genome with samtools..."
##SOFTWARE
source /hpc/home/hpk4/miniconda3/etc/profile.d/conda.sh
conda activate mapping_calling
samtools faidx /cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19.fasta

conda deactivate mapping_calling

echo -e "\n## Indexing ref genome with picard..."
[[ -f /cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19.fasta.dict ]] && rm /cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19.fasta.dict
$JAVA -Xmx4g -jar $PICARD CreateSequenceDictionary \
    R=/cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19.fasta O=/cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19.fasta.dict

echo -e "\n## Indexing ref genome with bwa..."
/datacommons/yoderlab/users/jelmer/proj/wgs/scripts/misc/indexGenome.sh /cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19.fasta


# CREATE BEDFILE AND LOOKUP TABLE ----------------------------------------------
## Create bedfile with regions to exclude, and superscaffold-to-scaffold location lookup table:
echo "## Running R script for superscaffold-to-scaffold location lookup table..."
module load R/4.0.0 

Rscript "$SCRIPT_LOOKUP" "$SCAF_SIZES_INFILE" "$SCAF_INDEX_INFILE" \
        "$SCAF_EXCLUDE_INFILE" "$SCAF_INDEX_OUTFILE" "$SCAF_EXCLUDE_OUTFILE" \
    "$SCAFLIST_FILE" "$NR_N"

module unload R/4.0.0
## Report:
echo -e "\nDone with script stitchScaffolds.sh"
date
