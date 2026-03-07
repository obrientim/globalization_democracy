# SETWD ===========================
rm(list = ls())

# LIBRARIES ===========================
library(tidyverse)
library(lmtest)
library(plm)
library(sandwich)
library(stargazer)

# IMPORT DATA ===========================
full_panel <- read.csv("data/full_panel.csv")

# CLEAN SAMPLE ===========================
temp <- full_panel %>%
  filter(!is.na(lag_fdi_inflows),
         !is.na(lag_fdi_outflows),
         !is.na(lag_trade),
         !is.na(lag_tariff_rate),
         !is.na(lag_gdppc),
         !is.na(lag_gdp_growth),
         !is.na(lag_inflation))

# Filter out countries with fewer than 5 observations so TWFE and Arellano-Bond run without errors, also helps balance
temp <- temp %>%
  group_by(country) %>%
  filter(n() > 4) %>%
  ungroup()

# Create numeric trend variable for country-specific linear time trends
temp$trend <- as.numeric(as.character(temp$year))

# FREEFAIR MODELS ===========================

## TWFE with Country-Specific Trends Free Fair ----

# model 52, TWFE with controls, 2 DV lags, and country-specific trends
# Using lm with explicit country FE, year FE, and country-specific trends because
# plm with twoways absorbs the trend variable (collinear with year FE)
m52 <- lm(freefair ~ lag_fdi_inflows + lag_fdi_outflows +
            lag_trade + lag_tariff_rate + log(lag_gdppc) +
            lag_gdp_growth + lag_inflation + lag_freefair + lag2_freefair +
            as.factor(country) + as.factor(year) + as.factor(country):trend,
          data = temp)

crse52 <- coeftest(m52, vcovCL(m52, cluster = temp$country, type = "HC1"))
crse52
nobs(m52)

# equivalent plm model for Wooldridge test
m52_plm <- plm(freefair ~ lag_fdi_inflows + lag_fdi_outflows +
            lag_trade + lag_tariff_rate + log(lag_gdppc) +
            lag_gdp_growth + lag_inflation + lag_freefair + lag2_freefair +
            as.factor(year) + as.factor(country):trend,
          data = temp,
          index = c("country", "year"),
          model = "within",
          effect = "individual")
wooldridge_m52 <- pwartest(m52_plm)

## FD Free Fair ----

# model 53, FD with controls, 2 DV lags, and year dummies
# First-differencing removes country FE and country-specific linear trends
# plm(model = "fd") does not support effect = "time", so year dummies are included explicitly
m53 <- plm(freefair ~ lag_fdi_inflows + lag_fdi_outflows +
            lag_trade + lag_tariff_rate + log(lag_gdppc) +
            lag_gdp_growth + lag_inflation + lag_freefair + lag2_freefair +
            as.factor(year),
          data = temp,
          index = c("country", "year"),
          model = "fd")

crse53 <- coeftest(m53, vcovHC(m53, type = "HC1", cluster = "group"))
crse53
nobs(m53)

# EQUALLAW MODELS ===========================

## TWFE with Country-Specific Trends Equal Law ----

# model 54, TWFE with controls, 2 DV lags, and country-specific trends
m54 <- lm(equallaw ~ lag_fdi_inflows + lag_fdi_outflows +
            lag_trade + lag_tariff_rate + log(lag_gdppc) +
            lag_gdp_growth + lag_inflation + lag_equallaw + lag2_equallaw +
            as.factor(country) + as.factor(year) + as.factor(country):trend,
          data = temp)

crse54 <- coeftest(m54, vcovCL(m54, cluster = temp$country, type = "HC1"))
crse54
nobs(m54)

m54_plm <- plm(equallaw ~ lag_fdi_inflows + lag_fdi_outflows +
            lag_trade + lag_tariff_rate + log(lag_gdppc) +
            lag_gdp_growth + lag_inflation + lag_equallaw + lag2_equallaw +
            as.factor(year) + as.factor(country):trend,
          data = temp,
          index = c("country", "year"),
          model = "within",
          effect = "individual")
wooldridge_m54 <- pwartest(m54_plm)

## FD Equal Law ----

# model 55, FD with controls, 2 DV lags, and year dummies
m55 <- plm(equallaw ~ lag_fdi_inflows + lag_fdi_outflows +
            lag_trade + lag_tariff_rate + log(lag_gdppc) +
            lag_gdp_growth + lag_inflation + lag_equallaw + lag2_equallaw +
            as.factor(year),
          data = temp,
          index = c("country", "year"),
          model = "fd")

crse55 <- coeftest(m55, vcovHC(m55, type = "HC1", cluster = "group"))
crse55
nobs(m55)

# EQUALACCESS MODELS ===========================

## TWFE with Country-Specific Trends Equal Access ----

# model 56, TWFE with controls, 2 DV lags, and country-specific trends
m56 <- lm(equalaccess ~ lag_fdi_inflows + lag_fdi_outflows +
            lag_trade + lag_tariff_rate + log(lag_gdppc) +
            lag_gdp_growth + lag_inflation + lag_equalaccess + lag2_equalaccess +
            as.factor(country) + as.factor(year) + as.factor(country):trend,
          data = temp)

crse56 <- coeftest(m56, vcovCL(m56, cluster = temp$country, type = "HC1"))
crse56
nobs(m56)

m56_plm <- plm(equalaccess ~ lag_fdi_inflows + lag_fdi_outflows +
            lag_trade + lag_tariff_rate + log(lag_gdppc) +
            lag_gdp_growth + lag_inflation + lag_equalaccess + lag2_equalaccess +
            as.factor(year) + as.factor(country):trend,
          data = temp,
          index = c("country", "year"),
          model = "within",
          effect = "individual")
wooldridge_m56 <- pwartest(m56_plm)

## FD Equal Access ----

# model 57, FD with controls, 2 DV lags, and year dummies
m57 <- plm(equalaccess ~ lag_fdi_inflows + lag_fdi_outflows +
            lag_trade + lag_tariff_rate + log(lag_gdppc) +
            lag_gdp_growth + lag_inflation + lag_equalaccess + lag2_equalaccess +
            as.factor(year),
          data = temp,
          index = c("country", "year"),
          model = "fd")

crse57 <- coeftest(m57, vcovHC(m57, type = "HC1", cluster = "group"))
crse57
nobs(m57)

# Because there are three DVs, I need to extract their coefficients, standard errors, and significance stars separately

extract_stars <- function(coef, p) {
  stars <- ""
  if (p < 0.01) {
    stars <- "$^{***}$" }
  else if (p < 0.05) {
    stars <- "$^{**}$" }
  else if (p < 0.10) {
    stars <- "$^{*}$" }
  return(paste0(round(coef, 2), stars))
}

extract_ses <- function(se) {
  paste0("(", round(se, 2), ")")
}

lag1_coef <- c(
  extract_stars(coef(m52)["lag_freefair"], crse52["lag_freefair", 4]),
  extract_stars(coef(m53)["lag_freefair"], crse53["lag_freefair", 4]),
  extract_stars(coef(m54)["lag_equallaw"], crse54["lag_equallaw", 4]),
  extract_stars(coef(m55)["lag_equallaw"], crse55["lag_equallaw", 4]),
  extract_stars(coef(m56)["lag_equalaccess"], crse56["lag_equalaccess", 4]),
  extract_stars(coef(m57)["lag_equalaccess"], crse57["lag_equalaccess", 4])
)

lag1_se <- c(
  extract_ses(crse52["lag_freefair", 2]),
  extract_ses(crse53["lag_freefair", 2]),
  extract_ses(crse54["lag_equallaw", 2]),
  extract_ses(crse55["lag_equallaw", 2]),
  extract_ses(crse56["lag_equalaccess", 2]),
  extract_ses(crse57["lag_equalaccess", 2])
)

lag2_coef <- c(
  extract_stars(coef(m52)["lag2_freefair"], crse52["lag2_freefair", 4]),
  extract_stars(coef(m53)["lag2_freefair"], crse53["lag2_freefair", 4]),
  extract_stars(coef(m54)["lag2_equallaw"], crse54["lag2_equallaw", 4]),
  extract_stars(coef(m55)["lag2_equallaw"], crse55["lag2_equallaw", 4]),
  extract_stars(coef(m56)["lag2_equalaccess"], crse56["lag2_equalaccess", 4]),
  extract_stars(coef(m57)["lag2_equalaccess"], crse57["lag2_equalaccess", 4])
)

lag2_se <- c(
  extract_ses(crse52["lag2_freefair", 2]),
  extract_ses(crse53["lag2_freefair", 2]),
  extract_ses(crse54["lag2_equallaw", 2]),
  extract_ses(crse55["lag2_equallaw", 2]),
  extract_ses(crse56["lag2_equalaccess", 2]),
  extract_ses(crse57["lag2_equalaccess", 2])
)


table_A3 <- stargazer(m52, m53, m54, m55, m56, m57,
            type = "latex",
            title = "Pooled Analysis of Globalization's Effect on Democracy, Country-Specific Linear Time Trends and First Differences",
            float = TRUE,

            se = list(crse52[,2], crse53[,2], crse54[,2], crse55[,2],
                    crse56[,2], crse57[,2]),

            apply.coef = function(x) x * 100,
            apply.se = function(x) x * 100,

            column.separate = c(2, 2, 2),
            keep = c("lag_fdi_inflows", "lag_fdi_outflows", "lag_trade", "lag_tariff_rate"),
            covariate.labels = c("FDI Inflows", "FDI Outflows", "Trade", "Tariff Rate"),

            dep.var.caption = "Dependent Variable",
            dep.var.labels = c("Free Fair", "Equal Law", "Equal Access"),
            model.names = FALSE,

            add.lines = list(
              c("Lag 1", lag1_coef),
              c("", lag1_se),
              c("Lag 2", lag2_coef),
              c("", lag2_se),
              c("Estimator", "TWFE", "FD", "TWFE", "FD", "TWFE", "FD"),
              c("Country-Specific Trends", "Yes", "No", "Yes", "No", "Yes", "No"),
              c("Wooldridge test p-value", round(wooldridge_m52$p.value, 3),
              "", round(wooldridge_m54$p.value, 3),
              "", round(wooldridge_m56$p.value, 3), ""),
              c("Observations", nobs(m52), nobs(m53), nobs(m54), nobs(m55),
              nobs(m56), nobs(m57))
            ),

            column.sep.width = "2pt",
            digits = 3,
            font.size = "small",
            omit.stat = c("f","ser","aic","ll", "rsq", "adj.rsq", "n"),
            star.cutoffs = c(0.10, 0.05, 0.01),
            star.char = c("*","**","***"),
            notes = "\\parbox{1.0\\linewidth}{\\textit{Notes:} $^{*}p<0.1$; $^{**}
            p<0.05$; $^{***} p<0.01$. Robust standard errors clustered at the
            country level are reported in parentheses below their corresponding
            point estimates. The globalization variable coefficients and their
            standard errors are multiplied by 100 for ease of comparison and
            viewing. The lag coefficients are left at the standard scale for
            display. Odd-numbered columns report results from two-way fixed
            effects models with country-specific linear time trends, estimated
            via OLS with explicit country dummies, year dummies, and
            country-by-trend interactions. Even-numbered columns report
            first-differenced models with year dummies, which eliminate both
            country fixed effects and country-specific linear trends through
            differencing. All models include two lags of the dependent variable,
            economic controls, and year fixed effects.}",
            notes.align = "l",
            notes.label = "",
            notes.append = FALSE
            )

cat(table_A3, file = "tables/table_A3.tex")
