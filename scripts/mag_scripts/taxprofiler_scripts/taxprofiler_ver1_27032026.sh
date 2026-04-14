#!/bin/bash
#SBATCH --job-name=mag_run
#SBATCH --cpus-per-task=32
#SBATCH --mem=80G
#SBATCH --time=3:00:00
#SBATCH --output=taxprofilerrun_%j.log
#SBATCH --error=taxprofilerrun_%j.err


# Run nf-core/taxprofiler with sample and database sheets

module load nextflow/25.04.6
module load apptainer/1.4.0-rc.1

# 1) Directory with FASTQ + output folder
OUTDIR="taxprofiler_results"
SAMPLES="/gpfs/scratch/ajh20fhu/taxprofiler/samplesheet.csv"
DATABASES="/gpfs/scratch/ajh20fhu/taxprofiler/databases.csv"


# 2) Choose profile: docker / singularity / conda
#    Use your preferred container system
PROFILE="apptainer"

# 3) Which profilers to run (set flags)
RUN_KRAKEN2="--run_kraken2"
RUN_METAPHLAN="--run_metaphlan"

# 4) Run Nextflow
nextflow \
  run nf-core/taxprofiler -r 1.2.6 \
  -profile $PROFILE \
  --input $SAMPLES \
  --databases $DATABASES \
  --outdir $OUTDIR \
  $RUN_KRAKEN2 \
  $RUN_METAPHLAN \
  -resume

echo "nf-core/taxprofiler run launched"