# Load libraries
source("R_scripts/packages.R")

## DATA WRANGLING ====
# Read MetaPhlAn files
meta_H  <- fread("results/H_13_01_nohost_H_13_01_nohost_mpa_v30.metaphlan_profile.txt")
meta_NH <- fread("results/NH_12_01_nohost_NH_12_01_nohost_mpa_v30.metaphlan_profile.txt")

# --- SPECIES-LEVEL FUNCTION (unchanged) ---
process_metaphlan <- function(df, sample_name) {
  df %>%
    transmute(
      sample = sample_name,
      taxon = `#clade_name`,
      abundance = relative_abundance
    ) %>%
    filter(str_detect(taxon, "s__")) %>%
    mutate(species = str_extract(taxon, "s__[^|]+") %>% str_remove("s__")) %>%
    distinct(sample, species, .keep_all = TRUE) %>%
    select(sample, species, abundance) %>%
    arrange(desc(abundance))
}

# --- GENUS-LEVEL FUNCTION (new) ---
process_metaphlan_genus <- function(df, sample_name) {
  df %>%
    transmute(
      sample = sample_name,
      taxon = `#clade_name`,
      abundance = relative_abundance
    ) %>%
    filter(str_detect(taxon, "g__")) %>%          # keep genus and below
    filter(!str_detect(taxon, "s__")) %>%          # exclude species rows (keep genus-level only)
    mutate(genus = str_extract(taxon, "g__[^|]+") %>% str_remove("g__")) %>%
    distinct(sample, genus, .keep_all = TRUE) %>%
    select(sample, genus, abundance) %>%
    arrange(desc(abundance))
}

## SPECIES-LEVEL DATAFRAMES (unchanged) ====
meta_H_species  <- process_metaphlan(meta_H,  "H")
meta_NH_species <- process_metaphlan(meta_NH, "NH")
meta_all        <- bind_rows(meta_H_species, meta_NH_species)

## GENUS-LEVEL DATAFRAMES (new) ====
meta_H_genus  <- process_metaphlan_genus(meta_H,  "H")
meta_NH_genus <- process_metaphlan_genus(meta_NH, "NH")
meta_all_genus <- bind_rows(meta_H_genus, meta_NH_genus)

## DATA VISUALISATION ====

# --- Species-level plot (unchanged) ---
plot_df <- meta_all %>%
  group_by(sample, species) %>%
  summarise(abundance = sum(abundance), .groups = "drop")

n_colors <- length(unique(plot_df$species))
colors   <- brewer.pal(min(n_colors, 12), "Set3")

metaphlan_plot <- ggplot(plot_df, aes(x = sample, y = abundance, fill = species)) +
  geom_col() +
  labs(x = "Sample", y = "Relative abundance (%)", fill = "Species") +
  scale_fill_manual(values = colors) +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 12))

ggsave("metaphlan_plot_species.tiff", plot = metaphlan_plot, width = 6, height = 4, dpi = 300)

# --- Genus-level plot (new) ---
plot_df_genus <- meta_all_genus %>%
  group_by(sample, genus) %>%
  summarise(abundance = sum(abundance), .groups = "drop")

n_colors_genus <- length(unique(plot_df_genus$genus))
colors_genus   <- brewer.pal(min(n_colors_genus, 12), "Set3")

metaphlan_plot_genus <- ggplot(plot_df_genus, aes(x = sample, y = abundance, fill = genus)) +
  geom_col() +
  labs(x = "Sample", y = "Relative abundance (%)", fill = "Genus") +
  scale_fill_manual(values = colors_genus) +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 12))

ggsave("metaphlan_plot_genus.tiff", plot = metaphlan_plot_genus, width = 10, height = 3, dpi = 300)

## ALPHA DIVERSITY ====

# --- Species-level (unchanged) ---
abund_vec <- meta_H_species$abundance

shannon <- diversity(abund_vec, index = "shannon")
shannon
# Result: 1.2; quite low diversity
#   measures species richness and evenness
#   sensitive to rare AND common species

simpson_index <- diversity(abund_vec, index = "simpson")
simpson_index
# Result: 0.7; fairly high diversity
#   range 0-1; more sensitive to dominant species

# --- Genus-level (new) ---
abund_vec_genus <- meta_H_genus$abundance

shannon_genus <- diversity(abund_vec_genus, index = "shannon")
shannon_genus
# Genus-level Shannon: typically higher than species-level
#   (fewer groups = more even distribution)

simpson_genus <- diversity(abund_vec_genus, index = "simpson")
simpson_genus
# Genus-level Simpson: compare to species-level result
#   higher values here suggest diversity is concentrated in fewer genera