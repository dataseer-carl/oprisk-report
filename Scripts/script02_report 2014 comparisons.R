cache.path <- file.path(".", "Data")
stage.path <- file.path("~/Data", "oprisk-report")
source("./Scripts/template.R")

library(magrittr)

# Raw
CY2014.df <- file.path(cache.path, "CY2014.rds") %>% readRDS()

# Summary per biz ####
biz.path <- file.path(cache.path, "out00_total-netloss-per-biz-2014")
biz.df <- readRDS(paste0(biz.path, ".rds"))

library(dplyr)
library(ggplot2)
library(scales)
library(tidyr)
library(ggrepel)

## Order pie sections
biz.names <- biz.df$Business[order(biz.df$`Net Loss`)] %>% as.character()
biz.df$Business %<>% factor(levels = rev(biz.names))
## dataseer palette
biz.cols <- dataseer.cols[1:length(biz.names)]
names(biz.cols) <- rev(biz.names)

## _Bar 1 ####

biz.df %<>% mutate(Severity = `Net Loss` / Freq)

bizLab.df <- biz.df %>% 
	mutate(
		loss.label = comma(`Net Loss`),
		loss.vjust = `Net Loss` > 1e6
	)

ggplot(bizLab.df) +
	geom_bar(
		aes(x = Business, y = `Net Loss`, fill = Business),
		stat = "identity"
	) +
	geom_text(
		aes(x = Business, y = `Net Loss`, label = loss.label, vjust = loss.vjust)
	) +
	scale_y_continuous(name = NULL, expand = c(0, 0)) +
	scale_x_discrete(name = NULL) +
	scale_fill_manual(values = biz.cols, guide = FALSE) +
	theme(
		plot.background = element_blank(),
		panel.background = element_blank(),
		# axis.text = element_blank(),
		# axis.ticks = element_blank(),
		axis.line.x = element_line(colour = "black"),
		axis.line.y = element_blank(),
		axis.text.y = element_blank(),
		axis.ticks = element_blank()
	)
ggsave("./Plots/plot05_compare_loss_bar.png")

### __Bar 1 segmented ####

biz2.ls <- lapply(
	unique(biz.df$Business), # unique Business --- no dups
	function(temp.biz){
		temp.df <- biz.df %>% filter(Business == temp.biz)
			# Supposedly contains only 1 row
		blocks <- rep(temp.df$Severity, temp.df$Freq)
		out.df <- tibble(Business = temp.biz, Avg.Event = blocks, block.id = 1:length(blocks))
		return(out.df)
	}
)
blocks.df <- do.call(bind_rows, biz2.ls)

ggplot(blocks.df) +
	geom_bar(
		aes(x = Business, y = Avg.Event, fill = Business),
		colour = "white",
		stat = "identity", positio = "stack"
	) +
	scale_y_continuous(name = NULL, expand = c(0, 0)) +
	scale_x_discrete(name = NULL) +
	scale_fill_manual(values = biz.cols, guide = FALSE) +
	theme(
		plot.background = element_blank(),
		panel.background = element_blank(),
		# axis.text = element_blank(),
		# axis.ticks = element_blank(),
		axis.line.x = element_line(colour = "black"),
		axis.line.y = element_blank(),
		axis.text.y = element_blank(),
		axis.ticks = element_blank()
	)
ggsave("./Plots/plot06_compare_avgloss_stacked.png")

## _Bar 2 ####

bar2.df <- biz.df %>% 
	select(Business, Freq, Severity) %>% 
	gather("measure", "value", -Business) %>% 
	# for labels
	group_by(measure) %>% 
	mutate(
		max.val = max(value),
		textBelow = value > (0.75*max.val),
		value.label = round(value) %>% comma()
	) %>% 
	ungroup()

ggplot(bar2.df) +
	geom_bar(
		aes(x = Business, y = value, fill = Business),
		stat = "identity"
	) +
	facet_wrap(~ measure, scales = "free_y") +
	geom_text(
		aes(x = Business, y = value, label = value.label, vjust = textBelow),
		size = 3
	) +
	scale_y_continuous(name = NULL, expand = c(0, 0)) +
	scale_x_discrete(name = NULL) +
	scale_fill_manual(values = biz.cols, guide = FALSE) +
	theme(
		plot.background = element_blank(),
		panel.background = element_blank(),
		strip.background = element_rect(fill ="#787c84"),
		strip.text = element_text(colour = "white"),
		# axis.text = element_blank(),
		# axis.ticks = element_blank(),
		axis.line.x = element_line(colour = "black"),
		axis.line.y = element_blank(),
		axis.text.y = element_blank(),
		axis.text.x = element_text(angle = 90, hjust = 1),
		axis.ticks = element_blank()
	)
ggsave("./Plots/plot07_compare_FREQvsSEV_bar.png")

## _Scatter ####

amtLab <- function(x){
	temp.amt <- x / 1e3
	temp.lab <- paste0(temp.amt, "k")
	return(temp.lab)
}

ggplot(biz.df) +
	geom_point(
		aes(x = Freq, y = Severity, colour = Business),
		size = 8, alpha = 0.75
	) +
	geom_text_repel(
		aes(x = Freq, y = Severity, label = Business),
		segment.colour = NA
	) +
	scale_colour_manual(values = biz.cols, guide = FALSE) +
	scale_y_continuous(label = amtLab) +
	theme(
		plot.background = element_blank(),
		panel.background = element_blank(),
		strip.background = element_rect(fill ="#787c84"),
		strip.text = element_text(colour = "white"),
		axis.line = element_line(colour = "black")
	)
ggsave("./Plots/plot08_compare_FREQvsSEV_scatter.png")
