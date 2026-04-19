# Read in packages

packages <- c("tidyverse","data.table","stringr","RColorBrewer","vegan")

# Load all packages
lapply(packages, library, character.only = TRUE)
