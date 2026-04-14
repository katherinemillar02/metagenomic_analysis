#!/bin/bash
#SBATCH --job-name=kraken_classify2
#SBATCH --cpus-per-task=16
#SBATCH --mem=120G
#SBATCH --time=2-00:00
#SBATCH -o ./out2/kraken_classify2-%j.out
#SBATCH -e ./log2/kraken_classify2-%j.err

set -euo pipefail

module load kraken2/2.1.5

# Directories
DB_DIR=/gpfs/scratch/ajh20fhu/kraken_db2
IN_DIR=/gpfs/scratch/ajh20fhu/post-qc/results  # INPUT folder with *_nohost.fastq.1.gz / .2.gz
OUTDIR=/gpfs/scratch/ajh20fhu/medfly_metagenomics/results2  # OUTPUT folder

mkdir -p "$OUTDIR"
mkdir -p ./out2
mkdir -p ./log2

echo "======================================"
echo "KRAKEN2 CLASSIFICATION START"
echo "Date: $(date)"
echo "======================================"

# Loop through R1 FASTQ files
for READ1 in "$IN_DIR"/*_nohost.fastq.1.gz
do
    # Skip if no files match
    [ -e "$READ1" ] || { echo "No input files found in $IN_DIR"; break; }

    READ2=${READ1/.1.gz/.2.gz}
    SAMPLE=$(basename "$READ1" _nohost.fastq.1.gz)

    echo "Processing sample: $SAMPLE"

    kraken2 \
      --db "$DB_DIR" \
      --threads 16 \
      --paired \
      --gzip-compressed \
      --use-names \
      --report "$OUTDIR/${SAMPLE}.report" \
      --output "$OUTDIR/${SAMPLE}.kraken" \
      "$READ1" \
      "$READ2"

    echo "$SAMPLE classification finished"
done

echo "All samples finished: $(date)"