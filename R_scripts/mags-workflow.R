library(tidyverse)

process_mags_full <- function(stats_file,
                              gtdb_file = NULL,
                              derep_gtdb_file = NULL,
                              qc_completeness = 90,
                              qc_contamination = 10) {
  

  raw_lines <- read_lines(stats_file)
  mags <- tibble(line = raw_lines) %>%
    separate(line, into = c("bin", "info"), sep = "\t", fill = "right") %>%
    mutate(
      completeness = str_extract(info, "(?<=Completeness': )\\d+\\.?\\d*") %>% as.numeric(),
      contamination = str_extract(info, "(?<=Contamination': )\\d+\\.?\\d*") %>% as.numeric())
  
  mags_qc <- mags %>%
    filter(completeness >= qc_completeness, contamination <= qc_contamination)
  
  if (is.null(gtdb_file)) return(list(qc_mags = mags_qc))
  
  gtdb_lines <- read_lines(gtdb_file)
  gtdb <- tibble(line = gtdb_lines) %>%
    separate(
      line,
      into = c(
        "user_genome","classification","closest_genome_reference",
        "closest_genome_reference_radius","closest_genome_taxonomy",
        "closest_genome_ani","closest_genome_af",
        "closest_placement_reference","closest_placement_radius",
        "closest_placement_taxonomy","closest_placement_ani",
        "closest_placement_af","pplacer_taxonomy",
        "classification_method","note",
        "other_related_references(genome_id,species_name,radius,ANI,AF)",
        "msa_percent","translation_table","red_value","warnings"),
      sep = "\t",
      fill = "right")
  
  derep_gtdb <- NULL
  related_species <- NULL
  
  if (!is.null(derep_gtdb_file)) {

    derep_lines <- read_lines(derep_gtdb_file)
    derep_gtdb <- tibble(line = derep_lines) %>%
      separate(line, into = colnames(gtdb), sep = "\t", fill = "right")
    

    related_species <- derep_gtdb %>%
      select(user_genome, `other_related_references(genome_id,species_name,radius,ANI,AF)`) %>%
      mutate(entries = str_split(`other_related_references(genome_id,species_name,radius,ANI,AF)`, ";")) %>%
      unnest(entries) %>%
      filter(!is.na(entries)) %>%
      mutate(
        related_species = str_extract(entries, "(?<=s__)[^,]+"),
        ANI = as.numeric(str_extract(entries, "(?<=,\\s)\\d+\\.\\d+"))
      ) %>%
      select(user_genome, related_species, ANI) %>%
      filter(!is.na(related_species))
  }

  list(qc_mags = mags_qc,
       gtdb_taxonomy = gtdb,
       derep_gtdb_taxonomy = derep_gtdb,
       related_species = related_species)
}

## MetaBat2 Results ============================================================
MetaBAT2 <- process_mags_full(stats_file = "mag/results/bin_stats_ext.tsv")
# ## ## ## ## #
view(MetaBAT2$qc_mags) # Nothing passes quality checking so this ends here. 
#################### ===========================================================





## MaxBin2 Results ============================================================
maxbin2 <- process_mags_full(stats_file = "mag/results/max_bin_stats_ext.tsv",
                            gtdb_file = "mag/results/gtdbtk.bac120.summary2.tsv",
                            derep_gtdb_file = "mag/results/gtdbtk.bac120.summary.tsv")
# ## ## ## ## #
view(maxbin2$qc_mags) #Result: 7 QC MAGs 
view(maxbin2$gtdb_taxonomy)
view(maxbin2$related_species)
view(maxbin2$derep_gtdb_taxonomy)
#################### ===========================================================





## COMEBIN Results  ============================================================
COMEBin <- process_mags_full(stats_file = "mag/results/bin_stats_ext_COMEBin.tsv",
                             gtdb_file = "mag/results/gtdbtk.bac120.summary_comebin.tsv")

# ## ## ## ## #
view(COMEBin$qc_mags) #Result: 1 QC MAG 
view(COMEBin$gtdb_taxonomy) 
view(COMEBin$related_species)
## waiting for dRep to work. 
#################### ===========================================================



## CONCOCT Results =============================================================
CONCOCT <- process_mags_full(stats_file = "mag/results/bin_stats_ext.CONCOCT.tsv",
                             gtdb_file = "mag/results/gtdbtk.bac120.CONCOCT.tsv")
# ## ## ## ## #
view(CONCOCT$qc_mags) #Result: 8 QC MAGs 
view(CONCOCT$gtdb_taxonomy)
view(CONCOCT$related_species)
## waiting for dRep to work. 
#################### ===========================================================


## MetaBinner Results =============================================================
MetaBinner <- process_mags_full(stats_file = "mag/results/bin_stats_ext_MetaBinner.tsv",
                             gtdb_file = "mag/results/gtdbtk.bac120.MetaBinner.tsv")

# ## ## ## ## #
view(MetaBinner$qc_mags) #Result: 3 
view(CONCOCT$gtdb_taxonomy)
view(CONCOCT$related_species)
## waiting for dRep to work. 

