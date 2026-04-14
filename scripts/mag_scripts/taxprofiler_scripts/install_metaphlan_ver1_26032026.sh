#!/bin/bash
# Script to install MetaPhlAn 4.x and its database automatically

# -----------------------------
# Paths
DB_DIR="/gpfs/scratch/ajh20fhu/metaphlan_db"
ENV_DIR="$HOME/metaphlan_env"
DB_ARCHIVE="mpa_v30_CHOCOPhlAnSGB_202503.tar"

mkdir -p $DB_DIR

# -----------------------------
# 1) Create Python virtual environment
if [ ! -d "$ENV_DIR" ]; then
    echo "Creating Python venv at $ENV_DIR ..."
    python3 -m venv $ENV_DIR
fi

# Activate environment
source $ENV_DIR/bin/activate

# Upgrade pip
pip install --upgrade pip

# -----------------------------
# 2) Install MetaPhlAn
echo "Installing MetaPhlAn 4.2.4..."
pip install metaphlan==4.2.4 --upgrade

# Verify installation
if ! command -v metaphlan &> /dev/null; then
    echo "ERROR: MetaPhlAn not found. Installation failed."
    exit 1
fi
echo "MetaPhlAn installed successfully!"

# -----------------------------
# 3) Download database if not present
cd $DB_DIR
if [ ! -f "$DB_ARCHIVE" ]; then
    echo "Downloading MetaPhlAn database..."
    wget https://data.biobakery.org/metaphlan_databases/$DB_ARCHIVE
else
    echo "Database archive already exists: $DB_ARCHIVE"
fi

# -----------------------------
# 4) Extract database
if [ ! -d "$DB_DIR/mpa_v30" ]; then
    echo "Extracting database..."
    tar -xvf $DB_ARCHIVE
    mv mpa_v30_CHOCOPhlAnSGB_202503 mpa_v30
else
    echo "Database folder already exists: mpa_v30"
fi

# -----------------------------
# 5) Verify contents
echo "Database contents:"
ls -lh $DB_DIR/mpa_v30

echo "MetaPhlAn setup complete!"
echo "Use $DB_DIR/mpa_v30 as the database path in databases.csv"