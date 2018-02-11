cache.path <- file.path(".", "Data")
stage.path <- file.path("~/Data", "oprisk-report")
source("./Scripts/template.R")

library(magrittr)

# Raw
CY2014.df <- file.path(cache.path, "CY2014.rds") %>% readRDS()

# Daily trend ####

library(dplyr)
library(ggplot2)
library(scales)
library(lubridate)
library(googledrive)
library(tidyr)

rawDaily.df <- CY2014.df %>% 
	group_by(`Occurrence Start Date`) %>% 
	summarise(
		`Net Loss` = sum(`Net Loss`)
	)
daily.path <- file.path(cache.path, "out02_daily-net-loss-2014")
daily.csv <- paste0(daily.path, ".csv")
write.csv(rawDaily.df, daily.csv, row.names = FALSE)
drive_upload(daily.csv, paste0(stage.path, "/"))

amtLab <- function(x){
	# See script02_report 2014 comparisons.R
	temp.amt <- x / 1e3
	temp.lab <- paste0(temp.amt, "k")
	return(temp.lab)
}

## _Line ####

ggplot(rawDaily.df) +
	geom_line(
		aes(x = `Occurrence Start Date`, y = `Net Loss`),
		colour = dataseer.cols[1], size = 1
	) +
	scale_y_continuous(labels = amtLab, expand = c(0, 0)) +
	theme(
		plot.background = element_blank(),
		panel.background = element_blank(),
		panel.grid.major.y = element_line(colour = "#787c8455"),
		axis.line.y = element_blank(),
		axis.line.x = element_line(colour = "black"),
		panel.grid.major.x = element_blank()
	)
ggsave("./Plots/plot13_trend_netloss_line.png")


## _Calendar ####

daily.df <- rawDaily.df %>% 
	mutate(
		Month = month(`Occurrence Start Date`) %>% factor(levels = 1:12, labels = month.name),
		Week = week(`Occurrence Start Date`),
		WDay = wday(`Occurrence Start Date`, label = TRUE, abbr = TRUE),
		Day = mday(`Occurrence Start Date`)
	)

daily.df <- seq.Date(
	year(rawDaily.df$`Occurrence Start Date`) %>% min() %>% paste0("-01-01") %>% as.Date(),
	year(rawDaily.df$`Occurrence Start Date`) %>% max() %>% paste0("-12-31") %>% as.Date(),
	by = "day"
	) %>% 
	tibble(`Occurrence Start Date` = .) %>% 
	left_join(rawDaily.df) %>% 
	replace_na(list(`Net Loss` = 0)) %>% 
	mutate(
		Month = month(`Occurrence Start Date`) %>% factor(levels = 1:12, labels = month.name),
		WDay = wday(`Occurrence Start Date`, label = TRUE, abbr = TRUE),
		Day = mday(`Occurrence Start Date`),
		YDay = yday(`Occurrence Start Date`),
		start.idx = wday(min(daily.df$`Occurrence Start Date`), label = TRUE) %>% as.integer(),
		# calendar.week.temp = (YDay + start.idx - 2),
		calendar.week = floor((YDay + start.idx - 2) / 7)
	) %>% 
	select(-start.idx)

calendar.path <- file.path(cache.path, "out03_daily-net-loss-2014_calendar")
calendar.csv <- paste0(calendar.path, ".csv")
write.csv(daily.df, calendar.csv, row.names = FALSE)
drive_upload(calendar.csv, paste0(stage.path, "/"))

ggplot(daily.df) +
	geom_tile(
		aes(x = WDay, y = calendar.week, fill = `Net Loss`)
	) +
	geom_text(
		aes(x = WDay, y = calendar.week, label = Day),
		size = 3
	) +
	scale_fill_continuous(low = "white", high = "#ee5f50", labels = amtLab) +
	scale_x_discrete(name = NULL, position = "top") +
	scale_y_continuous(name = NULL, trans = reverse_trans()) +
	facet_wrap(~ Month, scales = "free") +
	# coord_fixed(ratio = 1) +
	theme(
		plot.background = element_blank(),
		panel.background = element_blank(),
		strip.background = element_rect(fill ="#787c84"),
		strip.text = element_text(colour = "white"),
		strip.placement = "outside",
		axis.text.y = element_blank(),
		axis.text.x = element_text(size = 6),
		axis.ticks = element_blank()
	)
ggsave("./Plots/plot14_trend_netloss_calendar.png")
