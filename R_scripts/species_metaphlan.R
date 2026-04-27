# Load libraries
source("R_scripts/packages.R")


# ------------------------------
# 1. Read MetaPhlAn files
# ------------------------------
meta_H  <- fread("results/H_13_01_nohost_H_13_01_nohost_mpa_v30.metaphlan_profile.txt")
meta_NH <- fread("results/NH_12_01_nohost_NH_12_01_nohost_mpa_v30.metaphlan_profile.txt")

# ------------------------------
# 2. Clean and tidy each sample
# ------------------------------
process_metaphlan <- function(df, sample_name) {
  df %>%
    transmute(
      sample = sample_name,
      taxon = `#clade_name`,
      abundance = relative_abundance
    ) %>%
    filter(str_detect(taxon, "s__")) %>%                         # keep species only
    mutate(species = str_extract(taxon, "s__[^|]+") %>% str_remove("s__")) %>%
    distinct(sample, species, .keep_all = TRUE) %>%             # remove SGB/strain duplicates
    select(sample, species, abundance) %>%
    arrange(desc(abundance))
}

meta_H_species  <- process_metaphlan(meta_H,  "H")
meta_NH_species <- process_metaphlan(meta_NH, "NH")

# ------------------------------
# 3. Combine samples
# ------------------------------
meta_all <- bind_rows(meta_H_species, meta_NH_species)

# ------------------------------
# 4. Select top species across all samples
# ------------------------------
top_species <- meta_all %>%
  group_by(species) %>%
  summarise(total_abundance = sum(abundance), .groups = "drop") %>%
  slice_max(total_abundance, n = 10) %>%
  pull(species)

# ------------------------------
# 5. Prepare data for stacked bar plot
# ------------------------------
plot_df <- meta_all %>%
  mutate(species_plot = if_else(species %in% top_species, species, "Other")) %>%
  group_by(sample, species_plot) %>%
  summarise(abundance = sum(abundance), .groups = "drop")

# ------------------------------
# 6. Stacked bar plot
# ------------------------------

# Choose a palette with enough colors
n_colors <- length(unique(plot_df$species_plot))
colors <- brewer.pal(min(n_colors, 12), "Set3")  # max 12 colors in Set3

# Plot
ggplot(plot_df, aes(x = sample, y = abundance, fill = species_plot)) +
  geom_col() +
  labs(
    x = "Sample",
    y = "Relative abundance (%)",
    fill = "Species"
  ) +
  scale_fill_manual(values = colors) +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 12))



abund_vec <- meta_H_species$abundance

shannon <- diversity(abund_vec, index = "shannon")
shannon
#Result: 1.2; quite low diversity 
  #measures species richness and species evenness, more sensitive to the presence of rare species. 

simpson_index <- diversity(abund_vec, index = "simpson")
simpson_index
#Result: 0.7;
  #More sensitive to the dominance of few species? 

