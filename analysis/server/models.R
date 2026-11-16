# =========================================================================
# Model registry -- the one place a model is defined
# =========================================================================
# Sourced by fit_model.R (which fits one of these per job) and combine_model.R
# (which merges its shards). `./hpc` reads the model *names*
# straight out of this file, so keep the declaration lines in the form
#
#     <name> = list(
#
# at two-space indent, one per model, and use that form for nothing else.
# `./hpc models` prints what it found.
#
# Each entry:
#   formula   a function returning the brms bf(); a function so that sourcing
#             this file costs nothing
#   priors    a function(formula, data) returning a brmsprior
#
# The data are data/data_illusiongame.csv, built by analysis/0_preprocessing.qmd; see
# there for how Illusion_Strength and Task_Difficulty are scaled (both on
# [-1, 1]; + = conflicting, + = hardest).


# Formula -----------------------------------------------------------------
# One log-normal race (cogmod_lnr) for choice and RT together. Accumulator 0
# is the correct response, 1 the error (dec(Error)); larger nu = faster.
#
# Every parameter gets the same fixed part: Group x a strength x difficulty
# surface per illusion. The nesting gives each illusion its own strength and
# difficulty slopes rather than differences from a reference illusion, and
# Group is treatment-coded (Never as reference): the group comparisons are
# recovered as marginal means and effects from the posterior (marginals.R),
# so no contrast coding is needed.
#
# Participants: the two drift rates get the full surface per illusion (12
# random effects each); the sigmas and ndt only an intercept per illusion,
# because a 12-dimensional covariance on every parameter is mostly prior.
# `0 +` in the participant terms only re-expresses the three intercepts:
# one per illusion instead of Ebbinghaus plus two differences. That spans
# the same space, but makes each SD the spread of one illusion (which is
# what IllusionGameComputational estimated, hence the priors below) and the
# correlations the cross-illusion ones (e.g. of the strength slopes: a
# general illusion-sensitivity factor).
#
# sigmabias = 0 is the plain LNR. Omitting it does not error: it silently
# becomes a freely estimated start-point range.

igsa_nest <- "Illusion_Type / (Illusion_Strength * Task_Difficulty)"
igsa_fixed <- paste0("Group * (", igsa_nest, ")")
igsa_re_full <- paste0("(0 + ", igsa_nest, " | Participant)")
igsa_re_light <- "(0 + Illusion_Type | Participant)"

igsa_f <- function(lhs, re) {
  stats::as.formula(paste(lhs, "~", igsa_fixed, "+", re), env = globalenv())
}


# Priors ------------------------------------------------------------------
# cogmod's family-aware defaults, then four edits. Everything that sets the
# reference group's (Never's) surface comes from IllusionGameComputational's
# gam_lnr fits (cogmod 0.3.5, ~2,200 participants per illusion, 2026-11-02);
# everything that carries a group difference stays weak, as the group
# differences are the question. IGC's Ebbinghaus fits all have drifting
# chains (population Rhat 2-6), so only its MullerLyer (ML) and
# VerticalHorizontal (VH) are used.
#
# 1. The Group coefficients: normal(0, 1) on both drift rates. brms leaves
#    `mu`'s flat and cogmod sets `nuone`'s to normal(0, 0.5); the same prior
#    on both accumulators is what cogmod's docs advise. The predictors span
#    [-1, 1], so 1 is a group difference in slope as large as half of IGC's
#    largest slope: weak, but proper. The sigmas' (normal(0, 0.5)) and ndt's
#    (normal(0, 0.2)) are cogmod's, kept.
#
# 2. Never's slopes: each illusion's strength, difficulty and strength x
#    difficulty coefficients, centred on IGC. IGC's surfaces are t2() smooths,
#    so analysis/2_priors.R reads them at this task's 160 strength x
#    difference points and fits this model's linear surface to them (R2
#    0.93-0.98 for the drift rates, 0.6-0.8 for ndt, whose surface is nearly
#    flat). With b that coefficient and tau the parameter's IGC participant SD:
#        normal(b, sqrt((0.4 b)^2 + (tau / 2)^2))
#    0.4 b puts another population's effect at roughly x0.2 to x1.8 of
#    IGC's; tau / 2 is the floor for the effects IGC puts near zero, and
#    absorbs the linear approximation (a bootstrap over the 160 points moves
#    the coefficients by 0.003-0.14). Ebbinghaus: the ML-VH average with
#    twice the SD (the same projection of IGC's unconverged Ebbinghaus
#    medians lands close to it).
#    The illusions' intercept differences (from Ebbinghaus, at strength 0 and
#    mid-difficulty): normal(0, tau). ML and VH are 0.03-0.33 apart.
#
# 3. The intercepts and the participant SDs, from IGC too:
#      - the intercepts. brms states them on centred predictors, so each is
#        the average linear predictor over the data. Centre: IGC's ML and VH
#        surfaces averaged over this task's grid (2_priors.R), which is
#        narrower than IGC's, hence a faster mu than IGC's own intercepts;
#        SD wide enough to cover a different population.
#      - the participant SDs of the per-illusion intercepts, and of poutlier.
#        Centre: IGC's ML and VH; SD 40% of it, so roughly x0.2 to x1.8. The
#        participant SDs of the slopes keep cogmod's defaults: IGC has no
#        participant slopes.
#    IGC posteriors (median; link scale):
#                  Intercept               participant SD
#                  ML     VH     Ebb       ML     VH
#      mu          0.86   0.88   0.66      0.37   0.37
#      nuone      -0.97  -0.96  -1.58      0.62   0.67
#      sigmazero  -0.13  -0.13   0.18      0.25   0.29
#      sigmaone    0.91   0.89   1.05      0.27   0.28
#      ndt        -1.01  -1.09  -0.97      0.14   0.17
#      poutlier   -7.00  -7.53  -6.99      2.09   2.46
#
# 4. lkj(2) on every participant correlation matrix: the 12 x 12 ones of the
#    drift rates have 66 correlations each from ~120 participants.

igsa_igc <- list(
  intercept = c(mu = 0.99, nuone = -1.16, sigmazero = -0.17, sigmaone = 0.90, ndt = -1.07),
  intercept_sd = c(mu = 0.4, nuone = 0.6, sigmazero = 0.4, sigmaone = 0.4, ndt = 0.25),
  participant_sd = c(mu = 0.37, nuone = 0.65, sigmazero = 0.27, sigmaone = 0.28, ndt = 0.16),
  poutlier_sd = 2.2
)

# IGC's surfaces as this model's slopes (analysis/2_priors.R; link scale)
igsa_igc_b <- data.frame(
  dpar = rep(c("mu", "nuone", "sigmazero", "sigmaone", "ndt"), each = 3),
  term = rep(c("Illusion_Strength", "Task_Difficulty", "Illusion_Strength:Task_Difficulty"), 5),
  MullerLyer = c(
    -1.04, -0.58, -0.67, # mu
    2.09, 0.93, 0.71,    # nuone
    0.24, 0.29, 0.27,    # sigmazero
    -0.69, -0.33, -0.11, # sigmaone
    0.00, 0.04, 0.04     # ndt
  ),
  VerticalHorizontal = c(
    -0.79, -0.42, -0.24,
    1.61, 1.09, -0.28,
    0.00, 0.28, 0.06,
    -0.46, -0.45, 0.26,
    -0.03, 0.02, 0.03
  )
)

igsa_priors <- function(f, data) {
  priors <- cogmod::cogmod_priors(f, data)

  igc <- list(
    brms::prior_string("normal(0, 1)", class = "b"),
    brms::prior_string("normal(0, 1)", class = "b", dpar = "nuone")
  )
  tau <- igsa_igc$participant_sd
  for (i in seq_len(nrow(igsa_igc_b))) {
    r <- igsa_igc_b[i, ]
    dpar <- if (r$dpar == "mu") "" else r$dpar
    centre <- c(MullerLyer = r$MullerLyer, VerticalHorizontal = r$VerticalHorizontal)
    centre[["Ebbinghaus"]] <- mean(centre)
    for (illusion in names(centre)) {
      s <- sqrt((0.4 * centre[[illusion]])^2 + (tau[[r$dpar]] / 2)^2)
      if (illusion == "Ebbinghaus") s <- 2 * s
      igc[[length(igc) + 1]] <- brms::prior_string(
        sprintf("normal(%.3g, %.3g)", centre[[illusion]], s),
        class = "b", dpar = dpar, coef = paste0("Illusion_Type", illusion, ":", r$term)
      )
    }
  }
  for (par in names(igsa_igc$intercept)) {
    dpar <- if (par == "mu") "" else par
    igc[[length(igc) + 1]] <- brms::prior_string(
      sprintf("normal(%g, %g)", igsa_igc$intercept[[par]], igsa_igc$intercept_sd[[par]]),
      class = "Intercept", dpar = dpar
    )
    for (illusion in levels(data$Illusion_Type)[-1]) {
      igc[[length(igc) + 1]] <- brms::prior_string(
        sprintf("normal(0, %g)", tau[[par]]),
        class = "b", dpar = dpar, coef = paste0("Illusion_Type", illusion)
      )
    }
    s <- tau[[par]]
    for (illusion in levels(data$Illusion_Type)) {
      igc[[length(igc) + 1]] <- brms::prior_string(
        sprintf("normal(%g, %g)", s, 0.4 * s),
        class = "sd", group = "Participant", dpar = dpar,
        coef = paste0("Illusion_Type", illusion)
      )
    }
  }
  s <- igsa_igc$poutlier_sd
  igc[[length(igc) + 1]] <- brms::prior_string(
    sprintf("normal(%g, %g)", s, 0.4 * s),
    class = "sd", group = "Participant", dpar = "poutlier", coef = "Intercept"
  )
  # cogmod_priors() returns validate_prior()'s table, where a newer brms
  # (2.23) has already turned the default `cor` row into `L`; adding a `cor`
  # row to that is a duplicate. Edit whichever one is there.
  igc[[length(igc) + 1]] <- if ("L" %in% priors$class) {
    brms::prior_string("lkj_corr_cholesky(2)", class = "L")
  } else {
    brms::prior_string("lkj(2)", class = "cor")
  }

  do.call(c, c(list(priors), igc, list(replace = TRUE)))
}


# Registry ----------------------------------------------------------------

igsa_models <- list(

  lnr = list(
    formula = function() {
      brms::bf(
        igsa_f("RT | dec(Error)", igsa_re_full),
        igsa_f("nuone", igsa_re_full),
        igsa_f("sigmazero", igsa_re_light),
        igsa_f("sigmaone", igsa_re_light),
        sigmabias = 0,
        igsa_f("ndt", igsa_re_light),
        poutlier ~ 1 + (1 | Participant),
        family = cogmod::cogmod_lnr()
      )
    },
    priors = igsa_priors
  )

)

igsa_model <- function(name) {
  if (!nzchar(name) || !name %in% names(igsa_models)) {
    stop("unknown model '", name, "'. Known: ", paste(names(igsa_models), collapse = ", "),
         call. = FALSE)
  }
  c(list(name = name), igsa_models[[name]])
}


# Data --------------------------------------------------------------------
# The factor levels fix the meaning of every coefficient (Never and
# Ebbinghaus are the references); marginals.R reads them back from the fit.

igsa_prepare <- function(df) {
  df$Participant <- factor(df$Participant)
  df$Group <- factor(df$Group, levels = c("Never", "Past", "Recent"))
  df$Illusion_Type <- factor(df$Illusion_Type,
                             levels = c("Ebbinghaus", "MullerLyer", "VerticalHorizontal"))
  df
}
