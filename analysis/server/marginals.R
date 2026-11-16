# =========================================================================
# Marginal means and effects of the LNR, from its posterior
# =========================================================================
# The model is Group (treatment-coded, Never = reference) x a strength x
# difficulty surface per illusion. Rather than reading coefficients, every
# quantity is computed per posterior draw on a grid of conditions, at the
# population level (re_formula = NA), and then summarised or contrasted.
#
#   source("models.R"); source("marginals.R")
#   m    <- readRDS("../models/lnr.rds")
#   grid <- igsa_grid(m)
#   d    <- igsa_draws(m, grid)              # draws x conditions, per quantity
#   igsa_summary(d, grid)                    # means per Group x illusion x condition
#   igsa_summary(igsa_slopes(d, grid), ...)  # illusion sensitivity per group
#   igsa_summary(igsa_contrasts(...))        # Past - Never, Recent - Never, Recent - Past
#
#   design <- igsa_design_grid(m)            # every strength x difficulty point shown
#   igsa_summary(igsa_contrasts(igsa_average(igsa_draws(m, design), design)))  # averaged over the design
#   g4 <- igsa_grid(m, strength = c(0, 1), difficulty = c(0, 1))
#   igsa_summary(igsa_index(igsa_draws(m, g4), g4))   # illusion magnitude per group
#
# The same per participant: igsa_participant_grid(m) and
# igsa_draws(m, grid, re_formula = NULL). Those estimates are shrunk towards
# their group's mean, since Group is in the model.
#
# For the parameters themselves (not the derived quantities), modelbased gives
# the same averages and slopes from the fit directly, e.g.
#   modelbased::estimate_contrasts(m, contrast = "Group", by = "Illusion_Type",
#                                  newdata = design, predict = "mu", re_formula = NA)
#   modelbased::estimate_slopes(m, trend = "Illusion_Strength", by = c("Group", "Illusion_Type"),
#                               newdata = igsa_grid(m, 0, 0), predict = "ndt", re_formula = NA)
# `predict` names the distributional parameter, `re_formula = NA` keeps it at
# the population level, and `newdata` sets the grid (it averages over the
# grid within `by`). On the same draws the two paths agree to the last digit
# (3_lnr_groups.qmd checks it). modelbased cannot do delta, speed or perror,
# which need several parameters per draw; those stay here.
#
# Quantities (cogmod_lnr: T_k ~ LogNormal(-nu_k, sigma_k), accumulator 0 =
# correct; larger nu = faster):
#   mu, nuone, sigmazero, sigmaone, ndt   the parameters, on their natural scale
#   delta    nu0 - nu1: discriminability, how far ahead the correct
#            accumulator is
#   speed    (nu0 + nu1) / 2: overall speed of both accumulators. The LNR's
#            stand-in for (inverse) caution, since its threshold is fixed at 1
#   perror   P(error) from the race alone, Phi((nu1 - nu0) / sqrt(s0^2 + s1^2));
#            cogmod's posterior_epred() for a race model refuses (it would
#            integrate numerically per draw and observation), and this closed
#            form is exact (the outlier component adds poutlier / 2 on top)
#
# Fits made on the cluster (brms 2.21.0) predict correctly with a newer local
# brms: the mispredictions IllusionGameComputational found came from rebuilt
# t2() smooth bases, and this model has no smooth.

igsa_grid <- function(m, strength = seq(-1, 1, by = 0.25), difficulty = c(-1, 0, 1)) {
  d <- m$data
  grid <- expand.grid(
    Group = levels(d$Group),
    Illusion_Type = levels(d$Illusion_Type),
    Illusion_Strength = strength,
    Task_Difficulty = difficulty,
    stringsAsFactors = FALSE
  )
  grid$Group <- factor(grid$Group, levels = levels(d$Group))
  grid$Illusion_Type <- factor(grid$Illusion_Type, levels = levels(d$Illusion_Type))
  # Not used by the population-level predictions, but brms validates the
  # response and its dec() term on new data.
  grid$RT <- 1
  grid$Error <- 0L
  grid
}

# Every participant, in their own group, on a grid of conditions.
igsa_participant_grid <- function(m, strength = c(0, 1), difficulty = 0) {
  d <- m$data
  conditions <- expand.grid(
    Illusion_Type = levels(d$Illusion_Type),
    Illusion_Strength = strength,
    Task_Difficulty = difficulty,
    stringsAsFactors = FALSE
  )
  grid <- merge(d[!duplicated(d$Participant), c("Participant", "Group")], conditions, by = NULL)
  grid$Illusion_Type <- factor(grid$Illusion_Type, levels = levels(d$Illusion_Type))
  grid$RT <- 1
  grid$Error <- 0L
  grid
}

# Every strength x difficulty point the task showed, per illusion (80 each,
# 222-236 trials apiece in the cleaned data), crossed with Group. Averaging
# over it is averaging over the task as run. Its mean strength is 0 and
# strength is orthogonal to difficulty, so for the identity-link parameters
# the average equals the value at strength 0; its mean difficulty is 0.098,
# a little hard of the midpoint.
igsa_design_grid <- function(m) {
  d <- m$data
  points <- unique(d[c("Illusion_Type", "Illusion_Strength", "Task_Difficulty")])
  grid <- merge(data.frame(Group = factor(levels(d$Group), levels = levels(d$Group))), points, by = NULL)
  grid$Illusion_Type <- factor(grid$Illusion_Type, levels = levels(d$Illusion_Type))
  grid$RT <- 1
  grid$Error <- 0L
  rownames(grid) <- NULL
  grid
}

# `...` goes to posterior_linpred(), e.g. draw_ids.
igsa_draws <- function(m, grid, ndraws = NULL, re_formula = NA, ...) {
  pars <- c("mu", "nuone", "sigmazero", "sigmaone", "ndt", "poutlier")
  out <- lapply(setNames(pars, pars), function(p) {
    brms::posterior_linpred(m, newdata = grid, dpar = p, re_formula = re_formula,
                            transform = TRUE, ndraws = ndraws, ...)
  })
  out$delta <- out$mu - out$nuone
  out$speed <- (out$mu + out$nuone) / 2
  out$perror <- stats::pnorm(-out$delta / sqrt(out$sigmazero^2 + out$sigmaone^2))
  out
}

# Illusion sensitivity: the effect of one unit of strength (half the range,
# from no illusion to the strongest conflicting one), per Group x illusion x
# difficulty, on every quantity. Linear predictors are linear in strength, so
# for the parameters on an identity link (mu, nuone, delta, speed) this is
# exactly the slope; for the others it is the change between strength 0 and 1.
# `var = "Task_Difficulty"` gives the difficulty slope the same way, from mid
# difficulty to the hardest trials, per Group x illusion x strength.
igsa_slopes <- function(draws, grid, from = 0, to = 1, var = "Illusion_Strength") {
  key <- setdiff(names(grid), c(var, "RT", "Error"))
  i0 <- which(grid[[var]] == from)
  i1 <- which(grid[[var]] == to)
  stopifnot(length(i0) > 0, length(i1) > 0)
  i1 <- i1[match(do.call(paste, grid[i0, key, drop = FALSE]), do.call(paste, grid[i1, key, drop = FALSE]))]
  stopifnot(!anyNA(i1))
  out <- lapply(draws, function(x) x[, i1, drop = FALSE] - x[, i0, drop = FALSE])
  attr(out, "grid") <- grid[i0, key, drop = FALSE]
  out
}

# The draws averaged over the grid within cells: per Group x illusion (the
# default) or per Group alone. On igsa_design_grid() this is the group
# difference "averaged over the design".
igsa_average <- function(draws, grid, by = c("Group", "Illusion_Type")) {
  cells <- unique(grid[by])
  rownames(cells) <- NULL
  key <- do.call(paste, grid[by])
  idx <- split(seq_len(nrow(grid)), factor(key, levels = do.call(paste, cells)))
  out <- lapply(draws, function(x) sapply(idx, function(i) rowMeans(x[, i, drop = FALSE])))
  attr(out, "grid") <- cells
  out
}

# Illusion magnitude in stimulus units. At strength 0 and mid difficulty, the
# effect of one unit of strength on discriminability (delta) over the effect
# of one unit of difficulty on it. Both are negative (conflicting illusions
# and harder trials both lower delta), so the ratio is positive: how many
# units of Task_Difficulty one unit of Illusion_Strength costs. That is the
# PSE shift of psychophysics, and anything that scales the whole surface
# (precision, caution, care) cancels out of it. The grid must hold the points
# (0, 0), (1, 0) and (0, 1) for every cell. Per draw:
#   delta_strength     delta(1, 0) - delta(0, 0)   the illusion effect
#   delta_difficulty   delta(0, 1) - delta(0, 0)   the precision term
#   index              their ratio
# The ratio is unstable where delta_difficulty crosses zero: summarise it by
# the median, and check the share of such draws.
igsa_index <- function(draws, grid) {
  key <- intersect(c("Participant", "Group", "Illusion_Type"), names(grid))
  at <- function(s, d) which(grid$Illusion_Strength == s & grid$Task_Difficulty == d)
  k <- function(i) do.call(paste, grid[i, key, drop = FALSE])
  i00 <- at(0, 0)
  i10 <- at(1, 0)[match(k(i00), k(at(1, 0)))]
  i01 <- at(0, 1)[match(k(i00), k(at(0, 1)))]
  stopifnot(length(i00) > 0, !anyNA(i10), !anyNA(i01))
  strength <- draws$delta[, i10, drop = FALSE] - draws$delta[, i00, drop = FALSE]
  difficulty <- draws$delta[, i01, drop = FALSE] - draws$delta[, i00, drop = FALSE]
  out <- list(delta_strength = strength, delta_difficulty = difficulty, index = strength / difficulty)
  attr(out, "grid") <- grid[i00, key, drop = FALSE]
  out
}

# Group differences per draw, for every condition in `grid` (or the grid
# stored by igsa_slopes()).
igsa_contrasts <- function(draws, grid = attr(draws, "grid"),
                           pairs = list(c("Past", "Never"), c("Recent", "Never"),
                                        c("Recent", "Past"))) {
  key <- setdiff(names(grid), c("Group", "RT", "Error"))
  out <- list()
  rows <- list()
  for (p in pairs) {
    ia <- which(grid$Group == p[1])
    ib <- which(grid$Group == p[2])
    if (length(key)) { # a Group-only grid has one row per group
      ib <- ib[match(do.call(paste, grid[ia, key, drop = FALSE]),
                     do.call(paste, grid[ib, key, drop = FALSE]))]
    }
    rows[[length(rows) + 1]] <- cbind(Contrast = paste(p, collapse = " - "),
                                      grid[ia, key, drop = FALSE])
    for (q in names(draws)) {
      out[[q]] <- cbind(out[[q]], draws[[q]][, ia, drop = FALSE] - draws[[q]][, ib, drop = FALSE])
    }
  }
  attr(out, "grid") <- do.call(rbind, rows)
  out
}

# Median, 95% equal-tailed interval and probability of direction, one row
# per condition and quantity.
igsa_summary <- function(draws, grid = attr(draws, "grid"), what = names(draws)) {
  grid <- grid[setdiff(names(grid), c("RT", "Error"))]
  do.call(rbind, lapply(what, function(q) {
    x <- draws[[q]]
    data.frame(
      grid,
      Quantity = q,
      Median = apply(x, 2, stats::median),
      CI_low = apply(x, 2, stats::quantile, probs = 0.025),
      CI_high = apply(x, 2, stats::quantile, probs = 0.975),
      pd = apply(x, 2, function(v) max(mean(v > 0), mean(v < 0))),
      row.names = NULL
    )
  }))
}
