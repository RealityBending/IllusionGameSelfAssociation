# =========================================================================
# Fit ONE model, as one shard of an array job
# =========================================================================
# Which model is IGSA_MODEL (see models.R); which shard is SLURM_ARRAY_TASK_ID.
# Each shard writes <model>_<shard>.rds into IGSA_MODELS_DIR and
# combine_model.R merges them into combined/<model>.rds. Submitted by
# `./hpc fit <model>`; also runs on a laptop (see README.md, "Local test").
#
# Run-shaping variables (all forwarded by ./hpc when set):
#   IGSA_DATA                the trial file           (default data/data_illusiongame.csv)
#   IGSA_WARMUP              warmup per chain         (default 1500)
#   IGSA_SAMPLES             draws per chain          (default 1000)
#   IGSA_CHAINS              chains per array task    (default 2)
#   IGSA_NPARTICIPANTS       subset, or "all"         (default all)
#   IGSA_FILE_REFIT          "never" (resume) or "always"
#   IGSA_BACKEND             "cmdstanr" (default), "stanli" or "nutpie"
#
# The defaults are IllusionGameComputational's production settings: 4 shards
# x 2 chains x 1,000 = 8,000 draws, after 1,500 warmup iterations.

library(brms)
library(cogmod) # remotes::install_github("DominiqueMakowski/cogmod@dev")

# 0.3.5 is what IllusionGameComputational's fits, and so the priors taken
# from them, were made with (it changed poutlier's default prior).
cogmod_min <- Sys.getenv("IGSA_COGMOD_MIN", unset = "0.3.5")
if (utils::packageVersion("cogmod") < cogmod_min) {
  stop("cogmod ", utils::packageVersion("cogmod"), " is too old; need >= ", cogmod_min, ". ",
       "Run  ./hpc install cogmod", call. = FALSE)
}

# Backend. "cmdstanr" is brm()'s own fit, with reduce_sum threads.
# "stanli" samples brms's program -- its Stan code and data -- in stanli,
# which interprets it over precompiled Stan Math kernels. It was faster in
# IllusionGameComputational (its AGENT.md 6.9), whose programs kept their
# reduce_sum threading. This one does not: brms's partial_log_lik_lpmf
# writes in place, so stanli 0.25.0 runs each chain on one core. In the
# 2026-11-03 smoke tests (30 participants, same node, 8 CPUs) cmdstanr ran
# 400 iterations in 48 min; stanli took 70 min for its first 50.
#
# "nutpie" (2026-11-17) samples the same program with nutpie's sampler
# (nuts-rs, through nutpieR) on stanli's log density and gradient
# (stanli::sample_nutpie(), stanli >= 0.26.0). Its warmup learns from the
# gradients and settles on larger steps: about 2x cmdstanr's ESS per second
# on a small DDM-5 (cogmod's benchmarks/nutpieR/). stanli (0.26.0, 0.27.0)
# does not thread brms's likelihood here (OP_SET_INDEX_INPLACE): its loop
# adds the drift's 12 participant terms, and above 10 stanli leaves its fast
# path (README.md, "The same model with stanli + nutpie"). So each chain is
# one core: give the task one CPU per chain. brms, stanli and
# nutpieR come from the library on IGSA_R_LIBS (README.md, "DDM-5").
backend <- Sys.getenv("IGSA_BACKEND", unset = "cmdstanr")
if (!backend %in% c("cmdstanr", "stanli", "nutpie")) {
  stop("IGSA_BACKEND must be 'cmdstanr', 'stanli' or 'nutpie', not '", backend, "'", call. = FALSE)
}
if (backend %in% c("stanli", "nutpie")) {
  # stanli alone from its own library (./hpc passes IGSA_STANLI_LIB), so that
  # nothing there can shadow the production brms 2.21.0. Its runtime comes
  # from STANLI_RUNTIME: never call stanli_install(), which deletes the
  # runtimes of other releases from its cache, including those of running
  # jobs.
  loadNamespace("stanli", lib.loc = Sys.getenv("IGSA_STANLI_LIB"))
  if (!stanli::stanli_thread_safe()) {
    stop("this stanli runtime has no thread support", call. = FALSE)
  }
}
if (backend == "nutpie" &&
    (utils::packageVersion("stanli") < "0.26.0" || !requireNamespace("nutpieR", quietly = TRUE))) {
  stop("IGSA_BACKEND=nutpie needs stanli >= 0.26.0 and nutpieR", call. = FALSE)
}
# stanli 0.26.0's bridgestan_data(), which sample_nutpie() hands to nutpie,
# keeps the data JSON after its opening brace with substring(data, first):
# substring()'s default `last` is 1e6, so data longer than a million
# characters is cut and the model fails to open ("embedded __stanli
# manifest: parse error"). Even 6 participants' data are 3.2 million here.
# Patched in stanli's namespace for this session; the JSON is validated
# before sampling.
if (backend == "nutpie") {
  bsd <- get("bridgestan_data", envir = asNamespace("stanli"))
  old <- 'substring(data, attr(open, "match.length") + 1L)'
  src <- deparse(body(bsd), width.cutoff = 500L)
  if (any(grepl(old, src, fixed = TRUE))) {
    body(bsd) <- parse(text = sub(old, 'substring(data, attr(open, "match.length") + 1L, nchar(data))',
                                  src, fixed = TRUE))[[1]]
    utils::assignInNamespace("bridgestan_data", bsd, "stanli")
    cat("patched stanli's bridgestan_data() (substring() cut the data at 1e6 characters)\n")
  }
  rm(bsd, old, src)
}
# The sampler a shard is stamped with: a shard is only reused, or combined,
# with shards of the same one.
sampler <- switch(backend,
  cmdstanr = "cmdstanr",
  stanli = paste("stanli", format(utils::packageVersion("stanli"))),
  nutpie = paste("nutpie, stanli", format(utils::packageVersion("stanli")))
)
shard_sampler <- function(m) {
  if (is.null(m$stanli$version)) return("cmdstanr")
  paste(if (identical(m$stanli$sampler, "nutpie")) "nutpie, stanli" else "stanli", m$stanli$version)
}

source("models.R")

spec <- igsa_model(Sys.getenv("IGSA_MODEL", unset = "lnr"))

task_id <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", unset = "1"))
total_cores <- as.numeric(Sys.getenv("SLURM_CPUS_PER_TASK", unset = "2"))

# Each chain is a separate process with its own copy of the data and AD stack;
# threading takes the remaining cores. 16 cores / 2 chains = 8 threads.
chains_per_task <- as.integer(Sys.getenv("IGSA_CHAINS", unset = "2"))
threads_per_chain <- max(1, total_cores %/% chains_per_task)

models_dir <- Sys.getenv("IGSA_MODELS_DIR", unset = "models")
dir.create(models_dir, recursive = TRUE, showWarnings = FALSE)

# "never" makes a resubmitted array skip shards whose .rds already exists, so a
# job killed at the wall resumes instead of restarting. A shard from another
# cogmod or run length stops the job instead (see "Reuse" below), and
#   IGSA_FILE_REFIT=always ./hpc fit <model>
# forces a clean refit. A changed formula or data is NOT detected: give it its
# own IGSA_MODELS_DIR.
file_refit <- Sys.getenv("IGSA_FILE_REFIT", unset = "never")
if (!file_refit %in% c("never", "always")) {
  stop("IGSA_FILE_REFIT must be 'never' or 'always', not '", file_refit, "'", call. = FALSE)
}

warmup <- as.integer(Sys.getenv("IGSA_WARMUP", unset = "1500"))
iter <- warmup + as.integer(Sys.getenv("IGSA_SAMPLES", unset = "1000"))

cat(sprintf(
  "config: model=%s shard=%d warmup=%d samples=%d chains=%d threads/chain=%d refit=%s sampler=%s\n",
  spec$name, task_id, warmup, iter - warmup, chains_per_task, threads_per_chain, file_refit, sampler
))
cat("brms", format(utils::packageVersion("brms")), "- cogmod",
    format(utils::packageVersion("cogmod")), "\n")
if (backend %in% c("stanli", "nutpie")) cat("stanli from", find.package("stanli"), "\n")
if (backend == "nutpie") {
  cat("nutpieR", format(utils::packageVersion("nutpieR")), "from", find.package("nutpieR"), "\n")
}


# Data --------------------------------------------------------------------
# Built locally by analysis/0_preprocessing.qmd and copied up by `./hpc push`: the data
# are not on GitHub.

df <- read.csv(Sys.getenv("IGSA_DATA", unset = "data/data_illusiongame.csv"))

# No set.seed() anywhere before sampling: with the module's processx (< 3.9),
# array tasks that set.seed() alike tag their chains alike and kill each
# other's (lab hub, troubleshooting.md "Chains killed by a sibling task").
# brm(seed = ) seeds CmdStan only.

# Subset for smoke tests: the first n participants of each group in turn, so
# that every Group x Illusion cell is still in the design.
n_participants <- Sys.getenv("IGSA_NPARTICIPANTS", unset = "all")
if (!identical(tolower(n_participants), "all")) {
  first <- df[!duplicated(df$Participant), c("Participant", "Group")]
  first$rank <- ave(seq_len(nrow(first)), first$Group, FUN = seq_along)
  first <- first[order(first$rank, first$Group), ]
  df <- df[df$Participant %in% head(first$Participant, as.integer(n_participants)), ]
}

data <- igsa_prepare(df)
cat("participants:", nlevels(data$Participant), " rows:", nrow(data), "\n")
print(table(Group = data$Group[!duplicated(data$Participant)]))


# Fit ---------------------------------------------------------------------

f <- spec$formula()
priors <- spec$priors(f, data)

# One-line summary per shard so runs can be compared from the .out logs alone.
report_fit <- function(m, name, wall_min) {
  np <- brms::nuts_params(m) # post-warmup draws only
  stat <- vapply(split(np$Value, np$Parameter), mean, numeric(1))
  rh <- brms::rhat(m)
  ne <- brms::neff_ratio(m)
  cat(sprintf(
    "REPORT %s | wall %.1f min | n_leapfrog %.0f | treedepth %.2f | stepsize %.3g | divergent %.3f | accept %.2f | max Rhat %.3f | min neff_ratio %.3f | n params %d\n",
    name, wall_min, stat[["n_leapfrog__"]], stat[["treedepth__"]], stat[["stepsize__"]],
    stat[["divergent__"]], stat[["accept_stat__"]], max(rh, na.rm = TRUE),
    min(ne, na.rm = TRUE), length(rh)
  ))
  md <- attr(m$fit, "metadata")
  if (!is.null(md$time)) {
    cat("REPORT time per chain (s):\n")
    print(md$time)
  }
  if (!is.null(m$stanli$elapsed)) {
    cat("REPORT time per chain (s),", shard_sampler(m), "(nutpie: warmup and sampling together):\n")
    print(m$stanli$elapsed)
  }
  invisible(stat)
}

shard_name <- sprintf("%s_%d", spec$name, task_id)
shard_file <- file.path(models_dir, paste0(shard_name, ".rds"))

# Save --------------------------------------------------------------------
# IllusionGameComputational lost five 1-day shards on 2026-10-05 to a failed
# saveRDS on Lustre: the shard went straight to its final name and the Stan
# CSVs were in the node's tempdir. So the CSVs go to models/stan_csv/ and
# are deleted only once the shard is saved, and the shard is written to .tmp
# and renamed. After a failed save, rebuild the fit from the CSVs instead of
# resampling: brm(..., empty = TRUE), then
# m$fit <- brms:::read_csv_as_stanfit(<csv files>) and m <- brms:::rename_pars(m).
save_shard <- function(m, file, keep_dir) {
  tmp <- paste0(file, ".tmp")
  ok <- tryCatch({
    saveRDS(m, tmp)
    file.rename(tmp, file)
  }, error = function(e) {
    cat("saveRDS failed:", conditionMessage(e), "\n")
    FALSE
  })
  if (!isTRUE(ok)) {
    unlink(tmp)
    stop("could not save ", file, ". The Stan CSVs are kept in ", keep_dir, call. = FALSE)
  }
}

# Reuse -------------------------------------------------------------------
# Only a shard of this very run (cogmod, warmup, draws, sampler) is reused;
# any other stops the task rather than be adopted or overwritten.
m <- NULL
if (file_refit == "never" && file.exists(shard_file)) {
  m <- tryCatch(readRDS(shard_file), error = function(e) {
    cat("existing shard unreadable (", conditionMessage(e), "); refitting\n")
    NULL
  })
}
if (!is.null(m)) {
  old_cogmod <- if (is.null(m$cogmod$version)) "unrecorded" else m$cogmod$version
  old_run <- c(m$fit@sim$warmup, m$fit@sim$iter)
  old_sampler <- shard_sampler(m)
  if (old_cogmod == "unrecorded" || package_version(old_cogmod) < cogmod_min ||
      !isTRUE(all(old_run == c(warmup, iter))) || old_sampler != sampler) {
    stop(shard_file, " is from another run (cogmod ", old_cogmod, ", ", old_run[1],
         " warmup + ", old_run[2] - old_run[1], " draws, ", old_sampler,
         "; this run wants cogmod >= ", cogmod_min, ", ", warmup, " + ", iter - warmup,
         ", ", sampler, "). Move it aside or refit over it (IGSA_FILE_REFIT=always).",
         call. = FALSE)
  }
  cat("reusing existing shard", shard_file, "\n")
}

csv_dir <- file.path(models_dir, "stan_csv",
                     paste0(shard_name, "_", Sys.getenv("SLURM_ARRAY_JOB_ID", unset = "local")))

t0 <- Sys.time()
if (is.null(m) && backend == "stanli") {
  dir.create(csv_dir, recursive = TRUE, showWarnings = FALSE)
  # brm() up to the point where it would compile: the program, data and
  # threading (reduce_sum) that the cmdstanr arm samples.
  m <- brm(f,
    data = data,
    prior = priors,
    stanvars = cogmod_stanvars(f),
    backend = "cmdstanr",
    warmup = warmup,
    iter = iter,
    chains = chains_per_task,
    threads = threading(threads_per_chain),
    empty = TRUE
  )
  sm <- stanli::stanli_model(
    code = as.character(brms::stancode(m)),
    data = lapply(unclass(brms::standata(m)), identity),
    threads_per_chain = threads_per_chain
  )
  # The same cogmod_inits() as the cmdstanr arm, one row per chain on the
  # unconstrained scale; partial = TRUE draws anything they leave out in
  # (-2, 2), as CmdStan does.
  inits <- cogmod_inits(f, data)
  init_u <- do.call(rbind, lapply(seq_len(chains_per_task), function(i) {
    stanli::unconstrain(sm, inits(i), partial = TRUE)
  }))
  # stanli runs in this process, so the processx clash above does not arise;
  # the seed is the cmdstanr arm's.
  sfit <- stanli::sample_model(sm,
    chains = chains_per_task,
    parallel_chains = chains_per_task,
    threads_per_chain = threads_per_chain,
    seed = 1234 + task_id,
    warmup = warmup,
    samples = iter - warmup,
    init = init_u,
    refresh = 50
  )
  # Whether the threading took: brms's reduce_sum kept as a reduction, or
  # refused and run serially.
  cat("stanli reduce_sum retained:", format(sfit$model$reduce_sum_count),
      " fallbacks:", format(sfit$model$reduce_sum_fallbacks), "\n")
  # `exclude` drops the z_ latents brm() leaves out (a character vector in
  # brms 2.21.0, a list of them in 2.23.1, hence unlist()). as_stanfit() returns
  # stanli's own subclass of stanfit, which readRDS() restores only where
  # stanli is installed; a plain stanfit has the same slots and reads
  # anywhere, the laptop included.
  sf <- methods::as(stanli::as_stanfit(sfit, exclude = unlist(brms:::exclude_pars(m), use.names = FALSE)),
                    "stanfit", strict = TRUE)
  # stanli writes no CSVs: the draws are kept here until the shard is saved.
  saveRDS(sf, file.path(csv_dir, "stanfit.rds"))
  m$fit <- sf
  m <- brms:::rename_pars(m) # what brm() does after sampling
  m$stanli <- list(version = format(utils::packageVersion("stanli")), seed = 1234 + task_id,
                   elapsed = stanli::get_elapsed_time(sfit))
  rm(sfit, sf)
  sha <- utils::packageDescription("cogmod")$RemoteSha
  m$cogmod <- list(version = format(utils::packageVersion("cogmod")),
                   sha = if (is.null(sha)) NA_character_ else sha)
  save_shard(m, shard_file, keep_dir = csv_dir)
  unlink(csv_dir, recursive = TRUE)
}
if (is.null(m) && backend == "nutpie") {
  dir.create(csv_dir, recursive = TRUE, showWarnings = FALSE)
  # brms's program and data, as the stanli arm, but without reduce_sum:
  # stanli would run it serially anyway.
  m <- brm(f,
    data = data,
    prior = priors,
    stanvars = cogmod_stanvars(f),
    backend = "cmdstanr",
    warmup = warmup,
    iter = iter,
    chains = chains_per_task,
    empty = TRUE
  )
  t_build <- Sys.time()
  sm <- stanli::stanli_model(
    code = as.character(brms::stancode(m)),
    data = lapply(unclass(brms::standata(m)), identity)
  )
  cat(sprintf("stanli build: %.0f s\n", as.numeric(difftime(Sys.time(), t_build, units = "secs"))))
  bd <- stanli::bridgestan_data(sm)
  if (!isTRUE(jsonlite::validate(bd)) || nchar(bd) < nchar(sm$source$data_json)) {
    stop("the data JSON that nutpie would get is not valid (", nchar(bd), " characters)", call. = FALSE)
  }
  cat("data JSON for nutpie:", nchar(bd), "characters, valid\n")
  rm(bd)
  # The same cogmod_inits() as the other arms, one constrained list per chain,
  # which is what nutpieR takes. One core per chain (`cores`).
  inits <- cogmod_inits(f, data)
  sfit <- stanli::sample_nutpie(sm,
    chains = chains_per_task,
    seed = 1234 + task_id,
    warmup = warmup,
    samples = iter - warmup,
    init = lapply(seq_len(chains_per_task), inits),
    cores = chains_per_task,
    progress = "text",
    refresh = 25
  )
  sf <- methods::as(stanli::as_stanfit(sfit, exclude = unlist(brms:::exclude_pars(m), use.names = FALSE)),
                    "stanfit", strict = TRUE)
  # No CSVs here either: the draws are kept until the shard is saved.
  saveRDS(sf, file.path(csv_dir, "stanfit.rds"))
  m$fit <- sf
  m <- brms:::rename_pars(m)
  m$stanli <- list(version = format(utils::packageVersion("stanli")), sampler = "nutpie",
                   nutpieR = format(utils::packageVersion("nutpieR")), seed = 1234 + task_id,
                   elapsed = stanli::get_elapsed_time(sfit), step_size = sfit$step_size)
  rm(sfit, sf)
  sha <- utils::packageDescription("cogmod")$RemoteSha
  m$cogmod <- list(version = format(utils::packageVersion("cogmod")),
                   sha = if (is.null(sha)) NA_character_ else sha)
  save_shard(m, shard_file, keep_dir = csv_dir)
  unlink(csv_dir, recursive = TRUE)
}
if (is.null(m)) {
  dir.create(csv_dir, recursive = TRUE, showWarnings = FALSE)
  m <- brm(f,
    data = data,
    prior = priors,
    init = cogmod_inits(f, data),
    stanvars = cogmod_stanvars(f),
    backend = "cmdstanr",
    warmup = warmup,
    iter = iter,
    chains = chains_per_task,
    cores = chains_per_task,
    threads = threading(threads_per_chain),
    seed = 1234 + task_id,
    # Must match precompile.R's cpp_options exactly, or a cold array races to
    # build a second precompiled-header variant.
    stan_model_args = list(
      stanc_options = list("O1"),
      cpp_options = list(STAN_CPP_OPTIMS = TRUE, STAN_NO_RANGE_CHECKS = TRUE)
    ),
    output_dir = csv_dir # passed on to cmdstanr's $sample()
  )
  sha <- utils::packageDescription("cogmod")$RemoteSha
  m$cogmod <- list(version = format(utils::packageVersion("cogmod")),
                   sha = if (is.null(sha)) NA_character_ else sha)
  save_shard(m, shard_file, keep_dir = csv_dir)
  unlink(csv_dir, recursive = TRUE)
}
wall_min <- as.numeric(difftime(Sys.time(), t0, units = "mins"))

cat(spec$name, "shard", task_id, ": SUCCESSFUL.\n")
tryCatch(report_fit(m, spec$name, wall_min),
  error = function(e) cat("REPORT failed:", conditionMessage(e), "\n")
)
