# Build / refresh the project R library on Artemis.
#
#   ./hpc install          install anything missing
#   ./hpc install cogmod   force-reinstall cogmod at IGSA_COGMOD_REF's latest commit
#   ./hpc install all      force-reinstall everything
#
# The CmdStanR module ships brms / cmdstanr / loo; this only adds what it
# doesn't (cogmod) and a newer cmdstanr. brms 2.21.0 comes from the shared
# library the .slurm files put on R_LIBS_USER (lab hub, toolchain.md).
#
# The library is SHARED with every other project on the account
# (IllusionGameComputational, FakeArt), so on dmm56 all of this is usually
# there already. Do not install an older cogmod from here: they need >= 0.3.5
# too.

lib <- Sys.getenv("IGSA_R_LIBS", unset = file.path(
  "/mnt/lustre/users/psych", Sys.getenv("USER"),
  "cluster_R_libs/x86_64-pc-linux-gnu-library",
  paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = ".")
))
dir.create(lib, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(lib, .libPaths()))
cat("target library:", lib, "\n")
cat("running on:", Sys.info()[["nodename"]], "\n")

`%||%` <- function(a, b) if (is.null(a) || !nzchar(a)) b else a
repos <- "https://cloud.r-project.org"
need <- function(p) !requireNamespace(p, quietly = TRUE)

# IGSA_FORCE="cogmod" (comma/space separated, or "all") reinstalls a package
# even when it is already present.
force <- strsplit(Sys.getenv("IGSA_FORCE", unset = ""), "[, ]+")[[1]]
force <- force[nzchar(force)]
forced <- function(p) "all" %in% force || p %in% force

cogmod_ref <- Sys.getenv("IGSA_COGMOD_REF", unset = "dev")
cogmod_min <- Sys.getenv("IGSA_COGMOD_MIN", unset = "0.3.5")

# The module pins cmdstanr 0.7.1, which cannot read the CSV metadata of
# CmdStan >= 2.36.
if (need("cmdstanr") || forced("cmdstanr") || utils::packageVersion("cmdstanr") < "0.8.0") {
  cat("installing cmdstanr from stan-dev r-universe\n")
  install.packages("cmdstanr", lib = lib, repos = c("https://stan-dev.r-universe.dev", repos))
}

# CmdStan itself: ~15-25 min, once per account.
if (requireNamespace("cmdstanr", quietly = TRUE)) {
  have_cmdstan <- tryCatch({
    cmdstanr::cmdstan_version()
    TRUE
  }, error = function(e) FALSE)
  if (!have_cmdstan) {
    cat("no CmdStan found -- building one (~15-25 min, once per account)\n")
    cmdstanr::install_cmdstan(
      cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", unset = "4")),
      overwrite = FALSE
    )
  }
  cat("cmdstan:", tryCatch(
    paste(cmdstanr::cmdstan_path(), as.character(cmdstanr::cmdstan_version())),
    error = function(e) "MISSING"
  ), "\n")
}

if (need("remotes") || forced("remotes")) install.packages("remotes", lib = lib, repos = repos)

pkg_version <- function(p) {
  tryCatch(as.character(utils::packageVersion(p, lib.loc = .libPaths())),
           error = function(e) NA_character_)
}
cogmod_version <- pkg_version("cogmod")
if (need("cogmod") || forced("cogmod") ||
    (!is.na(cogmod_version) && package_version(cogmod_version) < cogmod_min)) {
  cat("installing cogmod@", cogmod_ref, " from GitHub (was: ",
      if (is.na(cogmod_version)) "none" else cogmod_version, ")\n", sep = "")
  remotes::install_github(paste0("DominiqueMakowski/cogmod@", cogmod_ref),
                          lib = lib, upgrade = "never", dependencies = TRUE, force = TRUE)
}

cat("=== FINAL CHECK ===\n")
for (p in c("brms", "cmdstanr", "loo", "cogmod")) {
  v <- pkg_version(p)
  cat(sprintf("%-10s %s", p, if (is.na(v)) "MISSING" else paste("OK", v)), "\n")
}
d <- tryCatch(utils::packageDescription("cogmod"), error = function(e) NULL)
if (!is.null(d)) {
  cat("cogmod ref   :", d$RemoteRef %||% "?", "\n")
  cat("cogmod commit:", substr(d$RemoteSha %||% "?", 1, 10), "\n")
}

installed <- pkg_version("cogmod")
if (is.na(installed) || package_version(installed) < cogmod_min) {
  stop("cogmod ", if (is.na(installed)) "none" else installed, " is below the required ",
       cogmod_min, " -- check IGSA_COGMOD_REF (currently '", cogmod_ref, "')", call. = FALSE)
}
cat("cogmod >=", cogmod_min, "OK\n")
