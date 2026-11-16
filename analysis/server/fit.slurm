#!/bin/bash
#SBATCH --job-name=igsa_fit
#SBATCH --array=1-4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=16G
#SBATCH --partition=long
#SBATCH --output=fit_%A_%a.out
#SBATCH --error=fit_%A_%a.err
#SBATCH --mail-type=END,FAIL

# One array task = one shard of one model (IGSA_MODEL) = 2 chains x 8 threads.
# 4 tasks x 16 CPUs = 64 CPUs of long's 140-CPU per-user cap. No --time: each
# task gets long's 8-day maximum, and a task killed at the wall loses its
# chains. The data are ~56k rows (IllusionGameComputational's LNR: ~6.5 GB
# per chain at 324k), hence 16G; the run time is not measured yet -- the
# smoke test in README.md is what tells.
#
# --job-name/--array/--output/--error/--mail-user/--chdir and the IGSA_*
# variables are all overridden on the sbatch command line by `./hpc fit`, so
# nothing here is hard-coded to one account. Submitting this file by hand still
# works: it then falls back to the directory it was submitted from.

PROJECT_DIR="${IGSA_USERS_DIR:-$SLURM_SUBMIT_DIR}"
export IGSA_MODELS_DIR="${IGSA_MODELS_DIR:-$PROJECT_DIR/models}"

cd "$PROJECT_DIR" || exit 1
mkdir -p "$IGSA_MODELS_DIR"

echo "Running on $(hostname)"
echo "Model: ${IGSA_MODEL:-<unset>}  shard: ${SLURM_ARRAY_TASK_ID:-1}"
echo "Models directory: $IGSA_MODELS_DIR"
echo "Job started at: $(date '+%Y-%m-%d %H:%M:%S')"

# SLURM runs this non-interactively, where 'module' is not yet a function.
[ -n "${LMOD_CMD:-}" ] || [ ! -f /etc/profile.d/lmod.sh ] || . /etc/profile.d/lmod.sh

# Compute nodes only get /opt/ohpc/pub/modulefiles; the EasyBuild tree that
# actually holds R/CmdStanR is on the login node's MODULEPATH only.
module use "${IGSA_EB_MODULES:-/mnt/shared/easybuild/modules/all}"
module load "${IGSA_R_MODULE:-CmdStanR/0.7.1-foss-2023a-R-4.3.2}"

# Project library holds what the module doesn't ship (cogmod, a newer
# cmdstanr); it precedes the module on R_LIBS and so shadows it.
if [ -n "${IGSA_R_LIBS:-}" ]; then
  export R_LIBS="${IGSA_R_LIBS}${R_LIBS:+:$R_LIBS}"
fi

# brms 2.21.0 is in neither: the module's 2.20.4 writes int[] arrays, which
# CmdStan >= 2.33 rejects. It comes from a shared library on R_LIBS_USER
# (lab hub, toolchain.md "The brms trap"). R searches it after R_LIBS and
# before the module's R_LIBS_SITE.
export R_LIBS_USER="${IGSA_R_LIBS_USER:-/research/cisc2/shared/cluster_R_libs/x86_64-pc-linux-gnu-library/4.2/}"

echo "Rscript: $(command -v Rscript)"
Rscript -e 'cat("brms", format(packageVersion("brms")), "from", find.package("brms"), "\n")'

# Propagate R's exit status. Without this the trailing echo below makes every
# task report COMPLETED/0:0 even when Rscript died, which hides failures in
# sacct. Do not add a command after Rscript without preserving $?.
Rscript fit_model.R
status=$?

echo "FINISHED at: $(date '+%Y-%m-%d %H:%M:%S') with status $status"
exit $status
