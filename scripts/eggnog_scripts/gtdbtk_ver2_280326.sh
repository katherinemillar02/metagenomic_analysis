#!/bin/bash
#SBATCH --job-name=mag_run
#SBATCH --cpus-per-task=16
#SBATCH --mem=96G
#SBATCH --time=48:00:00
#SBATCH --output=gtdbtk_%j.log
#SBATCH --error=gtdbtk_%j.err

# Load conda properly
source /gpfs/software/ada/python/anaconda/2019.10/3.7/etc/profile.d/conda.sh

# Activate environment
conda activate gtdbtk_env

# Set database path
export GTDBTK_DATA_PATH=/gpfs/scratch/ajh20fhu/gtdbtk_db/release226

# Input and output
GENOME_DIR="/gpfs/scratch/ajh20fhu/nfcore/nfcore_magpipeline_21032026_trial/results/GenomeBinning/MetaBinner/bins"
OUT_DIR="/gpfs/scratch/ajh20fhu/nfcore/gtdbtk_db/results_MetaBinner"
mkdir -p "$OUT_DIR"

# Make a temporary genome folder containing all .fa files
FLAT_GENOME_DIR="${OUT_DIR}/all_bins_fa"
mkdir -p "$FLAT_GENOME_DIR"

# Copy all .fa files from all subfolders into one directory
find "$GENOME_DIR" -type f -name "*.fa" -exec cp {} "$FLAT_GENOME_DIR" \;


# Run GTDB-Tk
gtdbtk classify_wf \
  --genome_dir "$FLAT_GENOME_DIR" \
  --out_dir "$OUT_DIR" \
  --extension fa \
  --cpus 16 \
  --pplacer_cpus 1
echo "GTDB-Tk job finished!"