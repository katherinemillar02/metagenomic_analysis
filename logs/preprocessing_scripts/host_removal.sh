#!/bin/bash
#SBATCH --job-name=medfly_metagenome
#SBATCH --cpus-per-task=16
#SBATCH --mem=120G
#SBATCH --time=2-00:00
#SBATCH -o ./out/kraken_classify-%j.out
#SBATCH -e ./log/kraken_classify-%j.err

set -euo pipefail

module load bowtie2/2.5.4
module load samtools/1.21
module load kraken2/2.1.5

# ==========================
# PATHS
# ==========================

DB_DIR=/gpfs/scratch/ajh20fhu/kraken_db2
MEDFLY_INDEX=/gpfs/scratch/ajh20fhu/medfly_index/medfly_index

R1=/gpfs/scratch/ajh20fhu/fastq/X204SC26022514-Z01-F001/01.RawData/H_13_01/H_13_01_EKDN260003873-1A_23FVJMLT4_L1_1.fq.gz
R2=/gpfs/scratch/ajh20fhu/fastq/X204SC26022514-Z01-F001/01.RawData/H_13_01/H_13_01_EKDN260003873-1A_23FVJMLT4_L1_2.fq.gz

OUTDIR=/gpfs/scratch/ajh20fhu/medfly_metagenomics/results
mkdir -p $OUTDIR

SAMPLE=H_13_01

echo "======================================"
echo "STEP 1: REMOVE MEDFLY HOST READS"
echo "Date: $(date)"
echo "======================================"

bowtie2 \
  -x $MEDFLY_INDEX \
  -1 $R1 \
  -2 $R2 \
  --threads 16 \
  --very-sensitive \
  --un-conc-gz $OUTDIR/${SAMPLE}_nohost.fastq.gz \
  -S /dev/null

echo "Host removal finished"

echo "======================================"
echo "STEP 2: KRAKEN2 CLASSIFICATION"
echo "======================================"

kraken2 \
  --db $DB_DIR \
  --threads 16 \
  --paired \
  --gzip-compressed \
  --report $OUTDIR/${SAMPLE}.report \
  --output $OUTDIR/${SAMPLE}.kraken \
  $OUTDIR/${SAMPLE}_nohost.1.fastq.gz \
  $OUTDIR/${SAMPLE}_nohost.2.fastq.gz

echo "Kraken classification finished"

echo "Pipeline complete: $(date)"