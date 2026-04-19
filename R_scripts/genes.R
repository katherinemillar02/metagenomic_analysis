#### GENES AND FUNCTIONS #### 

# READING IN: 
raw_tsv_files <- read_lines("mag/results/MEGAHIT-COMEBin-H_13_01.101.tsv")

# Genes and functions table: 
genes <- tibble(line = raw_tsv_files) %>%
  separate(line, into = c("locus", "tftype", "tlength_bp", "tgene" , "tEC_number", "tCOG",  "tproduct"), sep = "\t", fill = "right")

# Number of identified genes:
gene_count <- genes %>%
  count(tproduct, sort = TRUE)
 # overwhelmed by 'hypothetical proteins' 



