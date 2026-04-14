#!/bin/bash
#SBATCH --job-name=metaphlan_db_install
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=02:00:00
#SBATCH -o metaphlan_db_install-%j.out
#SBATCH -e metaphlan_db_install-%j.err

# Load module (use the one that exists on your system)
module load python/anaconda/2023.07/3.11.4

# Activate your conda environment
source activate metaphlan

# Set install location
DB_DIR=$HOME/metaphlan_db

mkdir -p $DB_DIR

echo "Installing MetaPhlAn database into $DB_DIR"

# Install database
metaphlan --install --bowtie2db $DB_DIR

echo "Done. Database installed at: $DB_DIR"