#!/bin/bash
#SBATCH --job-name=pack_N100
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem-per-cpu=6G
#SBATCH --time=24:00:00

set -euo pipefail
mkdir -p logs csv img

# module load gcc

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_PROC_BIND=close
export OMP_PLACES=cores

gcc -O3 -march=native -fopenmp -std=c11 -Wall -Wextra -pedantic \
  sa_pack_shrink_poly_hpc_fastcount.c \
  -o sa_pack_shrink_poly_hpc_fastcount -lm

# Example run
srun ./sa_pack_shrink_poly_hpc_fastcount 100 123456 \
  --threads 48 \
  --checkpoint_every 600 \
  --time_limit 86000
