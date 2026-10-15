# Reproduces every table and figure in "Does Economic Globalization Promote Democracy?"
#
#   Rscript run.R           tables and figures, from data/full_panel.csv
#   Rscript run.R --build   also rebuilds data/full_panel.csv from data/raw
#
# Run from the repository root. Outputs go to exhibits/tables and exhibits/figures.

args  <- commandArgs(trailingOnly = TRUE)
BUILD <- "--build" %in% args

if (!file.exists("globalization_democracy.Rproj")) stop("run from the repository root")
dir.create("exhibits/tables",  showWarnings = FALSE, recursive = TRUE)
dir.create("exhibits/figures", showWarnings = FALSE, recursive = TRUE)

RSCRIPT <- file.path(R.home("bin"), "Rscript")
run <- function(f) { cat("==", f, "\n"); stopifnot(system2(RSCRIPT, shQuote(f)) == 0) }

# CLEANING =========================== writes data/full_panel.csv

if (BUILD) run("src/data_cleaning/01-data_cleaning.r")

# DESCRIPTIVES ===========================

run("src/descriptives/fig_democracy_trends.r")       # Figure 2
run("src/descriptives/tab_variable_descriptions.r")  # Table 1
run("src/descriptives/tab_summary_stats.r")          # Table 2

# ESTIMATION ===========================

run("src/estimation/fig_coefs_freefair.r")           # Figure 3A
run("src/estimation/fig_coefs_equallaw.r")           # Figure 3B
run("src/estimation/tab_main_results.r")             # Table 3
run("src/estimation/tab_no_econ_controls.r")         # Table 4
run("src/estimation/tab_population_controls.r")      # Table A1
run("src/estimation/tab_outliers.r")                 # Table A2
run("src/estimation/tab_trends_first_diff.r")        # Table A3

# POST-ESTIMATION ===========================

run("src/post-estimation/fig_sim_trade.r")           # Figure 4
run("src/post-estimation/fig_sim_fdi_outflows.r")    # Figure 5

cat("\nDone. Exhibits are in exhibits/tables and exhibits/figures.\n")
