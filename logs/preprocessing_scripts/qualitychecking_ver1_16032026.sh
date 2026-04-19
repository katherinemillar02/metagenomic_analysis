#!/bin/bash
#SBATCH --job-name=trim_reads
#SBATCH --output=trim_%j.out
#SBATCH --error=trim_%j.err
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G

module load trimgalore/0.6.10

RAW_DIR=/gpfs/scratch/ajh20fhu/fastq/X204SC26022514-Z01-F001/01.RawData
OUT_DIR=/gpfs/scratch/ajh20fhu/qc

mkdir -p $OUT_DIR

for R1 in $RAW_DIR/*/*_1.fq.gz
do

R2=${R1/_1.fq.gz/_2.fq.gz}

echo "Processing $R1"

trim_galore --paired \
--cores 8 \
--gzip \
-o $OUT_DIR \
$R1 $R2

done

echo "Trimming complete"