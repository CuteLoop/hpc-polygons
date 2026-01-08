#!/bin/bash
#SBATCH --job-name=pack_bench
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem-per-cpu=6G
#SBATCH --time=02:00:00

set -euo pipefail
mkdir -p logs bench csv img

# Load compiler if needed:
# module purge
# module load gcc

# OpenMP controls (good defaults)
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_PROC_BIND=close
export OMP_PLACES=cores

# Build
gcc -O3 -march=native -fopenmp -std=c11 -Wall -Wextra -pedantic \
  sa_pack_shrink_poly_hpc_fastcount.c \
  -o sa_pack_shrink_poly_hpc_fastcount -lm

# Run benchmark script (uses --threads)
chmod +x bench_2_30.sh
./bench_2_30.sh 48 3 2 30
