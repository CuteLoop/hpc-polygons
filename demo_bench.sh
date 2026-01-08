#!/usr/bin/env bash
set -euo pipefail

SRC="sa_pack_shrink_poly_hpc_fastcount.c"
BIN="./sa_pack_shrink_poly_hpc_fastcount"

THREADS="${1:-48}"          # ./bench_2_30.sh 48
REPS="${2:-3}"              # ./bench_2_30.sh 48 5
N_MIN="${3:-2}"
N_MAX="${4:-30}"

mkdir -p bench csv img

echo "[build] compiling..."
gcc -O3 -march=native -fopenmp -std=c11 -Wall -Wextra -pedantic "$SRC" -o "$BIN" -lm

TIMINGS="bench/timings_2_30.csv"
echo "N,rep,threads,seconds,seed" > "$TIMINGS"

BASE_SEED=1234567

run_one () {
  local N="$1"
  local rep="$2"
  local seed=$((BASE_SEED + 100000*N + rep))

  local outdir="bench/run_N${N}_rep${rep}"
  mkdir -p "$outdir"

  local tfile="${outdir}/time.txt"

  /usr/bin/time -f "%e" -o "$tfile" \
    "$BIN" "$N" "$seed" --demo --no_polish --threads "$THREADS" \
    > "${outdir}/stdout.log" 2> "${outdir}/stderr.log"

  local sec
  sec="$(cat "$tfile")"
  echo "${N},${rep},${THREADS},${sec},${seed}" >> "$TIMINGS"
  printf "[done] N=%02d rep=%d sec=%s\n" "$N" "$rep" "$sec"
}

echo "[run] N=${N_MIN}..${N_MAX} reps=${REPS} threads=${THREADS}"
for N in $(seq "$N_MIN" "$N_MAX"); do
  for rep in $(seq 1 "$REPS"); do
    run_one "$N" "$rep"
  done
done

echo "[plot] generating plots..."
python3 bench_plot_2_30.py "$TIMINGS" "bench/timings_mean.png" "bench/timings_loglog.png"

echo
echo "Wrote:"
echo "  - $TIMINGS"
echo "  - bench/timings_mean.png"
echo "  - bench/timings_loglog.png"
