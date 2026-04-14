#!/bin/bash
#SBATCH --job-name=medfly_metaphlan_classify
#SBATCH --cpus-per-task=16
#SBATCH --mem=120G
#SBATCH --time=2-00:00
#SBATCH -o ./out/metaphlan_classify-%j.out
#SBATCH -e ./log/metaphlan_classify-%j.err

module load python/anaconda/2023.07/3.11.4
source activate metaphlan

cd $SLURM_SUBMIT_DIR
cd results

mkdir -p ../out

# Path to your MetaPhlAn database
DB_PATH=$HOME/metaphlan_db

# Loop through R1 files
for R1 in *_nohost.fastq.1.gz
do
    SAMPLE=$(basename "$R1" _nohost.fastq.1.gz)
    R2="${SAMPLE}_nohost.fastq.2.gz"

    echo "Processing $SAMPLE"

    metaphlan "${R1},${R2}" \
        --bowtie2db $DB_PATH \
        --unknown_estimation \
        --nproc 16 \
        --input_type fastq \
        -o ../out/${SAMPLE}.profiled_metagenome.txt

done