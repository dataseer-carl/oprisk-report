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

# CY2013 ####

## Load ####

CY2013.path <- file.path(local.path, "CY2013.xlsx")

library(readxl)

excel_sheets(CY2013.path) # Only 1 sheet: Bankwide
data.df <- read_excel(CY2013.path, sheet = "Bankwide")

# Archive ####

biz.df <- CY2014.df %>% 
	group_by(Business) %>% 
	summarise(
		Freq = n(), # Assumes unique entry per loss event
		`Estimated Gross Loss` = sum(`Estimated Gross Loss`),
		`Recovery Amount` = sum(`Recovery Amount`),
		`Net Loss` = sum(`Net Loss`)
	)
biz.df %<>% mutate(Severity = `Net Loss` / Freq)


risk.df <- CY2014.df %>% 
	group_by(Business, `Risk Category`) %>% 
	summarise(
		Freq = n(), # Assumes unique events
		`Gross Loss` = sum(`Estimated Gross Loss`),
		`Recovery Amount` = sum(`Recovery Amount`),
		`Net Loss` = sum(`Net Loss`)
	) %>% 
	ungroup() %>% 
	mutate(
		`Recovery Rate` = `Recovery Amount` / `Gross Loss`,
		Severity = `Net Loss` / Freq
	)

rawDaily.df <- CY2014.df %>% 
	group_by(`Occurrence Start Date`) %>% 
	summarise(
		`Net Loss` = sum(`Net Loss`)
	)