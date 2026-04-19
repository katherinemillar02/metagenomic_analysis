file_path <- "egg-nog/MEGAHIT-MaxBin2-NH_12_01.001_eggnog.emapper.annotations"
eggnog_df <- read_tsv(file_path, col_types = cols())

# Inspect first rows
head(eggnog_df)

# Read the file
eggnog_df <- read_tsv(file_path, comment = "#", col_types = cols())

# Inspect first few rows
head(eggnog_df)

