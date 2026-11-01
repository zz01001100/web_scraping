# ------------------------------------------------------------------------------
# AUTHOR:  Leroy Zahno (Source: Data Handling Lecture, Aurélien Sallin)
# DATE:    2026-10-17
# ------------------------------------------------------------------------------

# SETUP -------------------------------------------------------------------

library(rvest)
library(dplyr)
library(stringr)
library(readr)

SOURCE_PATH <- "https://en.wikipedia.org/wiki/Divided_government_in_the_United_States"
OUTPUT_PATH <- "Data/divided_gov.csv"

# DATA --------------------------------------------------------------------

connection <- read_html(SOURCE_PATH)
tables <- html_table(connection)
length(tables)
tab <- tables[[2]]
tab <- tab[-nrow(tab), ]

all_years <- list()
for (i in seq_len(nrow(tab))){
  row <- tab[i,]
  pieces <- unlist(strsplit(row$Year, split = "[\\–\\-]"))
  start <- as.numeric(pieces[1])
  end <- as.numeric(pieces[2])
  
  all_years[[i]] <- data.frame(Year = start:(end-1),
                          President = row$President,
                          Senate = row$Senate,
                          House = row$House)
}

divided_gov <- bind_rows(all_years)

divided_gov$Senate <- str_remove_all(divided_gov$Senate, "\\[[^\\]]*\\]")
divided_gov$House <- str_remove_all(divided_gov$House, "\\[[^\\]]*\\]")

# OUTPUT ------------------------------------------------------------------

write_csv(divided_gov, OUTPUT_PATH)