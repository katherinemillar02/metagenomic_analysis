library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(stringr)



#### METAPHLAN ==============================


# List of files and sample names
files <- c(
  "NH_12_01_nohost_NH_12_01_nohost_mpa_v30.metaphlan_profile.txt",
  "H_13_01_nohost_H_13_01_nohost_mpa_v30.metaphlan_profile.txt"
)
samples <- c("NH_12_01", "H_13_01")

# Read and combine all files into a single dataframe
all_species <- purrr::map2_dfr(files, samples, ~{
  read_tsv(.x, comment = "#",
           col_names = c("clade_name", "NCBI_tax_id", "relative_abundance", "additional_species")) %>%
    mutate(sample = .y)
})

# Extract species-level information
species_clean <- all_species %>%
  filter(str_detect(clade_name, "s__") | str_detect(clade_name, "^[A-Z][a-z]+_[a-z]+")) %>%
  mutate(
    species_name = str_extract(clade_name, "(?<=s__)[^|]+"),         # extract if s__ is present
    species_name = ifelse(is.na(species_name),
                          str_extract(clade_name, "^[A-Z][a-z]+_[a-z]+"),
                          species_name)
  ) %>%
  distinct(sample, species_name, .keep_all = TRUE)   # remove duplicates per sample

# Select top 5 species per sample
top_species <- species_clean %>%
  group_by(sample) %>%
  arrange(desc(relative_abundance)) %>%
  slice_head(n = 5) %>%
  ungroup()

# Plot top species for both samples
metaphlan <- ggplot(top_species,
       aes(x = reorder(species_name, relative_abundance), y = relative_abundance, fill = species_name)) +
  geom_bar(stat = "identity") +
  labs(title = "Metaphlan", 
       x = "Species",
       y = "Relative Abundance (%)") +
  facet_wrap(~sample, scales = "free_x") +  # separate bars by sample
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")+
  ylim(0,100)






#### KRAKEN ==============================


# Files and sample names
files <- c("H_13_01_nohost_H_13_01_nohost_standard.kraken2.kraken2.report.txt", "NH_12_01_nohost_NH_12_01_nohost_standard.kraken2.kraken2.report.txt")
samples <- c("H_13_01", "NH_12_01")

# Read and combine Kraken reports
all_species <- map2_dfr(files, samples, ~{
  read_tsv(.x,
           col_names = c("relative_abundance", "count1", "count2", "rank", "tax_id", "clade_name"),
           comment = "#") %>%
    mutate(sample = .y)
})

# Filter species-level entries (rank == "S") and extract species name
species_clean <- all_species %>%
  filter(rank %in% c("S")) %>%  
  mutate(species_name = str_trim(clade_name)) %>% 
  distinct(sample, species_name, .keep_all = TRUE) 

# Select top 5 species per sample
top_species_kraken <- species_clean %>%
  group_by(sample) %>%
  arrange(desc(relative_abundance)) %>%
  slice_head(n = 5) %>%
  ungroup()

# Plot top species for both samples
kraken <- ggplot(top_species_kraken,
       aes(x = reorder(species_name, relative_abundance), y = relative_abundance, fill = species_name)) +
  geom_bar(stat = "identity") +
  labs(title = "Kraken", 
       x = "Species",
       y = "Relative Abundance (%)") +
  facet_wrap(~sample, scales = "free_x") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none") + 
  ylim(0,100)


metaphlan + kraken

