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

ggplot(risk.df) +
	geom_point(
		aes(x = `Risk Category`, y = Business, size = `Net Loss`)
	)
