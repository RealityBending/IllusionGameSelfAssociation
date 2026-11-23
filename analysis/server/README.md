# The LNR on Artemis (Sussex HPC)

> **Cluster-level instructions live in the lab HPC hub**:
> <https://github.com/RealityBending/Lab/tree/main/hpc> (start at `hpc/README.md`).
> Prefer a local clone of `RealityBending/Lab` if there is one — it also holds
> your gitignored `hpc/private/` notes. The hub wins over anything here that
> contradicts it; this file only holds what is specific to this project.

One model, a log-normal race (`cogmod_lnr`) of choice and RT on every Illusion
Game trial, replaces the manuscript's separate error, RT and EZ-diffusion
analyses. This folder is a trimmed copy of FakeArt's `analysis/server/` (the
hub's reference layout), with IllusionGameComputational's fit script.

| file | role |
| --- | --- |
| `../0_preprocessing.qmd` | from the open data: Never / Past / Recent into `data/groups.csv`, the questionnaire scores, and `data/data_illusiongame.csv` (run locally; the derived data are gitignored) |
| `../2_priors.R` | projects IllusionGameComputational's surfaces onto this design: the prior centres hard-coded in `models.R` (run locally, only when the priors change) |
| `models.R` | **the model**: formula, priors, registry |
| `fit_model.R` / `fit.slurm` | fits one shard (2 chains) per array task |
| `combine_model.R` / `combine.slurm` | merges the shards into `models/combined/<model>.rds` |
| `marginals.R` | marginal means, slopes, design averages, the illusion magnitude index and group contrasts from the fit (local) |
| `install_pkgs.R`, `precompile.R` | project R library and CmdStan header, once per account |
| `hpc` | the driver |
| `hpc.local` | **gitignored**: this machine's account, e.g. `IGSA_HPC_USER=oc236` |

## The model

Per parameter (`mu` = the correct accumulator's rate `nu0`, `nuone`,
`sigmazero`, `sigmaone`, `ndt`):

```
param ~ Group * (Illusion_Type / (Illusion_Strength * Task_Difficulty)) + (0 + <random part> | Participant)
```

- **Random part:** the full `Illusion_Type / (Illusion_Strength * Task_Difficulty)` for the two drift rates (12 per participant), `Illusion_Type` alone for the sigmas and `ndt`.
- **Fixed settings:** `sigmabias = 0`, and `poutlier ~ 1 + (1 | Participant)`.
- **Predictors:** both are on [-1, 1], fixed by the task's stimulus grid (see `../0_preprocessing.qmd`).
  - `Illusion_Strength`: + is conflicting.
  - `Task_Difficulty`: + is hardest (the smallest difference).
- **Coding:** `Group` is treatment-coded with Never as the reference. Group comparisons come from `marginals.R` (per-draw marginal means and contrasts), not from the coefficients.
- **Priors** (`models.R` has the reasoning and the source numbers):
  - IllusionGameComputational's `gam_lnr` fits set the Never group's surface. Only its MullerLyer and VerticalHorizontal fits are used, because its Ebbinghaus fits never converged.
    - Per-illusion strength, difficulty and interaction slopes: IGC's smooths read at this task's 160 design points and projected onto the linear surface (`../2_priors.R`). The SD is √((0.4 b)² + (τ/2)²), where τ is the parameter's IGC participant SD. Ebbinghaus gets the average of the other two illusions, with twice the SD.
    - Illusion intercept differences: normal(0, τ).
    - The centred intercepts, and the participant SDs of the per-illusion intercepts and of `poutlier`.
  - Every Group coefficient stays weak: normal(0, 1) on both drift rates; cogmod's defaults on the sigmas (0.5) and `ndt` (0.2).
  - lkj(2) on the correlations.

Before a fit, rebuild the data from the repo root:

```bash
quarto render analysis/0_preprocessing.qmd   # data/groups.csv, data/data_illusiongame.csv
```

It reads the de-identified open data in `data/open/`, which is in git.
`../0_deidentify.R` builds it from the raw jsPsych files in Box
(`IGSA_RAW_DIR`), and only someone with the raw files needs to run it.
Its Groups section applies the manuscript's group rules to the screening answers.
It reproduces the 43 Never / 39 Recent / 35 Past: 117 participants and 55,470
trials after cleaning. The control who stated an age of 16 is out since
2026-11-21; the fits before that date include that session (118 participants,
55,937 trials). It states the rules and stops the render if a count changes.

The cluster gets the model input from `./hpc push`, not from GitHub, because
`data/data_illusiongame.csv` is derived and gitignored.

## The sampler: cmdstanr, not stanli

Fits sample with brm()'s own cmdstanr backend, with reduce_sum threads.
`IGSA_BACKEND=stanli` samples the same program in stanli instead. It was the
default for a day (2026-11-03) and was dropped after the smoke tests below.
- **What stanli does:** `fit_model.R` builds brms's program and data with
  `brm(empty = TRUE)`, then samples that same program in stanli. stanli
  interprets the program over precompiled Stan Math kernels, so nothing is
  compiled.
- **Why it looked faster:** IllusionGameComputational's three full-data
  tests (its `analysis/server/AGENT.md` 6.9). stanli took 0.57–0.72×
  cmdstanr's wall time per chain there, with 1.2–2× the bulk ESS per hour.
- **Why it is slower here: it does not thread this model.**
  - stanli 0.25.0 says at startup: "threads_per_chain = 4 has no effect on
    this model, which has no reduce_sum call to run in parallel". The
    laptop's 0.23.2 gave the reason: brms's `partial_log_lik_lpmf` writes in
    place (`OP_SET_INDEX_INPLACE`).
  - IGC's programs (one smooth and an intercept) kept their threading, and
    its speed-up was measured with it.
  - Here each chain runs on one core: at five minutes, stanli kept 1.6 of
    its 8 cores busy, against cmdstanr's 6.7. It took about 55 s an
    iteration, several times cmdstanr's pace.
  - More chains per CPU would not help, because warmup time per chain is
    what limits a fit.
- **The install, if it is tried again:** IGC's stanli 0.25.0 on `dmm56`,
  which `./hpc` passes to every job.
  - The package is in `cogmod_stanli/R_libs_0.25.0`, built for x86-64-v3.
  - The runtime is in `cogmod_stanli/runtime_v0.25.0/libstanli.so`, passed as
    `STANLI_RUNTIME`.
  - **Never run `stanli_install()`:** it deletes other releases' runtimes from
    its cache, under running jobs.
- **Shards are stamped with their sampler.** `fit_model.R` will not resume
  from another sampler's shard, and `combine_model.R` will not mix them.

## Every session

The **GlobalProtect VPN must be connected**. From `analysis/server/`:

```bash
./hpc check                # VPN + SSH
./hpc push                 # scripts (CRLF -> LF) + data/data_illusiongame.csv
./hpc models               # lnr, ddm5
./hpc queue
./hpc progress lnr         # per chain: latest iteration; REPORT lines at the end
./hpc log lnr              # when something is wrong
```

Once per account for this project: `./hpc setup`. On `dmm56` the R library,
cogmod 0.3.5, stanli 0.25.0, CmdStan and the precompiled header are already
there from IllusionGameComputational. `./hpc install` and `./hpc precompile` should then
finish quickly and report them present; on a fresh account they build them.

## 1. Smoke test

Its own models directory, so it can never be adopted as a production shard:

```bash
IGSA_MODELS_DIR=/mnt/lustre/users/psych/dmm56/IGSelfAssociation/smoke \
IGSA_NPARTICIPANTS=30 IGSA_WARMUP=300 IGSA_SAMPLES=100 \
  ./hpc fit lnr --array=1 --partition=general --cpus-per-task=8 --mem=8G
./hpc log lnr              # want "brms 2.21.0 from /research/...", then SUCCESSFUL and a REPORT line
```

It runs on `general` (8 hours), not `short`, whose 2-hour limit it would
probably exceed. The laptop needed 55 minutes for 200 warmup iterations with
24 participants, and this run is 400 iterations with 30. If an `./hpc`
command fails with "Connection reset", the login node's sshd is rate-limiting
a burst of connections: wait a minute.

Two smoke tests were run on 2026-11-03, one per sampler. Both used the same
30 participants (the data with raw IDs, pushed as `data_illusiongame_ref.csv`),
8 CPUs, and the same zen5 node, `rtx-01`:

| sampler | job | models dir | result |
| --- | --- | --- | --- |
| cmdstanr, 2 chains × 4 threads | 11645856 | `smoke/` | done in 48 min (chains 39 and 46 min) |
| stanli 0.25.0, 1 core per chain | 11645959 | `smoke_stanli/` | cancelled at iteration 50 of 400 after 70 min |

cmdstanr's `REPORT`: mean tree depth 9.1 (~600 leapfrog steps a draw) at
step size 0.0075, 0.5% divergent, max Rhat 1.25, min ESS ratio 0.03. That is
fine for 300 warmup iterations, and a hard geometry.

Scaled by participants (×4) and iterations (×6), production would take about
a day or two per shard, within `long`'s 8 days. Tree depth is capped at 10
(1,023 steps), so the full data cannot take more than ~1.7× the smoke
test's steps per draw. The 64 CPUs may wait in the queue: `long` caps CPUs
per user (~140), and IllusionGameComputational's jobs hold 128.

## 2. Production

```bash
./hpc fit lnr              # 4 shards x 2 chains x 8 threads on long; 1,500 warmup + 1,000 draws each
./hpc combine lnr          # after all four shards: models/combined/lnr.rds
./hpc pull                 # -> analysis/models/lnr.rds
```

The defaults (`fit.slurm`, `fit_model.R`) give 8,000 draws. `long` has no
`--time`, so each task gets its 8-day maximum.

When another project's arrays fill `long`, add `--partition=verylong`. Its
70-CPU cap is separate from `long`'s 140, at the same priority and on the same
nodes, and the four 16-CPU shards fit (the lab hub's `artemis.md`, "Quotas").
The 2026-11-03 production run went there, because IllusionGameComputational
held 128 of `long`'s 140 CPUs.

`combine` goes to `general`, which has a per-user CPU cap too: on 2026-11-06
another project's 400 CPUs there held it as `QOSMaxCpuPerUserLimit`. It
needs minutes (2.3 min and ~5 GB for 8 shards), so send it to `short`
instead: `./hpc combine lnr --partition=short --time=01:00:00`. After a few
`./hpc` calls in quick succession Artemis may reset new SSH connections
("kex_exchange_identification: Connection reset"); wait a minute. Run-shaping variables, forwarded
by `./hpc fit` when set:

| variable | default | |
| --- | --- | --- |
| `IGSA_NPARTICIPANTS` | `all` | subset for tests, balanced across groups |
| `IGSA_WARMUP` / `IGSA_SAMPLES` | `1500` / `1000` | per chain |
| `IGSA_CHAINS` | `2` | per array task; threads per chain = CPUs / chains |
| `IGSA_FILE_REFIT` | `never` | `never` resumes a killed array; `always` refits |
| `IGSA_CRITERION` | `none` | `loo` for a model comparison (`./hpc combine lnr --mem=96G`) |
| `IGSA_BACKEND` | `cmdstanr` | or `stanli` (see "The sampler") |

`file_refit = "never"` reuses a shard on disk when it has the same cogmod,
warmup, draw count and sampler; any other shard stops the task. **A changed formula,
priors or data are not detected**: give that run its own `IGSA_MODELS_DIR`, or
set `IGSA_FILE_REFIT=always`.

## DDM-5: the paper's model

`ddm5` in `models.R` is IllusionGameComputational's DDM-5 on this design:
drift, boundary, bias, ndt and the between-trial drift SD `sigmadrift`, each
with the LNR's fixed part, the full participant surface on the drift and an
intercept per illusion on the rest. Its priors come from IGC's `gam_ddm5`
MullerLyer and Ebbinghaus fits by the LNR's rules (`../2_priors.R` prints
them). It is the paper's model since 2026-11-18; `../3_ddm_groups.qmd` and `../4_ddm_correlates.qmd` read it.

It runs on **cogmod 0.3.6** (`ccf2351`), installed on 2026-11-17 into a library
of its own, `R_libs_cogmod_0.3.6/` in the project directory, with the
script that installed it. 0.3.5's likelihood was off by up to a log unit per
trial in the tails once `sigmadrift` is estimated, and cost ~3.4x as much per
gradient (cogmod's NEWS). The account's shared library stays at 0.3.5,
which IllusionGameComputational's queued fits use. Every `./hpc` call for
this model takes the same prefix (`MSYS_NO_PATHCONV=1` stops Git Bash from
rewriting the paths):

```bash
export MSYS_NO_PATHCONV=1 IGSA_COGMOD_MIN=0.3.6 \
  IGSA_R_LIBS=/mnt/lustre/users/psych/dmm56/IGSelfAssociation/R_libs_cogmod_0.3.6:/mnt/lustre/users/psych/dmm56/cluster_R_libs/x86_64-pc-linux-gnu-library/4.3
./hpc fit ddm5 --partition=verylong        # submitted 2026-11-17: job 11757858
./hpc combine ddm5 --partition=short --time=01:00:00
./hpc pull 'combined/ddm5.rds'
```

**The 117-participant refit** (2026-11-21, without the control who stated an
age of 16). A changed data set is not detected by `file_refit = "never"`, so
it has its own models directory, and the 118-participant shards stay in
`models/`. The same prefix as above, plus:

```bash
export IGSA_MODELS_DIR=/mnt/lustre/users/psych/dmm56/IGSelfAssociation/models_n117
./hpc push                                 # the 117-participant data replace the cluster's copy
./hpc fit ddm5 --partition=verylong        # submitted 2026-11-21: job 11781109, done 2026-11-22
./hpc combine ddm5 --partition=short --time=01:00:00   # job 11781960, 1.3 min
TMPDIR="$(cygpath -m "$TEMP")" ./hpc pull 'combined/ddm5.rds'   # -> analysis/models/ddm5.rds; the 118 fit is kept as ddm5_n118.rds
```

Done on 2026-11-22: 8,000 draws from 8 chains, no divergences, max Rhat
1.033, min neff_ratio 0.029 (AGENTS.md, DDM-5 entry). The `TMPDIR` on the
pull is needed with `MSYS_NO_PATHCONV=1` set: `./hpc pull` stages into
`${TMPDIR:-/tmp}`, and Windows's `scp.exe` cannot open `/tmp/...` once Git
Bash no longer rewrites it ("open local ... No such file or directory").

`marginals.R` handles both fits: `igsa_draws()` picks the parameters by the
fit's family and gives the DDM-5 a `delta` (−drift, towards the correct
response) and a `perror` of its own, so `igsa_index()` and the contrasts work
unchanged. `analysis/5_ddm_vs_lnr.qmd` compares the two fits.

### The same model with stanli + nutpie

`IGSA_BACKEND=nutpie` (2026-11-17) samples brms's program with nutpie's
sampler on stanli's gradient (`stanli::sample_nutpie()`), the route of
cogmod's `benchmarks/nutpieR/` (about 2x cmdstanr's ESS per second on a
small DDM-5). What it needs and why:

- **Libraries:** IllusionGameComputational's nutpie experiment,
  `/mnt/lustre/users/psych/dmm56/cogmod_nutpie/`: `R_libs` (brms 2.23.1,
  stanli 0.26.0, nutpieR 1.9.2) and `runtime_v0.26.0/libstanli.so`. It goes
  on `IGSA_R_LIBS` after the cogmod 0.3.6 library, so this run uses brms
  2.23.1, not 2.21.0.
- **One core per chain.** stanli does not thread this program: `reduce_sum`
  falls back on `OP_SET_INDEX_INPLACE`. The cause (found 2026-11-17, still
  there in 0.27.0) is the drift's 12 participant terms. When brms's loop adds
  more than 10 group-level terms per observation, stanli leaves its fast path:
  the gradient is ~25x slower on a gaussian model with 11 terms than with 10,
  and it cannot be threaded. Splitting that loop into two loops of 6 terms (the
  same sum) restores both. On a 24-participant subset of this DDM-5 it took
  the gradient from 38 to 25.5 ms on one thread, and to 16.4 ms with 4 threads.
  The running nutpie job (11757991) does not do this. An issue for stanli is
  drafted.
- **A stanli bug, patched in `fit_model.R`:** 0.26.0's `bridgestan_data()`
  cuts the data JSON at a million characters (`substring()`'s default
  `last`), so any real data set fails to open ("embedded __stanli manifest:
  parse error"). The job patches that one call in stanli's namespace and
  validates the JSON before sampling. 0.27.0 builds the JSON in C and is
  fixed (checked on a 2.1-million-character data set); there the patch finds
  nothing to change.
- **Its own models directory**, so its shards never meet cmdstanr's
  (`combine_model.R` refuses mixed samplers anyway).

```bash
export MSYS_NO_PATHCONV=1 IGSA_COGMOD_MIN=0.3.6 IGSA_BACKEND=nutpie \
  IGSA_MODELS_DIR=/mnt/lustre/users/psych/dmm56/IGSelfAssociation/models_nutpie \
  IGSA_STANLI_LIB=/mnt/lustre/users/psych/dmm56/cogmod_nutpie/R_libs \
  IGSA_STANLI_RUNTIME=/mnt/lustre/users/psych/dmm56/cogmod_nutpie/runtime_v0.26.0/libstanli.so \
  IGSA_R_LIBS=/mnt/lustre/users/psych/dmm56/IGSelfAssociation/R_libs_cogmod_0.3.6:/mnt/lustre/users/psych/dmm56/cogmod_nutpie/R_libs:/mnt/lustre/users/psych/dmm56/cluster_R_libs/x86_64-pc-linux-gnu-library/4.3
./hpc fit ddm5 --partition=verylong --cpus-per-task=2 --mem=16G
```

`./hpc progress ddm5` reads nutpie's progress lines too. nutpie reports
warmup and sampling as one time per chain.

## Local test

`fit_model.R` runs on a laptop too, from this folder, with cogmod >= 0.3.5:

```bash
IGSA_DATA=../../data/data_illusiongame.csv IGSA_MODELS_DIR=../models/smoke \
IGSA_NPARTICIPANTS=24 IGSA_WARMUP=300 IGSA_SAMPLES=200 \
SLURM_CPUS_PER_TASK=8 Rscript fit_model.R
```

For stanli, add `IGSA_BACKEND=stanli` and `IGSA_STANLI_LIB`, the library
holding it (`"$(Rscript -e 'cat(dirname(find.package("stanli")))')"`). A
stanli toy run went through on 2026-11-03: sampling, the saved shard,
`combine_model.R` and `marginals.R`. It used 3 participants, 10 warmup + 6
draws, and the laptop's stanli 0.23.2.

## After the fit

```r
source("models.R"); source("marginals.R")
m <- readRDS("../models/lnr.rds")
grid <- igsa_grid(m)
d <- igsa_draws(m, grid)
igsa_summary(d, grid, what = c("perror", "delta", "speed", "ndt"))      # per group and condition
s <- igsa_slopes(d, grid)                                               # illusion sensitivity
igsa_summary(igsa_contrasts(s), what = c("delta", "perror"))            # Past/Recent vs Never
design <- igsa_design_grid(m)                                           # every point the task showed
igsa_summary(igsa_contrasts(igsa_average(igsa_draws(m, design), design)))  # averaged over the design
g4 <- igsa_grid(m, strength = c(0, 1), difficulty = c(0, 1))
igsa_summary(igsa_index(igsa_draws(m, g4), g4))                         # illusion magnitude per group
```

The reports are `analysis/3_lnr_groups.qmd` (population level) and
`analysis/4_lnr_correlates.qmd` (participant level). For the parameters
themselves, `modelbased::estimate_contrasts()` and `estimate_slopes()` work
on the fit directly, with `predict` naming the distributional parameter,
`newdata = design` and `re_formula = NA`; `marginals.R`'s header shows the
calls, and the report checks them against the per-draw path.

Fits from the cluster's brms 2.21.0 predict correctly with a newer local brms.
IllusionGameComputational's mispredictions came from rebuilt `t2()` bases,
and this model has none.
