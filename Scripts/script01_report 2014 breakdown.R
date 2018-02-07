cache.path <- file.path(".", "Data")
stage.path <- file.path("~/Data", "oprisk-report")
source("./Scripts/template.R")

library(magrittr)

CY2014.df <- file.path(cache.path, "CY2014.rds") %>% readRDS()

library(dplyr)
library(ggplot2)
library(scales)
library(writexl)
library(googledrive)

# 2014 bdown ####

biz.df <- CY2014.df %>% 
	group_by(Business) %>% 
	summarise(
		Freq = n(), # Assumes unique entry per loss event
		`Estimated Gross Loss` = sum(`Estimated Gross Loss`),
		`Recovery Amount` = sum(`Recovery Amount`),
		`Net Loss` = sum(`Net Loss`)
	)

biz.path <- file.path(cache.path, "out00_total-netloss-per-biz-2014")

saveRDS(biz.df, paste0(biz.path, ".rds"))
drive_upload(paste0(biz.path, ".rds"), paste0(stage.path, "/"))

write_xlsx(biz.df, path = paste0(biz.path, ".xlsx"))
drive_upload(paste0(biz.path, ".xlsx"), paste0(stage.path, "/"))

## Order pie sections
biz.names <- biz.df$Business[order(biz.df$`Net Loss`)] %>% as.character()
biz.df$Business %<>% factor(levels = biz.names)
## dataseer palette
biz.cols <- dataseer.cols[1:length(biz.names)]
names(biz.cols) <- rev(biz.names)

## _Pie ####

ggplot(biz.df) +
	geom_bar(
		aes(x = 1, y = `Net Loss`, fill = Business),
		stat = "identity"
	) +
	scale_x_discrete(name = NULL) +
	scale_y_continuous(name = NULL) +
	coord_polar(theta = "y") +
	scale_fill_manual(values = biz.cols) +
	guides(fill = guide_legend(reverse = TRUE)) + # ggplot2.tidyverse.org/reference/guide_legend.html
	theme(
		plot.background = element_blank(),
		panel.background = element_blank(),
		axis.text = element_blank(),
		axis.ticks = element_blank()
	)
ggsave("./Plots/plot00_share_pie.png")

## _Bar ####

ggplot(biz.df) +
	geom_bar(
		aes(x = 1, y = `Net Loss`, fill = Business),
		stat = "identity"
	) +
	scale_x_discrete(name = NULL) +
	scale_y_continuous(name = NULL) +
	scale_fill_manual(values = biz.cols) +
	guides(fill = guide_legend(reverse = FALSE)) +
	theme(
		plot.background = element_blank(),
		panel.background = element_blank(),
		axis.text = element_blank(),
		axis.ticks = element_blank()
	)
ggsave("./Plots/plot01_share_bar.png")

## _Donut ####

ggplot(biz.df) +
	geom_bar(
		aes(x = 1, y = `Net Loss`, fill = Business),
		stat = "identity"
	) +
	scale_x_discrete(name = NULL, expand = c(0.75, 0)) +
	scale_y_continuous(name = NULL) +
	coord_polar(theta = "y") +
	scale_fill_manual(values = biz.cols) +
	guides(fill = guide_legend(reverse = TRUE)) + # ggplot2.tidyverse.org/reference/guide_legend.html
	theme(
		plot.background = element_blank(),
		panel.background = element_blank(),
		axis.text = element_blank(),
		axis.ticks = element_blank()
	)
ggsave("./Plots/plot02_share_donut.png")

## _Waffle ####

library(waffle)

biz.netloss <- biz.df$`Net Loss` %>% prop.table() %>% `*`(300)
names(biz.netloss) <- biz.df$Business

biz.parts <- biz.netloss[match(names(biz.cols), names(biz.netloss))]

waffle(biz.parts, reverse = FALSE, colors = biz.cols) +
	theme(
		legend.position = "top"
	)
ggsave("./Plots/plot03_share_waffle.png")

## _Treemap ####

library(treemapify)
## https://cran.rstudio.com/web/packages/treemapify/vignettes/introduction-to-treemapify.html

ggplot(biz.df) +
	aes(area = `Net Loss`, label = Business, fill = Business) +
	geom_treemap() +
	geom_treemap_text(fontface = "italic") +
	scale_fill_manual(values = biz.cols) +
	guides(fill = guide_legend(reverse = TRUE))
ggsave("./Plots/plot04_share_treemap.png")
