# =========================================================================
# Population-level priors from IllusionGameComputational (models.R)
# =========================================================================
# Prints the numbers that analysis/server/models.R hard-codes in igsa_igc and
# igsa_igc_b. The cluster never runs this: it only sources models.R. Run from
# the repo root, after 0_preprocessing.qmd:
#
#     Rscript analysis/2_priors.R
#
# Inputs (neither is in git):
#   data/data_illusiongame.csv   for this task's stimulus grid
#   <IGSA_IGC_DIR>/analysis/models/predictions/gam_lnr_<illusion>.rds
#                                IGC's prediction files, by default from the
#                                sibling folder ../IllusionGameComputational
#
# IGC fits one gam_lnr per illusion: every LNR parameter is a t2() smooth of
# strength x difference, plus a participant intercept. Its prediction files
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
# Only MullerLyer and VerticalHorizontal are used: every IGC Ebbinghaus LNR fit
# has population-level Rhat 2-6 (drifting chains). The same projection of its
# posterior medians lands close to the other two for the drift rates.

igc_dir <- Sys.getenv("IGSA_IGC_DIR", unset = "../IllusionGameComputational")
pred_dir <- file.path(igc_dir, "analysis/models/predictions")
if (!dir.exists(pred_dir)) stop(pred_dir, " not found: set IGSA_IGC_DIR", call. = FALSE)

df <- read.csv("data/data_illusiongame.csv")
df$Illusion_Difference <- abs(df$Illusion_Difference)

# Links of cogmod_lnr(): identity for the drift rates, softplus for the sigmas
link <- list(
  mu = identity, nuone = identity,
  sigmazero = function(x) log(expm1(x)), sigmaone = function(x) log(expm1(x)),
  ndt = log
)

# IGC's predictor scale (its predictions.R, normalize_units()): strength over
# its largest |strength|, |difference| onto [-1, 1] over its observed range
igc_units <- data.frame(
  Illusion_Type = c("MullerLyer", "VerticalHorizontal"),
  Strength_Max = c(49, 66.5),
  Difference_Min = c(0.04, 0.03),
  Difference_Max = c(0.46, 0.30)
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

out <- list()
for (k in seq_len(nrow(igc_units))) {
  u <- igc_units[k, ]
  file <- file.path(pred_dir, sprintf("gam_lnr_%s_%s.rds", tolower(u$Illusion_Type), u$Illusion_Type))
  heat <- readRDS(file)$heatmaps
  pts <- unique(df[df$Illusion_Type == u$Illusion_Type,
                   c("Illusion_Strength_Raw", "Illusion_Difference", "Illusion_Strength", "Task_Difficulty")])
  zs <- pts$Illusion_Strength_Raw / u$Strength_Max
  zd <- 2 * (pts$Illusion_Difference - u$Difference_Min) / (u$Difference_Max - u$Difference_Min) - 1

  for (par in names(link)) {
    h <- heat[heat$Parameter == par, ]
    h$Value <- link[[par]](h$Predicted)
    y <- interpolate(h, zs, zd)
    fit <- lm(y ~ Illusion_Strength * Task_Difficulty, data = cbind(pts, y = y))
    co <- coef(fit)
    out[[length(out) + 1]] <- data.frame(
      dpar = par, Illusion_Type = u$Illusion_Type,
      Mean = mean(y), # the linear predictor averaged over this grid
      Strength = co[["Illusion_Strength"]],
      Difficulty = co[["Task_Difficulty"]],
      Interaction = co[["Illusion_Strength:Task_Difficulty"]],
      R2 = summary(fit)$r.squared
    )
  }
}
out <- do.call(rbind, out)

cat("IGC's surfaces on this task's grid (link scale; R2 of the linear surface):\n")
print(cbind(out[1:2], round(out[-(1:2)], 2)), row.names = FALSE)

# brms puts the Intercept prior on centred predictors: the linear predictor
# averaged over the data. With the Group coefficients centred on 0, that is
# the reference group's average over the grid, the same for all three
# illusions (Ebbinghaus taken as the average of the other two).
cat("\nigsa_igc$intercept (average of the two illusions):\n")
print(round(tapply(out$Mean, out$dpar, mean)[names(link)], 2))
