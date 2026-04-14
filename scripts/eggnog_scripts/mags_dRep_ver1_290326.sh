#!/bin/bash
#SBATCH --job-name=drep_run
#SBATCH --cpus-per-task=16
#SBATCH --mem=96G
#SBATCH --time=48:00:00
#SBATCH --output=drep_%j.log
#SBATCH --error=drep_%j.err

set -eo pipefail

# Activate conda
module load python/anaconda/2024.10/3.12.7

source $(conda info --base)/etc/profile.d/conda.sh
conda activate drep_env

# Paths
GENOME_DIR="/gpfs/scratch/ajh20fhu/nfcore/nfcore_magpipeline_21032026_trial/results/GenomeBinning/COMEBin/bins"
DEDUP_DIR="/gpfs/scratch/ajh20fhu/nfcore/nfcore_magpipeline_21032026_trial/results/GenomeBinning/COMEBin/bins/dRep"
DREP_OUT="/gpfs/scratch/ajh20fhu/nfcore/nfcore_magpipeline_21032026_trial/results/GenomeBinning/COMEBin/bins/dRep_results"

# Path to your existing CheckM results table
GENOME_INFO="/gpfs/scratch/ajh20fhu/nfcore/nfcore_magpipeline_21032026_trial/results/GenomeBinning/COMEBin/bins/CheckM/storage/bin_stats_ext.tsv"

mkdir -p "$DEDUP_DIR" "$DREP_OUT"

# Collect genome files (symlink instead of copy)
find "$GENOME_DIR" -type f \( -name "*.fa" -o -name "*.fna" -o -name "*.fasta" \) -exec ln -sf {} "$DEDUP_DIR" \;
echo "Genome files linked into dRep folder:"
ls -lh "$DEDUP_DIR"

# Make sure genomes exist
ls "$DEDUP_DIR"/*.fa >/dev/null 2>&1 || { echo "ERROR: No .fa files found"; exit 1; }

# Make sure genome info exists
if [[ ! -f "$GENOME_INFO" ]]; then
    echo "ERROR: genomeInfo file not found: $GENOME_INFO"
    exit 1
fi

# Run dRep
dRep dereplicate "$DREP_OUT" \
    -g "$DEDUP_DIR"/*.fa \
    --genomeInfo "$GENOME_INFO" \
    -p 16 \
    -comp 50 \
    -con 10

echo "dRep dereplication finished!"