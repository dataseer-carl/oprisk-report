cache.path <- file.path(".", "Data")
stage.path <- file.path("~/Data", "oprisk-report")
source("./Scripts/template.R")

library(magrittr)

# Raw
CY2014.df <- file.path(cache.path, "CY2014.rds") %>% readRDS()

## Needed only for order of business-lines
biz.path <- file.path(cache.path, "out00_total-netloss-per-biz-2014")
biz.df <- readRDS(paste0(biz.path, ".rds"))

# Risk cat per biz ####

library(dplyr)
library(googledrive)
library(writexl)
library(ggplot2)
library(scales)
library(stringr)
library(XLConnect)
library(tidyr)

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

risk.path <- file.path(cache.path, "out01_risk-summary-per-biz-2014")
risk.rds <- paste0(risk.path, ".rds")
risk.xlsx <- paste0(risk.path, ".xlsx")

saveRDS(risk.df, risk.rds)
drive_upload(risk.rds, paste0(stage.path, "/"))

write_xlsx(risk.df, path = risk.xlsx)
# add wide format
wide.xl <- loadWorkbook(risk.xlsx)
risk.wide <- risk.df %>% 
	select(Business, `Risk Category`, `Net Loss`) %>% 
	spread("Risk Category", "Net Loss", fill = 0)
renameSheet(wide.xl, "Sheet1", "Long") # writexl cannot specify sheet names
createSheet(wide.xl, "Wide")
writeWorksheet(wide.xl, risk.wide, "Wide")
saveWorkbook(wide.xl); rm(wide.xl)
drive_upload(risk.xlsx, paste0(stage.path, "/"))

## _Bar ####

amtLab <- function(x){
	# See script02_report 2014 comparisons.R
	temp.amt <- x / 1e6
	temp.lab <- paste0(temp.amt, "m")
	return(temp.lab)
}

## Order bars
biz.names <- biz.df$Business[order(biz.df$`Net Loss`)] %>% as.character()
risk.df$Business %<>% factor(levels = rev(biz.names))
## dataseer palette
biz.cols <- dataseer.cols[1:length(biz.names)]
names(biz.cols) <- rev(biz.names)

## Order risk
riskSum.df <- risk.df %>% 
	group_by(`Risk Category`) %>% 
	summarise(`Net Loss` = sum(`Net Loss`))
risk.names <- riskSum.df$`Risk Category`[order(riskSum.df$`Net Loss`)]
risk.df$`Risk Category` %<>% factor(levels = risk.names)
## dataseer palette
risk.cols <- rev(dataseer.cols[-length(dataseer.cols)])[1:length(unique(risk.df$`Risk Category`))]
names(risk.cols) <- rev(risk.names)

ggplot(risk.df) +
	geom_bar(
		aes(x = Business, y = `Net Loss`, fill = `Risk Category`),
		stat = "identity"
	) +
	# scale_x_discrete(name = NULL) +
	scale_y_continuous(labels = amtLab, expand = c(0, 0)) +
	scale_fill_manual(values = risk.cols) +
	# guides(fill = guide_legend(reverse = FALSE)) +
	theme(
		plot.background = element_blank(),
		panel.background = element_blank(),
		axis.line = element_line(colour = "black"),
		axis.text.x = element_text(angle = 90, hjust = 1)
	)
ggsave("./Plots/plot09_compare_BIZvsRISK_bar.png")

ggplot(risk.df) +
	geom_bar(
		aes(x = `Risk Category`, y = `Net Loss`, fill = Business),
		stat = "identity"
	) +
	# scale_x_discrete(name = NULL) +
	scale_y_continuous(labels = amtLab, expand = c(0, 0)) +
	scale_fill_manual(values = biz.cols) +
	coord_flip() +
	theme(
		plot.background = element_blank(),
		panel.background = element_blank(),
		axis.line = element_line(colour = "black")
	)
ggsave("./Plots/plot10_compare_RISKvsBIZ_bar.png")

## _Bubble grid ####

lineBreak <- function(x) str_replace_all(x, c("and " = "and\n"))
spaceBreak <- function(x) str_replace_all(x, c(" " = "\n"))

ggplot(risk.df) +
	geom_point(
		aes(y = `Risk Category`, x = Business, size = `Net Loss`),
		colour = dataseer.cols[2]
	) +
	scale_size_continuous(
		labels = amtLab, 
		range = c(
			1,
			1 * sqrt(max(risk.df$`Net Loss`) / min(risk.df$`Net Loss`))
		)
	) +
	scale_y_discrete(labels = lineBreak) +
	scale_x_discrete(position = "top", labels = spaceBreak) +
	guides(size = guide_legend(label.position = "left")) +
	theme(
		plot.background = element_blank(),
		panel.background = element_rect(colour = "black", fill = NA),
		panel.grid.major = element_line(colour = "#c5e3fb"),
		axis.line = element_line(colour = "black"),
		axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = 0.5),
		axis.ticks = element_blank(),
		legend.key = element_blank()
	)
ggsave("./Plots/plot11_compare_RISKvsBIZ_bubble.png")

## _Heatmap ####

ggplot(risk.df) +
	geom_tile(
		aes(y = `Risk Category`, x = Business, fill = `Recovery Rate`)
	) +
	scale_y_discrete(labels = lineBreak) +
	scale_x_discrete(position = "top", labels = spaceBreak) +
	scale_fill_continuous(
		low = "#787c84", high = "#82f376",
		limits = c(0.10, 0.40),
		labels = percent
	) +
	guides(fill = guide_legend(label.position = "left", label.hjust = 1, reverse = TRUE)) +
	theme(
		plot.background = element_blank(),
		panel.background = element_rect(colour = NA, fill = "#787c84"),
		panel.grid.major = element_blank(),
		axis.line = element_line(colour = "black"),
		axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = 0.5),
		axis.ticks = element_blank(),
		legend.key = element_blank()
	)
ggsave("./Plots/plot12_compare_RISKvsBIZ_heat.png")
