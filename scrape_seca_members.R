# ------------------------------------------------------------------------------
# AUTHOR:  Leroy Zahno
# DATE:    2026-10-28
# ------------------------------------------------------------------------------

# SETUP -------------------------------------------------------------------

library(rvest)
library(dplyr)
library(stringr)
library(readr)

SOURCE_PATH <- "https://www.seca.ch/find-members"
OUTPUT_PATH <- "Data/seca_members.csv"

# DATA --------------------------------------------------------------------

start <- Sys.time()

connection <- read_html(SOURCE_PATH)

members <- connection |>
  html_element("div.memberList") |>
  html_elements(".memberSingleBox")

all_members <- list()

for (i in seq_along(members)) {
  
  member <- members[[i]]
  
  name <- html_attr(member, "data-name")
  
  link <- member |>
    html_element("a[href]") |>
    html_attr("href")
  
  if (is.na(link)) next
  
  url <- xml2::url_absolute(link, SOURCE_PATH)
  
  cat("Processing", i, "of", length(members), ":", url, "\n")
  
  profile <- tryCatch(
    read_html(url),
    error = function(e) {
      message("Failed: ", url, " - ", conditionMessage(e))
      return(NULL)
    }
  )
  
  if (is.null(profile)) next
  
  contact <- profile |>
    html_elements(".contact-info.fieldGroupProfile .property-value") |>
    html_text2()
  
  all_members[[i]] <- data.frame(
    Name = name,
    Contact = paste(contact, collapse = " | "),
    URL = url
  )
}

seca_members <- bind_rows(all_members)

# OUTPUT ------------------------------------------------------------------

write_csv(seca_members, OUTPUT_PATH)

cat("Total members:", nrow(seca_members), "\n")
cat("Execution time:", as.character(Sys.time() - start), "\n")