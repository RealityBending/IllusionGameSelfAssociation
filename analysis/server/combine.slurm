#!/bin/bash
#SBATCH --job-name=igsa_combine
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --partition=general
#SBATCH --output=combine_%j.out
#SBATCH --error=combine_%j.err
#SBATCH --mail-type=END,FAIL

# One job = one model (IGSA_MODEL): merge its shards, keep the shards. Not an
# array. 32G holds four shards and the merged fit. With IGSA_CRITERION=loo,
# log_lik() is draws x rows (8,000 x ~56k = 3.6 GB) and loo holds several of
# those at once: give it --mem=96G. No --time: general's 8 h maximum.

PROJECT_DIR="${IGSA_USERS_DIR:-$SLURM_SUBMIT_DIR}"
export IGSA_MODELS_DIR="${IGSA_MODELS_DIR:-$PROJECT_DIR/models}"

cd "$PROJECT_DIR" || exit 1
mkdir -p "$IGSA_MODELS_DIR/combined"

echo "Running on $(hostname)"
echo "Model: ${IGSA_MODEL:-<unset>}"
echo "Models directory: $IGSA_MODELS_DIR"
echo "Job started at: $(date '+%Y-%m-%d %H:%M:%S')"

[ -n "${LMOD_CMD:-}" ] || [ ! -f /etc/profile.d/lmod.sh ] || . /etc/profile.d/lmod.sh
module use "${IGSA_EB_MODULES:-/mnt/shared/easybuild/modules/all}"
module load "${IGSA_R_MODULE:-CmdStanR/0.7.1-foss-2023a-R-4.3.2}"

if [ -n "${IGSA_R_LIBS:-}" ]; then
  export R_LIBS="${IGSA_R_LIBS}${R_LIBS:+:$R_LIBS}"
fi
export R_LIBS_USER="${IGSA_R_LIBS_USER:-/research/cisc2/shared/cluster_R_libs/x86_64-pc-linux-gnu-library/4.2/}"

echo "Rscript: $(command -v Rscript)"

Rscript combine_model.R
status=$?

echo "FINISHED at: $(date '+%Y-%m-%d %H:%M:%S') with status $status"
exit $status
