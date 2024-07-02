#!/bin/bash

#SBATCH --account=yoderlab
#SBATCH --partition=yoderlab
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kania.hannah@duke.edu
#SBATCH --mem-per-cpu=8G
#SBATCH --output=/cwork/hpk4/cheiro_refgenome/log/picard.out
#SBATCH --error=/cwork/hpk4/cheiro_refgenome/log/picard.err

set -euo pipefail

/datacommons/yoderlab/programs/java_1.8.0/jre1.8.0_144/bin/java -Xmx4g -jar \
/datacommons/yoderlab/programs/picard_2.13.2/picard.jar CreateSequenceDictionary \
R=/cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19.fasta O=/cwork/hpk4/cheiro_refgenome/fasta/ref_genome_mar19.fasta.dict
