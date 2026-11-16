# =========================================================================
# Combine the shards of ONE model into a single fit
# =========================================================================
# fit_model.R runs as an array; shard N writes <model>_N.rds into
# IGSA_MODELS_DIR. This merges them into IGSA_MODELS_DIR/combined/<model>.rds.
# Which model is IGSA_MODEL. Submitted by `./hpc combine <model>`.
#
#   IGSA_CRITERION   "none" (default), "loo" or "waic"
#
# No criterion by default: there is one model, and loo is only needed to
# compare it with another (give that job --mem=96G, see combine.slurm).
# Shards are kept: each is hours of compute, the merge is minutes.

library(brms)
# add_criterion() calls log_lik(), which for a custom family resolves
# log_lik_cogmod_<family>() from cogmod.
library(cogmod)

source("models.R")

spec <- igsa_model(Sys.getenv("IGSA_MODEL", unset = "lnr"))
name <- spec$name

models_dir <- Sys.getenv("IGSA_MODELS_DIR", unset = "models")
combined_dir <- file.path(models_dir, "combined")
dir.create(combined_dir, recursive = TRUE, showWarnings = FALSE)

cat("**", name, ":", format(Sys.time()), "\n")

# The anchor matters: "lnr" must not also collect "lnr2".
pattern <- paste0("^", name, "_[0-9]+[.]rds$")
files <- list.files(models_dir, pattern = pattern, full.names = TRUE)
cat("** found", length(files), "shards in", models_dir, "\n")
if (length(files) == 0) stop("no shards matching ", pattern, " in ", models_dir)

# A shard was written by brm(), which may record its own path in $file, and
# add_criterion() writes the fit back there: without this the combined fit
# could be saved over shard 1 (IllusionGameComputational, 2026-09-18).
shards <- lapply(files, function(f) {
  fit <- readRDS(f)
  fit$file <- NULL
  fit
})

# Shards of another cogmod, run length or sampler (cmdstanr, or one stanli
# version: fit_model.R stamps m$stanli) would merge without complaint.
stamp <- vapply(shards, function(s) {
  paste(if (is.null(s$cogmod$version)) "?" else s$cogmod$version,
        s$fit@sim$warmup, s$fit@sim$iter,
        if (is.null(s$stanli$version)) "cmdstanr" else paste("stanli", s$stanli$version))
}, "")
if (length(unique(stamp)) > 1) {
  stop("shards differ in cogmod / warmup / iterations / sampler: ",
       paste(basename(files), stamp, sep = " = ", collapse = "; "), call. = FALSE)
}
cat("** cogmod / warmup / iterations / sampler:", stamp[1], "\n")

m <- brms::combine_models(mlist = shards)
m$file <- NULL
m$cogmod <- shards[[1]]$cogmod
if (!is.null(shards[[1]]$stanli)) {
  m$stanli <- list(version = shards[[1]]$stanli$version,
                   elapsed = lapply(shards, function(s) s$stanli$elapsed))
}
rm(shards)

criterion <- tolower(Sys.getenv("IGSA_CRITERION", unset = "none"))
if (!identical(criterion, "none")) {
  t0 <- Sys.time()
  m <- brms::add_criterion(m, criterion)
  cat(sprintf("** %s in %.1f min\n", criterion,
              as.numeric(difftime(Sys.time(), t0, units = "mins"))))
}

out <- file.path(combined_dir, paste0(name, ".rds"))
tmp <- paste0(out, ".tmp")
saveRDS(m, tmp)
file.rename(tmp, out)
cat("** wrote", out, "with", brms::ndraws(m), "draws from", brms::nchains(m), "chains\n")
cat(sprintf("** max Rhat %.3f | min neff_ratio %.3f\n",
            max(brms::rhat(m), na.rm = TRUE), min(brms::neff_ratio(m), na.rm = TRUE)))
cat("** finished:", name, "at", format(Sys.time()), "\n")
