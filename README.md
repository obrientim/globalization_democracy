# Does Economic Globalization Promote Democracy?

This repository contains the code and data for "Does Economic Globalization Promote Democracy? An Empirical Investigation into the Political Consequences of Economic Integration," my honors BA thesis in political science at the University of Chicago (2025). The paper is forthcoming in the *Berkeley Economic Review* and is available [here](https://obrientim.github.io/papers/economic_globalization_democracy.pdf).

The paper estimates the effects of foreign direct investment, trade openness, and tariffs on three V-Dem measures of democracy: free and fair elections, equality before the law, and equal access to power. The unit of analysis is the country-year. The main specifications are dynamic two-way fixed effects models and the Arellano-Bond GMM estimator, each with one or two lags of democracy.

## Quick start

From the repository root, run

```
Rscript run.R
```

This reproduces every table and figure from `data/full_panel.csv` and writes them to `exhibits/`. To rebuild `full_panel.csv` from the raw data first, run `Rscript run.R --build`. Each script also runs on its own from the repository root, for example after opening `globalization_democracy.Rproj` in RStudio.

## Structure

```
run.R                  runs every script in order
data/
  raw/                 World Bank and V-Dem extracts
  full_panel.csv       cleaned country-year panel
  codebook.md          variables in full_panel.csv
src/
  data_cleaning/       builds full_panel.csv from data/raw
  diagnostics/         variable distributions and panel unit-root tests
  descriptives/        Figure 2 and Tables 1-2
  estimation/          Figure 3 and Tables 3, 4, and A1-A3
  post-estimation/     dynamic simulations in Figures 4-5
exhibits/
  tables/              LaTeX tables
  figures/             PDF figures
```

## Data

### V-Dem

`data/raw/vdem.csv` holds five indices from the Varieties of Democracy (V-Dem) Country-Year dataset, version 15 (https://www.v-dem.net/data/the-v-dem-dataset/).

| Name in paper | V-Dem variable | Index |
|---|---|---|
| Free Fair | `v2xel_frefair` | Clean elections |
| Equal Law | `v2xcl_rol` | Equality before the law and individual liberty |
| Equal Access | `v2xeg_eqaccess` | Equal access |
| | `v2x_polyarchy` | Electoral democracy (Figure 2) |
| | `v2x_libdem` | Liberal democracy (Figure 2) |

### World Bank

`data/raw/wdi.csv` holds country-year series from the World Bank's World Development Indicators (https://databank.worldbank.org/source/world-development-indicators). The World Bank revises these series over time, so a fresh download will differ slightly from this file.

| Variable | WDI code | Series |
|---|---|---|
| `fdi_inflows` | `BX.KLT.DINV.WD.GD.ZS` | Foreign direct investment, net inflows (% of GDP) |
| `fdi_outflows` | `BM.KLT.DINV.WD.GD.ZS` | Foreign direct investment, net outflows (% of GDP) |
| `trade` | `NE.TRD.GNFS.ZS` | Trade (% of GDP) |
| `tariff_rate` | `TM.TAX.MRCH.WM.AR.ZS` | Tariff rate, applied, weighted mean, all products (%) |
| `gdppc` | `NY.GDP.PCAP.PP.KD` | GDP per capita, PPP (constant 2021 international $) |
| `gdp_growth` | `NY.GDP.PCAP.KD.ZG` | GDP per capita growth (annual %) |
| `inflation` | `NY.GDP.DEFL.KD.ZG` | Inflation, GDP deflator (annual %) |
| `pop_size` | `SP.POP.TOTL` | Population, total |
| `pop_growth` | `SP.POP.GROW` | Population growth (annual %) |

### Cleaning

`src/data_cleaning/01-data_cleaning.r` merges the two files, addresses country-coding mismatches, removes excess columns, codes each country's level of development (LDC, developing, or OECD), and creates one-year lags of the explanatory variables. The result is `data/full_panel.csv`, described in `data/codebook.md`.

`src/diagnostics/distributions_unit_roots.r` examines the distribution of each variable to choose transformations and tests for panel unit roots. It prints to the console, writes no exhibits, and is not part of `run.R`.

## Exhibits

Each script writes its output to `exhibits/tables` or `exhibits/figures` under the script's own name. Figures 1 and 6 were made in LaTeX and are not included.

| Exhibit | Script | Contents |
|---|---|---|
| Figure 2 | `src/descriptives/fig_democracy_trends.r` | V-Dem electoral and liberal democracy indices, 2017-2024 |
| Table 1 | `src/descriptives/tab_variable_descriptions.r` | Variable descriptions |
| Table 2 | `src/descriptives/tab_summary_stats.r` | Descriptive statistics |
| Figure 3A | `src/estimation/fig_coefs_freefair.r` | Coefficients from the preferred specification for *Free Fair*, standardized, with 95% confidence intervals |
| Figure 3B | `src/estimation/fig_coefs_equallaw.r` | The same for *Equal Law* |
| Table 3 | `src/estimation/tab_main_results.r` | Main results: 12 models, two-way fixed effects and Arellano-Bond, each with one or two lags of democracy |
| Table 4 | `src/estimation/tab_no_econ_controls.r` | Table 3 without the economic controls |
| Table A1 | `src/estimation/tab_population_controls.r` | Table 3 with controls for log population and population growth |
| Table A2 | `src/estimation/tab_outliers.r` | Excludes outliers with a standardized residual beyond 1.96 or a Cook's distance above 4/N |
| Table A3 | `src/estimation/tab_trends_first_diff.r` | Country-specific linear time trends and first-differenced specifications |
| Figure 4 | `src/post-estimation/fig_sim_trade.r` | Simulated effect of a one-standard-deviation increase in *Trade* on *Free Fair* over 30 years, with 95% intervals from a parametric bootstrap of 1,000 draws |
| Figure 5 | `src/post-estimation/fig_sim_fdi_outflows.r` | The same for *FDI Outflows* on *Equal Law* |

## Requirements

Tested with R 4.5.1.

```r
install.packages(c("tidyverse", "plm", "lmtest", "sandwich", "stargazer",
                   "knitr", "kableExtra", "urca"))
```

`MASS` ships with R. `urca` is used only by the unit-root tests.

## AI use

In October 2026 I used Claude Code to reorganize this repository, update the file paths in each script, and draft this README. It also fixed two bugs that stopped Tables A1 and A2 from running. Table A1 computed one column's standard errors from the wrong model, and Table A2 referred to standard-error objects by old names. The rest of the analysis code was not changed.
