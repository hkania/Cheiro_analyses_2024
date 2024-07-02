#!/bin/bash

#SBATCH --account=yoderlab
#SBATCH --partition=yoderlab
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kania.hannah@duke.edu
#SBATCH --mem-per-cpu=8G
#SBATCH --output=/cwork/hpk4/cheiro_refgenome/log/R3.out
#SBATCH --error=/cwork/hpk4/cheiro_refgenome/log/R3.err

module load R/4.0.0

Rscript /datacommons/yoderlab/users/hkania/cheiro/scripts/cheiro_stitched_genome/stitchScaffolds_extract2.R /datacommons/yoderlab/users/hkania/cheiro/reference_genome/cheiro_scaff_lengths.txt /cwork/hpk4/cheiro_refgenome/fasta/joint_index.txt \
	/datacommons/yoderlab/users/hkania/cheiro/reference_genome/scaffolds.nonAutosomal.txt /cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19_merged.scaffoldIndexLookup.txt /cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19_merged.nonAutosomalCoords.bed \
	/cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19_merged.scaffoldList.txt 1000

module unload R/4.0.0
