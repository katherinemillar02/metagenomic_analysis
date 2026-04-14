#!/bin/bash
#SBATCH --job-name=mag_run
#SBATCH --cpus-per-task=16
#SBATCH --mem=96G
#SBATCH --time=48:00:00
#SBATCH --output=nfcorerun_%j.log
#SBATCH --error=nfcorerun_%j.err

# Load modules
module load nextflow/25.04.6
module load apptainer/1.4.0-rc.1

# Run nf-core/mag
nextflow run nf-core/mag \
  -profile apptainer \
  --input /gpfs/scratch/ajh20fhu/scripts/nfcoresheet.csv \
  --outdir results \
  --skip_trimming \
  -resume \
  -process.memory 96.GB