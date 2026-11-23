# =========================================================================
# Population-level priors from IllusionGameComputational (models.R)
# =========================================================================
# Prints the numbers that analysis/server/models.R hard-codes: igsa_igc and
# igsa_igc_b for the LNR, igsa_igc_ddm5 and igsa_igc_ddm5_b for the DDM-5.
# The cluster never runs this: it only sources models.R. Run from the repo
# root, after 0_preprocessing.qmd:
#
#     Rscript analysis/2_priors.R
#
# Inputs (neither is in git):
#   data/data_illusiongame.csv   for this task's stimulus grid
#   <IGSA_IGC_DIR>/analysis/models/predictions/gam_<family>_<illusion>.rds
#                                IGC's prediction files, by default from the
#                                sibling folder ../IllusionGameComputational
#   <IGSA_IGC_DIR>/analysis/models/priors/gam_<family>_<illusion>.rds
#                                IGC's prior-check files, which hold its
#                                posterior medians (DDM-5 only; the LNR's
#                                participant SDs were typed into models.R)
#
# IGC fits one model per family and illusion: every parameter is a t2() smooth
# of strength x difference, plus a participant intercept. Its prediction files
# hold that smooth at the population level (`heatmaps`: 40 x 40 grid, response
# scale). This script reads the smooth at the 160 strength x difference points
# this task shows per illusion, takes it to the link scale, and fits this
# model's surface to it by least squares:
#
#     link(param) ~ Illusion_Strength * Task_Difficulty     (per illusion)
#
# The coefficients are what this model would estimate in IGC's population: the
# centres of the priors on the reference group's (Never's) slopes. The 160
# points weigh equally here. The fit weights them by how much each trial tells
# it, and that is not the same, but a bootstrap over the points moves the
# coefficients by 0.003-0.14, well inside the prior SDs.
#
# Which illusions: the ones whose IGC fit converged and has a prediction file.
#   LNR    MullerLyer and VerticalHorizontal. Every IGC Ebbinghaus LNR fit has
#          population-level Rhat 2-6 (drifting chains). The same projection of
#          its posterior medians lands close to the other two for the drift
#          rates.
#   DDM-5  MullerLyer and Ebbinghaus (cogmod 0.3.5, cmdstanr, both converged,
#          2026-11-16; IGC's AGENT.md). Its VerticalHorizontal fit was a
#          stanli stand-in with no prediction file here, and is being refitted.
# models.R gives the missing illusion the average of the other two, with twice
# the SD.

igc_dir <- Sys.getenv("IGSA_IGC_DIR", unset = "../IllusionGameComputational")
pred_dir <- file.path(igc_dir, "analysis/models/predictions")
prior_dir <- file.path(igc_dir, "analysis/models/priors")
if (!dir.exists(pred_dir)) stop(pred_dir, " not found: set IGSA_IGC_DIR", call. = FALSE)

df <- read.csv("data/data_illusiongame.csv")
df$Illusion_Difference <- abs(df$Illusion_Difference)

softplus_inv <- function(x) log(expm1(x))
logit <- function(p) log(p / (1 - p))

# Each family: the IGC model name, the illusions to read, and the links of its
# cogmod family (to take the response-scale heatmaps to the link scale).
families <- list(
  lnr = list(
    model = "gam_lnr",
    illusions = c("MullerLyer", "VerticalHorizontal"),
    # cogmod_lnr(): identity for the drift rates, softplus for the sigmas
    link = list(mu = identity, nuone = identity, sigmazero = softplus_inv,
                sigmaone = softplus_inv, ndt = log)
  ),
  ddm5 = list(
    model = "gam_ddm5",
    illusions = c("MullerLyer", "Ebbinghaus"),
    # cogmod_ddm(): identity for the drift, softplus for the boundary and
    # sigmadrift, logit for the bias
    link = list(mu = identity, boundary = softplus_inv, bias = logit,
                ndt = log, sigmadrift = softplus_inv)
  )
)

# IGC's predictor scale (its predictions.R, normalize_units()): strength over
# its largest |strength|, |difference| onto [-1, 1] over its observed range
igc_units <- data.frame(
  Illusion_Type = c("MullerLyer", "VerticalHorizontal", "Ebbinghaus"),
  Strength_Max = c(49, 66.5, 2.03),
  Difference_Min = c(0.04, 0.03, 0.05),
  Difference_Max = c(0.46, 0.30, 0.70)
)

# Bilinear interpolation on the heatmap grid. Points outside it take the edge:
# only MullerLyer's smallest difference (0.045; IGC's grid starts at 0.05).
interpolate <- function(h, x, y) {
  gx <- sort(unique(h$Illusion_StrengthZ))
  gy <- sort(unique(h$Illusion_DifferenceZ))
  z <- matrix(NA_real_, length(gx), length(gy))
  z[cbind(match(h$Illusion_StrengthZ, gx), match(h$Illusion_DifferenceZ, gy))] <- h$Value
  x <- pmin(pmax(x, min(gx)), max(gx))
  y <- pmin(pmax(y, min(gy)), max(gy))
  i <- findInterval(x, gx, all.inside = TRUE)
  j <- findInterval(y, gy, all.inside = TRUE)
  tx <- (x - gx[i]) / (gx[i + 1] - gx[i])
  ty <- (y - gy[j]) / (gy[j + 1] - gy[j])
  (1 - tx) * (1 - ty) * z[cbind(i, j)] + tx * (1 - ty) * z[cbind(i + 1, j)] +
    (1 - tx) * ty * z[cbind(i, j + 1)] + tx * ty * z[cbind(i + 1, j + 1)]
}

project <- function(fam) {
  out <- list()
  for (ill in fam$illusions) {
    u <- igc_units[igc_units$Illusion_Type == ill, ]
    file <- file.path(pred_dir, sprintf("%s_%s_%s.rds", fam$model, tolower(ill), ill))
    heat <- readRDS(file)$heatmaps
    pts <- unique(df[df$Illusion_Type == ill,
                     c("Illusion_Strength_Raw", "Illusion_Difference", "Illusion_Strength", "Task_Difficulty")])
    zs <- pts$Illusion_Strength_Raw / u$Strength_Max
    zd <- 2 * (pts$Illusion_Difference - u$Difference_Min) / (u$Difference_Max - u$Difference_Min) - 1

    for (par in names(fam$link)) {
      h <- heat[heat$Parameter == par, ]
      stopifnot(nrow(h) > 0)
      h$Value <- fam$link[[par]](h$Predicted)
      y <- interpolate(h, zs, zd)
      fit <- lm(y ~ Illusion_Strength * Task_Difficulty, data = cbind(pts, y = y))
      co <- coef(fit)
      out[[length(out) + 1]] <- data.frame(
        dpar = par, Illusion_Type = ill,
        Mean = mean(y), # the linear predictor averaged over this grid
        Strength = co[["Illusion_Strength"]],
        Difficulty = co[["Task_Difficulty"]],
        Interaction = co[["Illusion_Strength:Task_Difficulty"]],
        R2 = summary(fit)$r.squared
      )
    }
  }
  do.call(rbind, out)
}

for (name in names(families)) {
  fam <- families[[name]]
  out <- project(fam)
  cat("=====", name, "=====\n")
  cat("IGC's surfaces on this task's grid (link scale; R2 of the linear surface):\n")
  print(cbind(out[1:2], round(out[-(1:2)], 2)), row.names = FALSE)

  # brms puts the Intercept prior on centred predictors: the linear predictor
  # averaged over the data. With the Group coefficients centred on 0, that is
  # the reference group's average over the grid, the same for all three
  # illusions (the missing one taken as the average of the other two).
  cat("\nIntercept centres (average of the two illusions):\n")
  print(round(tapply(out$Mean, out$dpar, mean)[names(fam$link)], 2))

  # The participant SDs of the intercepts, and of poutlier: IGC's posterior
  # medians, from its prior-check files.
  if (name == "ddm5") {
    sds <- sapply(fam$illusions, function(ill) {
      tab <- readRDS(file.path(prior_dir, sprintf("%s_%s_%s.rds", fam$model, tolower(ill), ill)))$table
      dp <- c(names(fam$link), "poutlier")
      key <- ifelse(dp == "mu", "sd_Participant__Intercept", paste0("sd_Participant__", dp, "_Intercept"))
      setNames(tab$Post_Median[match(key, tab$Parameter)], dp)
    })
    cat("\nIGC's participant SDs (posterior medians; link scale):\n")
    print(round(cbind(sds, Average = rowMeans(sds)), 2))
  }
  cat("\n")
}
