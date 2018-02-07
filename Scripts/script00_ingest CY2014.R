dump.path <- "~/Data"

library(googledrive)
library(magrittr)

raw.dir <- "DataLake/IBM Watson/Banking Loss Events/data"
raw.path <- file.path(dump.path, raw.dir)

cache.path <- file.path(".", "Data")

# Show files
drive_ls(raw.path)

# Browse annual files ####
data.dir <- "case_Operational Loss Report_annual conso"
data.path <- raw.path %>% file.path(data.dir)
drive_ls(data.path)

# Select CY2014
data.file <- "CY2014.xlsx"
data.filepath <- file.path(data.path, data.file)
data.id <- data.filepath %>% drive_get() %>% as_id()
local.path <- file.path(cache.path, data.file)
drive_download(data.id, local.path, overwrite = TRUE)

# Parse ####

library(readxl)
library(dplyr)

excel_sheets(local.path) # Only 1 sheet
data.df <- read_excel(
	local.path,
	col_types = c(
		"text", # Region
		"text", # Business
		"text", # Name
		"text", # Status
		"text", # Risk Category
		"text", # Risk Sub-Category
		"date", # Discovery Date
		"date", # Occurrence Start Date
		"numeric", # Estimated Gross Loss
		"numeric", # Recovery Amount
		"numeric", # Net Loss
		"numeric"  # Recovery Rate
	)
)

## Convert date columns to Date form POSIXct
data.df %<>% mutate_at(vars(ends_with("Date")), funs(as.Date))

saveRDS(data.df, file.path(cache.path, "CY2014.rds"))
