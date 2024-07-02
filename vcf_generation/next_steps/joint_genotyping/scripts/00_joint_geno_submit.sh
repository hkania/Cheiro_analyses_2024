#!/bin/bash

# SETUP ------------------------------------------------------------------------
## Scripts
SCRIPT_GENO_INDS=/datacommons/yoderlab/users/hkania/cheiro/scripts/geno/01_ind-geno_runner.sh
SCRIPT_GENO_JOINT=/datacommons/yoderlab/users/hkania/cheiro/scripts/geno/02_joint-geno_runner.sh
SCRIPT_FILTER=/datacommons/yoderlab/users/hkania/cheiro/scripts/geno/03_filterVCF_FS6_runner.sh

## Input files
IDS_FILE_ALL=/datacommons/yoderlab/users/hkania/cheiro_tests_june24/metadata/xxx.txt
META_FILE=/datacommons/yoderlab/users/hkania/cheiro/metadata/test_metadata.tsv
REF_DIR=/cwork/hpk4/cheiro_refgenome/fasta
REF_ID=ref_genome_mar19  # Generate "stitched" genome from genome on NCBI by running `scripts/conversion/stitchScaffolds_submit.sh`
REF=$REF_DIR/$REF_ID.fasta
SCAFFOLD_FILE=$REF_DIR/$REF_ID.scaffoldList.txt

## Settings and output file
ids_short=($(cat "$IDS_FILE_ALL"))
gatk_version=gatk4
fq_dir=/datacommons/yoderlab/users/hkania/cheiro/final_fastq
bam_dir=/datacommons/yoderlab/users/hkania/cheiro/results/bam
vcf_dir=/datacommons/yoderlab/users/hkania/cheiro/results/geno
qc_dir_vcf=/datacommons/yoderlab/users/hkania/cheiro/results/geno/qc/vcf_ind
qc_dir_bam=/datacommons/yoderlab/users/hkania/cheiro/results/geno/qc/bam
minmapqual=30
mem=12
ncores=4
use_r2=TRUE
regions_file=notany
exclude_or_include_regions=notany

# FASTQ TO GVCF ----------------------------------------------------------------
bam_suffix=notany
skip_flags="--mRA"

for id_short in ${ids_short[@]}; do
    LANE=$(grep "$id_short" "$META_FILE" | cut -f 19 | head -n 1)
    LIBRARY=$(grep "$id_short" "$META_FILE" | cut -f 18 | head -n 1)
    readgroup_string="@RG\tID:${LANE}\tSM:${id_short}\tPL:ILLUMINA\tLB:${LIBRARY}"

    id_long_file=/datacommons/yoderlab/users/hkania/cheiro/metadata/cheiro/replicates/$id_short.txt
    grep "$id_short" "$META_FILE" | cut -f 1 > "$id_long_file"

        echo "Lane: ${lane} // Library: ${library}"
        echo "${readgroup_string}"
        echo "File with long IDs:"
        cat ${id_long_file}

# JOINT GENOTYPING -------------------------------------------------------------
Gvcf_dir=/datacommons/yoderlab/users/hkania/cheiro/results/geno/vcf/ind
vcf_dir=/datacommons/yoderlab/users/hkania/cheiro/results/geno/vcf/joint
qc_dir_vcf=/datacommons/yoderlab/users/hkania/cheiro/results/geno/qc/vcf
increment=1
start_at=1
stop_at="none"
add_commands="none"
mem_job=36
mem_gatk=28
ncores=1

## All cheiro inds:
file_id=cheiro.all
ids_short=($(cat "$IDS_FILE_ALL"))
echo ${ids_short[@]}
"$SCRIPT_GENO_JOINT" \
    "$file_id" "$SCAFFOLD_FILE" "$increment" "$start_at" "$stop_at" \
    "$Gvcf_dir" "$vcf_dir" "$qc_dir_vcf" "$REF" \
    "$add_commands" "$mem_job" "$mem_gatk" "$ncores" \
    ${ids_short[@]}
