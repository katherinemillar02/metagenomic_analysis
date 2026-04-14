#!/bin/bash
#SBATCH --job-name=eggnog
#SBATCH --cpus-per-task=8
#SBATCH --time=24:00:00
#SBATCH --mem=32G
#SBATCH --output=eggnog_%j.out
#SBATCH --error=eggnog_%j.err

set -eo pipefail

# ---------------------------
# Activate conda
# ---------------------------
source /gpfs/software/ada/python/anaconda/2019.10/3.7/etc/profile.d/conda.sh
conda activate eggnog_env

# ---------------------------
# Set working directory
# ---------------------------
WORKDIR="/gpfs/scratch/ajh20fhu/nfcore/nfcore_magpipeline_21032026_trial/results/GenomeBinning/MaxBin2/bins/drep_MaxBin2_out/dereplicated_genomes"

cd "$WORKDIR" || { echo "ERROR: Cannot access $WORKDIR"; exit 1; }

echo "Working directory: $(pwd)"

# ---------------------------
# Set eggNOG database
# ---------------------------
EGGNOG_DATA_DIR="$WORKDIR/eggnog_db"

if [ ! -d "$EGGNOG_DATA_DIR" ]; then
    echo "ERROR: eggNOG database not found at $EGGNOG_DATA_DIR"
    exit 1
fi

echo "Using eggNOG database: $EGGNOG_DATA_DIR"

# ---------------------------
# Check input files
# ---------------------------
if ! ls *.fa 1> /dev/null 2>&1; then
    echo "ERROR: No .fa files found in $WORKDIR"
    exit 1
fi

# ---------------------------
# Run eggNOG
# ---------------------------
for fasta in *.fa; do

    echo "=============================="
    echo "Running eggNOG on ${fasta}"
    echo "Start time: $(date)"
    echo "=============================="

    base=$(basename "$fasta" .fa)

    emapper.py \
        -i "$fasta" \
        -o "${base}_eggnog" \
        --cpu 8 \
        --data_dir "$EGGNOG_DATA_DIR" \
        --translate \
        --itype genome \
        --override

    echo "Finished ${fasta} at $(date)"

done

echo "All MAGs completed successfully at $(date)"