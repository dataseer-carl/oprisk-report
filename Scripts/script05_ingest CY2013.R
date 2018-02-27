# Initialise paths ##################################################
# Copy paste at beginning of every R script
# Edit as appropriate

project.name <- "oprisk-report"

## DataLake

author.name <- "IBM Watson"
data.source <- "Banking Loss Events"

## Path to data://
source.path <- file.path("~/Data/DataLake", author.name, data.source)
source.path <- file.path(source.path, "data")

library(googledrive)
drive_auth()

## Repo

data.path <- file.path("~/Data", project.name)
local.path <- "./Data"

#*******************************************************************#

# View extant data files ####

library(magrittr)

## Data source

(source.files <- source.path %>% drive_ls())

annual.path <- file.path(source.path, "case_Operational Loss Report_annual conso")
(annual.files <- annual.path %>% drive_ls())

get.files <- c("CY2014.xlsx", "CY2013.xlsx")
lapply(
	get.files,
	function(temp.file){
		# temp.file <- get.files[1]
		dataset.file <- annual.path %>% 
			file.path(temp.file) %>% ## Select file for download
			drive_get()
		dataset.id <- as_id(dataset.file) ## Get ID for download
		dataset.path <- file.path(local.path, dataset.file$name) # Assumes nrow = 1
		drive_download(dataset.id, path = dataset.path, overwrite = TRUE) ## Download raw data file
	}
)

## Project data

# (proj.files <- data.path %>% drive_ls())