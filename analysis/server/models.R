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
#
# ddm5 is the paper's model since 2026-11-18 (fitted 2026-11-17 as a check on
# the LNR; analysis/5_ddm_vs_lnr.qmd compares the two): IllusionGameComputational's
# DDM-5 (drift, boundary, bias, ndt and the between-trial drift SD sigmadrift;
# sigmabias = sigmandt = 0) on the same design. dec(Error) makes the upper boundary the error, so a negative drift
# favours the correct response, and bias > 0.5 starts closer to the error.
# The drift carries the full participant surface, as the LNR's two rates do;
# the other four get an intercept per illusion.

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
  # SD of the illusions' intercept differences: tau
  illusion_sd = c(mu = 0.37, nuone = 0.65, sigmazero = 0.27, sigmaone = 0.28, ndt = 0.16),
  poutlier_sd = 2.2,
  # The Group coefficients (point 1); the other dpars keep cogmod's
  group_sd = c(mu = 1, nuone = 1)
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

# DDM-5 (ddm5): the same four edits, from IGC's gam_ddm5 fits (cogmod 0.3.5,
# cmdstanr; analysis/2_priors.R reads them). Its MullerLyer and Ebbinghaus
# fits converged (2026-11-16) and are used; its VerticalHorizontal one was a
# stanli stand-in, so VerticalHorizontal takes the ML-Ebbinghaus average
# with twice the SD, as Ebbinghaus does for the LNR.
#   1. The drift's Group coefficients: normal(0, 2.5), half of IGC's largest
#      drift slope (5.4), as the LNR's normal(0, 1) is of its 2.1. brms
#      would leave them flat. The others keep cogmod's: normal(0, 0.5) for
#      boundary, bias and sigmadrift, normal(0, 0.2) for ndt.
#   2. Never's slopes: the same rule.
#   3. The intercepts: SDs picked by hand, as for the LNR, to cover another
#      population (the drift's is wider because its scale is). The participant
#      SDs: IGC's posterior medians, averaged over the two illusions, with
#      normal(tau, 0.4 tau). The illusions' intercept differences take
#      normal(0, max(tau, |ML - Ebbinghaus| in IGC)), since IGC's own gap
#      exceeds tau for the drift and the bias.
#   4. lkj(2).
#    IGC posteriors (median; link scale; Intercept = average over this grid):
#                  Intercept        participant SD
#                  ML     Ebb       ML     Ebb
#      mu         -4.01  -3.11      0.47   0.69
#      boundary    2.23   2.02      0.92   0.84
#      bias        0.77   0.43      0.09   0.18
#      ndt        -1.15  -1.05      0.16   0.16
#      sigmadrift  1.31   0.67      0.85   0.97
#      poutlier                     2.07   2.32

igsa_igc_ddm5 <- list(
  intercept = c(mu = -3.56, boundary = 2.13, bias = 0.60, ndt = -1.10, sigmadrift = 0.99),
  intercept_sd = c(mu = 1, boundary = 0.5, bias = 0.5, ndt = 0.25, sigmadrift = 0.5),
  participant_sd = c(mu = 0.58, boundary = 0.88, bias = 0.14, ndt = 0.16, sigmadrift = 0.91),
  illusion_sd = c(mu = 0.90, boundary = 0.88, bias = 0.34, ndt = 0.16, sigmadrift = 0.91),
  poutlier_sd = 2.2,
  group_sd = c(mu = 2.5)
)

igsa_igc_ddm5_b <- data.frame(
  dpar = rep(c("mu", "boundary", "bias", "ndt", "sigmadrift"), each = 3),
  term = rep(c("Illusion_Strength", "Task_Difficulty", "Illusion_Strength:Task_Difficulty"), 5),
  MullerLyer = c(
    5.37, 2.61, 1.64,    # mu
    -0.58, -0.15, 0.16,  # boundary
    -0.64, -0.36, -0.19, # bias
    0.13, 0.05, -0.02,   # ndt
    -1.19, -0.04, 0.47   # sigmadrift
  ),
  Ebbinghaus = c(
    4.11, 2.02, 0.41,
    -0.53, -0.16, 0.28,
    -1.14, -0.19, -0.07,
    0.08, 0.07, -0.04,
    -1.27, 0.22, 0.74
  )
)

# The priors of one model, from its IGC numbers: `igc` as igsa_igc, and
# `igc_b` as igsa_igc_b, with a column for each of the two illusions that IGC
# informs. The third illusion takes their average, with twice the SD.
igsa_priors_igc <- function(f, data, igc, igc_b) {
  priors <- cogmod::cogmod_priors(f, data)
  dp <- function(par) if (par == "mu") "" else par

  out <- lapply(names(igc$group_sd), function(par) {
    brms::prior_string(sprintf("normal(0, %g)", igc$group_sd[[par]]), class = "b", dpar = dp(par))
  })
  have <- setdiff(names(igc_b), c("dpar", "term"))
  missing <- setdiff(levels(data$Illusion_Type), have)
  stopifnot(length(have) == 2, length(missing) == 1)
  tau <- igc$participant_sd
  for (i in seq_len(nrow(igc_b))) {
    r <- igc_b[i, ]
    centre <- unlist(r[have])
    centre[[missing]] <- mean(centre)
    for (illusion in names(centre)) {
      s <- sqrt((0.4 * centre[[illusion]])^2 + (tau[[r$dpar]] / 2)^2)
      if (illusion == missing) s <- 2 * s
      out[[length(out) + 1]] <- brms::prior_string(
        sprintf("normal(%.3g, %.3g)", centre[[illusion]], s),
        class = "b", dpar = dp(r$dpar), coef = paste0("Illusion_Type", illusion, ":", r$term)
      )
    }
  }
  for (par in names(igc$intercept)) {
    out[[length(out) + 1]] <- brms::prior_string(
      sprintf("normal(%g, %g)", igc$intercept[[par]], igc$intercept_sd[[par]]),
      class = "Intercept", dpar = dp(par)
    )
    for (illusion in levels(data$Illusion_Type)[-1]) {
      out[[length(out) + 1]] <- brms::prior_string(
        sprintf("normal(0, %g)", igc$illusion_sd[[par]]),
        class = "b", dpar = dp(par), coef = paste0("Illusion_Type", illusion)
      )
    }
    s <- tau[[par]]
    for (illusion in levels(data$Illusion_Type)) {
      out[[length(out) + 1]] <- brms::prior_string(
        sprintf("normal(%g, %g)", s, 0.4 * s),
        class = "sd", group = "Participant", dpar = dp(par),
        coef = paste0("Illusion_Type", illusion)
      )
    }
  }
  s <- igc$poutlier_sd
  out[[length(out) + 1]] <- brms::prior_string(
    sprintf("normal(%g, %g)", s, 0.4 * s),
    class = "sd", group = "Participant", dpar = "poutlier", coef = "Intercept"
  )
  # cogmod_priors() returns validate_prior()'s table, where a newer brms
  # (2.23) has already turned the default `cor` row into `L`; adding a `cor`
  # row to that is a duplicate. Edit whichever one is there.
  out[[length(out) + 1]] <- if ("L" %in% priors$class) {
    brms::prior_string("lkj_corr_cholesky(2)", class = "L")
  } else {
    brms::prior_string("lkj(2)", class = "cor")
  }

  do.call(c, c(list(priors), out, list(replace = TRUE)))
}

igsa_priors <- function(f, data) igsa_priors_igc(f, data, igsa_igc, igsa_igc_b)
igsa_priors_ddm5 <- function(f, data) igsa_priors_igc(f, data, igsa_igc_ddm5, igsa_igc_ddm5_b)


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
  ),

  # The paper's model (see "Formula"), fitted with cogmod >= 0.3.6: 0.3.5's
  # likelihood is off by up to a log unit per trial in the tails once
  # sigmadrift is estimated, and costs ~3.4x as much per gradient (cogmod's
  # NEWS). README.md, "DDM-5", has the library and the commands.
  ddm5 = list(
    formula = function() {
      brms::bf(
        igsa_f("RT | dec(Error)", igsa_re_full),
        igsa_f("boundary", igsa_re_light),
        igsa_f("bias", igsa_re_light),
        igsa_f("ndt", igsa_re_light),
        igsa_f("sigmadrift", igsa_re_light),
        sigmabias = 0,
        sigmandt = 0,
        poutlier ~ 1 + (1 | Participant),
        family = cogmod::cogmod_ddm()
      )
    },
    priors = igsa_priors_ddm5
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
