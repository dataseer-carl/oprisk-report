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

CY.path <- file.path(local.path, "CY2013.xlsx")

library(readxl)

excel_sheets(CY.path) # Only 1 sheet: Bankwide
events.df <- read_excel(CY.path, sheet = "Bankwide")

library(dplyr)

biz.df <- events.df %>% 
	group_by(Business) %>% 
	summarise(
		Estimated.Gross.Loss = sum(`Estimated Gross Loss`),
		Recovery.Amount = sum(`Recovery Amount`),
		Net.Loss = sum(`Net Loss`),
		Freq = n()
	) %>% 
	mutate(
		Recovery.Rate = Recovery.Amount / Estimated.Gross.Loss,
		Severity = Net.Loss / Freq
	)

risk.df <- events.df %>% 
	group_by(Business, `Risk Category`) %>% 
	summarise(
		Estimated.Gross.Loss = sum(`Estimated Gross Loss`),
		Recovery.Amount = sum(`Recovery Amount`),
		Net.Loss = sum(`Net Loss`),
		Freq = n()
	) %>% 
	ungroup() %>% 
	mutate(
		Recovery.Rate = Recovery.Amount / Estimated.Gross.Loss,
		Severity = Net.Loss / Freq
	)
	
library(tidyr)

risk.report.netloss <- risk.df %>% 
	select(Business, `Risk Category`, Net.Loss) %>% 
	spread(`Risk Category`, Net.Loss, fill = 0)

risk.report.freq <- risk.df %>% 
	select(Business, `Risk Category`, Freq) %>% 
	spread(`Risk Category`, Freq, fill = 0)

risk.report.sev <- risk.df %>% 
	select(Business, `Risk Category`, Severity) %>% 
	spread(`Risk Category`, Severity, fill = 0)

library(XLConnect)

risk.file <- file.path(local.path, "oprisk measures 2013.xlsx")
risk.xl <- loadWorkbook(risk.file, create = TRUE)
createSheet(risk.xl, "Net Loss")
writeWorksheet(risk.xl, risk.report.netloss, "Net Loss")
createSheet(risk.xl, "Event Frequency")
writeWorksheet(risk.xl, risk.report.freq, "Event Frequency")
createSheet(risk.xl, "Event Severity")
writeWorksheet(risk.xl, risk.report.sev, "Event Severity")
saveWorkbook(risk.xl)

drive_upload(risk.file, paste0(data.path, "/"))