#!/bin/bash

# SETUP ------------------------------------------------------------------------
## Scripts
SCRIPT_GENO_INDS=/datacommons/yoderlab/users/hkania/cheiro/scripts/geno/01_ind-geno_runner.sh
SCRIPT_GENO_JOINT=/datacommons/yoderlab/users/hkania/cheiro/scripts/geno/02_joint-geno_runner.sh
SCRIPT_FILTER=/datacommons/yoderlab/users/hkania/cheiro/scripts/geno/03_filterVCF_FS6_runner.sh

## Input files
IDS_FILE_ALL=/datacommons/yoderlab/users/hkania/cheiro_tests_june24/metadata/ccro001_test.txt
###IDS_FILE_HZPROJ1=metadata/cheiro_metadata.tsv
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

        echo "Lane: ${LANE} // Library: ${LIBRARY}"
	echo "${readgroup_string}"
        echo "File with long IDs:"
        cat ${id_long_file}

	 sbatch -p yoderlab,common,scavenger -N 1-1 --ntasks 4 --mem-per-cpu 4G --job-name=genoInd_cheiro -o slurm.genoInd.$id_short \
        "$SCRIPT_GENO_INDS" \
        "$id_short" "$id_long_file" "$use_r2" "$REF" \
        "$fq_dir" "$bam_dir" "$vcf_dir" "$qc_dir_vcf" "$qc_dir_bam" \
        "$minmapqual" "$gatk_version" "$bam_suffix" "$readgroup_string" \
        "$regions_file" "$exclude_or_include_regions" "$mem" "$ncores" "$skip_flags"

        printf "\n"

done

## Process QC results (run after the above job is completed!)
# cat "$qc_dir_bam"/*meandepth* > "$qc_dir_bam"/cheiro_meanDepth.txt
# cat "$qc_dir_vcf"/vcftools/*FS6*idepth | grep -v "INDV" > "$qc_dir_vcf"/vcftools/cheiro_idepth.txt
