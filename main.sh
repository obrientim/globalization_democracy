#!/bin/bash
# Run from the repository root: bash main.sh

set -e
mkdir -p exhibits/tables exhibits/figures

# CLEANING ===========================
Rscript src/data_cleaning/01-data_cleaning.r

# DESCRIPTIVES ===========================
Rscript src/descriptives/fig_democracy_trends.r
Rscript src/descriptives/tab_variable_descriptions.r
Rscript src/descriptives/tab_summary_stats.r

# ESTIMATION ===========================
Rscript src/estimation/fig_coefs_freefair.r
Rscript src/estimation/fig_coefs_equallaw.r
Rscript src/estimation/tab_main_results.r
Rscript src/estimation/tab_no_econ_controls.r
Rscript src/estimation/tab_population_controls.r
Rscript src/estimation/tab_outliers.r
Rscript src/estimation/tab_trends_first_diff.r

# POST-ESTIMATION ===========================
Rscript src/post-estimation/fig_sim_trade.r
Rscript src/post-estimation/fig_sim_fdi_outflows.r
