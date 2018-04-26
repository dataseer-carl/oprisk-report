library(ggplot2)
library(readxl)
library(lubridate)

# Initialise paths here *******************#

dump.path <- file.path(".", "Data")
local.path <- file.path(dump.path, "raw")

#****************************************#

cache.file <- "data00_CY2013 raw.rds"
cache.path <- file.path(dump.path, cache.file)
events.df <- readRDS(cache.path)

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

ggplot(biz.df) +
	geom_point(
		aes(x = Freq, y = Severity, colour = Business)
	) +
	labs(title = "Table 1", subtitle = "Subtitle", x = "Frequency", y = "Severity") +
	scale_y_continuous(labels = comma) +
	theme(
		panel.background = element_blank(),
		axis.line = element_line( color = "black" )
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

ggplot(risk.df) +
	geom_point(
		aes(y = `Risk Category`, x = Business, size = Freq)
	) +
	scale_x_discrete(position = "top") +
	theme(
		panel.background = element_rect(color = "NA", fill = "NA")
	)
