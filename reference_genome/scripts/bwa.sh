#!/bin/bash

#SBATCH --account=yoderlab
#SBATCH --partition=yoderlab
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kania.hannah@duke.edu
#SBATCH --mem-per-cpu=8G

source /hpc/home/hpk4/miniconda3/etc/profile.d/conda.sh
conda activate mapping_calling

bwa index /cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19.fasta
