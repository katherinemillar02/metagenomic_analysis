## Download library
library(tidyverse)
library(patchwork)


## READ IN DATA FILES
H_13_01 <- read.table("separate_taxonomic_classification/H_13_01.report_postqc",
                      sep = "\t",
                      header = FALSE,
                      fill = TRUE,
                      stringsAsFactors = FALSE)

NH_12_01 <- read.table("separate_taxonomic_classification/NH_12_01.report_postqc",
                       sep = "\t",
                       header = FALSE,
                       fill = TRUE,
                       stringsAsFactors = FALSE)


# ASSIGN COLUMN NAMES
colnames(NH_12_01) <- c("percent",
                        "reads_clade",
                        "reads_taxon",
                        "rank",
                        "taxid",
                        "name")

colnames(H_13_01) <- c("percent",
                        "reads_clade",
                        "reads_taxon",
                        "rank",
                        "taxid",
                        "name")


# CALCULATE PERCENT OF READS PER TAXON, MUTATE COLUMN FOR THIS 
H_13_01 <- H_13_01 |>
  mutate(percent_taxon = reads_taxon / sum(reads_taxon) * 100)

H_12_01 <- NH_12_01 |>
  mutate(percent_taxon = reads_taxon / sum(reads_taxon) * 100)


# SELECT TOP TAXA BY RANK

## Genus comparison
genus_H <- H_13_01 |>
  filter(rank %in% ("G")) |>
  arrange(desc(percent)) |>
  slice_head(n = 5) 

genus_NH <- NH_12_01 |>
  filter(rank %in% ("G")) |>
  arrange(desc(percent)) |>
  slice_head(n = 5)

## Species comparison
species_H <- H_13_01 |>
  filter(rank %in% ("S")) |>
  arrange(desc(percent)) |>
  slice_head(n = 5)

species_NH <- NH_12_01 |>
  filter(rank %in% ("S")) |>
  arrange(desc(percent)) |>
  slice_head(n = 5)

## Sub species comparison 
subspecies_H <- H_13_01 |>
  filter(rank %in% c("S1", "S2", "S3")) |>
  arrange(desc(percent)) |>
  slice_head(n = 5)

subspecies_NH <- NH_12_01 |>
  filter(rank %in% c("S1", "S2", "S3")) |>
  arrange(desc(percent)) |>
  slice_head(n = 5)


# FUNCTION FOR TAXA COMPARISON PLOTS  
plot_taxa_comparison <- function(sample1, sample2, rank_filter, top_n = 5,
                                 sample_names = c("Sample 1", "Sample 2"),
                                 type = c("taxon", "clade")) {
  type <- match.arg(type)  # ensures type is either "taxon" or "clade"
  
  # Decide which column to use
  value_col <- ifelse(type == "taxon", "reads_taxon", "reads_clade")
  
  # Function to compute percent
  add_percent <- function(df) {
    df |>
      filter(rank %in% rank_filter) |>
      mutate(percent_value = !!sym(value_col) / sum(!!sym(value_col)) * 100) |>
      arrange(desc(percent_value)) |>
      slice_head(n = top_n)
  }
  
  # Process both samples
  sample1_top <- add_percent(sample1) |> mutate(sample = sample_names[1])
  sample2_top <- add_percent(sample2) |> mutate(sample = sample_names[2])
  
  # Combine
  combined <- bind_rows(sample1_top, sample2_top)
  
  # Plot
  ggplot(combined, aes(x = reorder(name, percent_value), y = percent_value, fill = sample)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7) +
    scale_fill_brewer(palette = "Set2", name = "Sample") +
    labs(x = "Taxon",
         y = paste0("Percent of Reads (per ", type, ")"),
         fill = "Sample") +
    theme_classic() +
    theme(axis.text.y = element_text(size = 11))
}

## VISUALISATION - PERCENT READ PER CLADE  

# Genus
genus_clade <- plot_taxa_comparison(H_13_01, NH_12_01, rank_filter = "G", top_n = 5, sample_names = c("H_13", "NH_12"), type = "clade")
# Species
species_clade <- plot_taxa_comparison(H_13_01, NH_12_01, rank_filter = "S", top_n = 5, sample_names = c("H_13", "NH_12"), type = "clade")
# Sub-species
subspecies_clade <- plot_taxa_comparison(H_13_01, NH_12_01,  rank_filter = c("S1", "S2", "S3"), top_n = 5, sample_names = c("H_13", "NH_12"), type = "clade")


## VISUALISATION - PERCENT READ PER TAXON 

# Genus
genus_taxa <- plot_taxa_comparison(H_13_01, NH_12_01, rank_filter = "G", top_n = 5, sample_names = c("H_13", "NH_12"), type = "taxon")
# Species
species_taxa <- plot_taxa_comparison(H_13_01, NH_12_01, rank_filter = "S", top_n = 5, sample_names = c("H_13", "NH_12"), type = "taxon")
# Sub-species
subspecies_taxa <- plot_taxa_comparison(H_13_01, NH_12_01,  rank_filter = c("S1", "S2", "S3"), top_n = 5, sample_names = c("H_13", "NH_12"), type = "taxon")

# Patchworking it 
genus_clade / genus_taxa

species_clade / species_taxa

subspecies_clade / subspecies_taxa

