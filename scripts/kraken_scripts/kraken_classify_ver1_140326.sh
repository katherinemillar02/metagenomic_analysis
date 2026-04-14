#!/bin/bash
#SBATCH --job-name=kraken_classify
#SBATCH --cpus-per-task=16
#SBATCH --mem=120G
#SBATCH --time=2-00:00
#SBATCH -o ./out/kraken_classify-%j.out
#SBATCH -e ./log/kraken_classify-%j.err

set -euo pipefail

module load kraken2/2.1.5

# ==========================
# PATHS
# ==========================

DB_DIR=/gpfs/scratch/ajh20fhu/kraken_db2
OUTDIR=/gpfs/scratch/ajh20fhu/medfly_metagenomics/results

SAMPLE=H_13_01

READ1=$OUTDIR/${SAMPLE}_nohost.fastq.1.gz
READ2=$OUTDIR/${SAMPLE}_nohost.fastq.2.gz

mkdir -p ./out
mkdir -p ./log

echo "======================================"
echo "STEP: KRAKEN2 CLASSIFICATION"
echo "Sample: $SAMPLE"
echo "Date: $(date)"
echo "======================================"

kraken2 \
  --db $DB_DIR \
  --threads 16 \
  --paired \
  --gzip-compressed \
  --use-names \
  --report $OUTDIR/${SAMPLE}.report \
  --output $OUTDIR/${SAMPLE}.kraken \
  $READ1 \
  $READ2

echo "Kraken classification finished"
echo "Pipeline complete: $(date)"