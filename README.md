# oprisk-report
From IBM Watson - Banking Loss Events

## Data

### Sources

| Data File/Directory | Description | Location | Columns | Rows | Size |
|:--|:--|:--|--:|--:|--:|
| [`case_Operational Loss Report_annual conso/`](https://drive.google.com/open?id=1pX3H4ta8j00IWDKglebO40QrrSL7ZURk) | Consolidated loss events across regions and business lines per year |`data:///DataLake/IBM Watson/Banking Loss Events/data/`| 12 columns | 135 rows | 12,975 bytes |

`data://` pertains to `~/Data/` in GDrive that is serving as data stage.  Currently it is hosted in Carl Calub's GDrive.

### Loaded

| Dataset | Data File | Description | Columns | Rows | Input Data | Data Processing Scripts |
|:--|:--|:--|--:|--:|:--|:--|
| 2013 Loss Events | `CY2013.rds` | 2013 loss events for all regions and business lines | 12 columns | 391 rows | `CY2013.xlsx` | `script00_ingest CY2014.R` |
| 2014 Loss Events | `CY2014.rds` | 2014 loss events for all regions and business lines | 12 columns | 135 rows | `CY2014.xlsx` | `script00_ingest CY2014.R` |


## Output

### Loss breakdown

#### Data

| Data File | Description | Columns | Rows | Input Data | Data Processing Scripts | csv Data File | xlsx Data File | R Data File |
|:--|:--|--:|--:|:--|:--|:--|:--|:--|
| `out00_total-netloss-per-biz-2014` | 2014 summary per business for all regions and business lines | 5 columns | 7 rows | `CY2014.rds` | `script01_report 2014 breakdown.R` |  | [`out00_total-netloss-per-biz-2014.xlsx`](https://drive.google.com/open?id=1aGvbdf3jHys3x-1sDUwk5ji528-Uf0qP) | [`out00_total-netloss-per-biz-2014.rds`](https://drive.google.com/open?id=18MS20CjPY9NFrNhfXvq-ynCY2flyVirj) |

#### Plots

| Plot | File | Script | Input data |
|:--|:--|:--|:--|
| Breakdown of 2014 Net Loss per Business: pie | `plot00_share_pie.png` | `script01_report 2014 breakdown.R` | `out00_total-netloss-per-biz-2014` |
| Breakdown of 2014 Net Loss per Business: bar | `plot01_share_bar.png` | `script01_report 2014 breakdown.R` | `out00_total-netloss-per-biz-2014` |
| Breakdown of 2014 Net Loss per Business: donut | `plot02_share_donut.png` | `script01_report 2014 breakdown.R` | `out00_total-netloss-per-biz-2014` |
| Breakdown of 2014 Net Loss per Business: waffle | `plot03_share_waffle.png` | `script01_report 2014 breakdown.R` | `out00_total-netloss-per-biz-2014` |
| Breakdown of 2014 Net Loss per Business: treemap | `plot04_share_treemap.png` | `script01_report 2014 breakdown.R` | `out00_total-netloss-per-biz-2014` |

### Loss event profile

#### Data

| Data File | Description | Columns | Rows | Input Data | Data Processing Scripts | csv Data File | xlsx Data File | R Data File |
|:--|:--|--:|--:|:--|:--|:--|:--|:--|
| `out00_total-netloss-per-biz-2014` | 2014 summary per business for all regions and business lines | 5 columns | 7 rows | `CY2014.rds` | `script01_report 2014 breakdown.R` |  | [`out00_total-netloss-per-biz-2014.xlsx`](https://drive.google.com/open?id=1aGvbdf3jHys3x-1sDUwk5ji528-Uf0qP) | [`out00_total-netloss-per-biz-2014.rds`](https://drive.google.com/open?id=18MS20CjPY9NFrNhfXvq-ynCY2flyVirj) |
| `out01_risk-summary-per-biz-2014` | 2014 risk breakdown per business for all regions | 8 columns | 19 rows | `CY2014.rds` | `script03_report 2014 monitor.R` |  | [`out01_risk-summary-per-biz-2014.xlsx`](https://drive.google.com/open?id=195RIBrymtXwGKgxF1OqY3Q0ltTSriDIv) | [`out01_risk-summary-per-biz-2014.rds`](https://drive.google.com/open?id=1WD619FjjxIBORuGddzCHcIltxtEbeoq8)

#### Plots 

##### Multi-metric comparison

| Plot | File | Script | Input data |
|:--|:--|:--|:--|
| Total Net Loss per Business in 2014: bar | `plot05_compare_loss_bar.png` | `script02_report 2014 comparisons.R` | `out00_total-netloss-per-biz-2014` |
| Stacked Average Net Loss of all loss events per Business in 2014: bar | `plot06_compare_avgloss_stacked.png` | `script02_report 2014 comparisons.R` | `out00_total-netloss-per-biz-2014` |
| Loss Event Frequency and Severity per Business in 2014: bar | `plot07_compare_FREQvsSEV_bar.png` | `script02_report 2014 comparisons.R` | `out00_total-netloss-per-biz-2014` |
| Loss Event Frequency and Severity per Business in 2014: scatter | `plot08_compare_FREQvsSEV_scatter.png` | `script02_report 2014 comparisons.R` | `out00_total-netloss-per-biz-2014` |

##### Multi-category comparison

| Plot | File | Script | Input data |
|:--|:--|:--|:--|
| Net Loss per Risk Category for each Business in 2014: bar | `plot09_compare_BIZvsRISK_bar.png` | `script03_report 2014 monitor.R` | `out01_risk-summary-per-biz-2014` |
| Net Loss per Business for each Risk Category in 2014: bar | `plot10_compare_RISKvsBIZ_bar.png` | `script03_report 2014 monitor.R` | `out01_risk-summary-per-biz-2014` |
| Net Loss per Risk Category per Business in 2014: bubble | `plot11_compare_RISKvsBIZ_bubble.png` | `script03_report 2014 monitor.R` | `out01_risk-summary-per-biz-2014` |
| Recovery Rate per Risk Category per Business in 2014: heat | `plot12_compare_RISKvsBIZ_heat.png` | `script03_report 2014 monitor.R` | `out01_risk-summary-per-biz-2014` |

### Loss trends

#### Data

| Data File | Description | Columns | Rows | Input Data | Data Processing Scripts | csv Data File | xlsx Data File | R Data File |
|:--|:--|--:|--:|:--|:--|:--|:--|:--|
| `out02_daily-net-loss-2014` | 2014 daily net loss | 2 columns | 110 rows | `CY2014.rds` | `script04_report 2014 trend.R` |  | [`out02_daily-net-loss-2014.csv`](https://drive.google.com/open?id=1FYaENUD2XO8uG7f4TOUcvKvG2KSBwgmO) |  |

#### Plots

| Plot | File | Script | Input data |
|:--|:--|:--|:--|
| Daily Net Loss in 2014: line | `plot13_trend_netloss_line.png` | `script04_report 2014 trend.R` | `out02_daily-net-loss-2014` |
| Daily Net Loss in 2014: calendar | `plot14_trend_netloss_calendar.png` | `script04_report 2014 trend.R` | `out03_daily-net-loss-2014_calendar` |