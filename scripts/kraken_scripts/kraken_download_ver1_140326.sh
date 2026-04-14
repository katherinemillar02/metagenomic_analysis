#!/bin/bash

#SBATCH --mem=200G
#SBATCH --cpus-per-task=12
#SBATCH --time=2-00:00
#SBATCH --job-name=kraken_bacteria
#SBATCH -o ./out/kraken_bacteria-%j.out
#SBATCH -e ./log/kraken_bacteria-%j.err

set -euo pipefail

DB_DIR=/gpfs/scratch/ajh20fhu/kraken_db
DB_URL=https://genome-idx.s3.amazonaws.com/kraken/k2_standard_20260226.tar.gz

mkdir -p "$DB_DIR" out log

echo "======================================"
echo "DOWNLOADING KRAKEN2 DATABASE"
echo "Date: $(date)"
echo "======================================"

cd "$DB_DIR"

echo "Downloading database..."
wget -c "$DB_URL"

echo "Extracting database..."
tar -xvzf k2_standard_20260226.tar.gz

echo "Extraction complete."

echo "Checking downloaded files..."

CORRUPT=0
for FILE in $(find "$DB_DIR" -name "*.gz"); do
    gzip -t "$FILE" 2>/dev/null || { echo "Corrupted file: $FILE"; CORRUPT=1; }
done

if [ "$CORRUPT" -eq 1 ]; then
    echo "ERROR: Some files are corrupted."
    exit 1
fi

echo "======================================"
echo "Kraken2 DB downloaded and validated successfully."
echo "Date: $(date)"
echo "======================================"