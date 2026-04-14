#!/bin/bash
#SBATCH --job-name=medfly_metaphlan_classify
#SBATCH --cpus-per-task=16
#SBATCH --mem=120G
#SBATCH --time=2-00:00
#SBATCH -o ./out/metaphlan_classify-%j.out
#SBATCH -e ./log/metaphlan_classify-%j.err

set -euo pipefail

# ---- Fix conda in non-interactive shell ----
export PS1=""
export _CONDA_SET_PROJ_LIB=""

set +u
source /gpfs/software/ada/python/anaconda/2019.10/3.7/etc/profile.d/conda.sh
conda activate metaphlan
set -u

# ---- Check tool ----
echo "MetaPhlAn path: $(which metaphlan)"
metaphlan --version

# ---- Directories ----
INPUT_DIR=/gpfs/scratch/ajh20fhu/post-qc/results
OUTPUT_DIR=metaphlan_results
LOG_DIR=logs

mkdir -p "$OUTPUT_DIR" "$LOG_DIR" out log

MASTER_LOG="${LOG_DIR}/metaphlan_master.log"
ERROR_LOG="${LOG_DIR}/metaphlan_error.log"

echo "=== START $(date) ===" | tee -a "$MASTER_LOG"

# ---- Find input files safely ----
shopt -s nullglob
FILES=("$INPUT_DIR"/*.fastq.1.gz)

if [ ${#FILES[@]} -eq 0 ]; then
    echo "ERROR: No input files found in $INPUT_DIR" | tee -a "$ERROR_LOG"
    exit 1
fi

# ---- Loop over samples ----
for R1 in "${FILES[@]}"
do
    R2="${R1/.fastq.1.gz/.fastq.2.gz}"
    SAMPLE=$(basename "$R1" .fastq.1.gz)

    echo "Processing $SAMPLE" | tee -a "$MASTER_LOG"

    # Check paired file
    if [ ! -f "$R2" ]; then
        echo "ERROR: Missing R2 for $SAMPLE: $R2" | tee -a "$ERROR_LOG"
        continue
    fi

    # Run MetaPhlAn
    metaphlan "${R1},${R2}" \
        --input_type fastq \
        --nproc ${SLURM_CPUS_PER_TASK} \
        -o "${OUTPUT_DIR}/${SAMPLE}_profile.txt" \
        >> "$MASTER_LOG" 2>> "$ERROR_LOG"

    if [ $? -eq 0 ]; then
        echo "SUCCESS: $SAMPLE" | tee -a "$MASTER_LOG"
    else
        echo "FAILED: $SAMPLE" | tee -a "$ERROR_LOG"
    fi

done

echo "=== END $(date) ===" | tee -a "$MASTER_LOG"