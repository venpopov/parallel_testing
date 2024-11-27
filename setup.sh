#!/bin/bash
# Initializes the SLURM environment if running inside a SLURM job.
# Detects SLURM environment and conditionally sets up modules and environments.

# Check if running inside a SLURM environment
if [[ -n $SLURM_JOB_ID ]]; then
    echo "Detected SLURM environment. Loading modules..."
    if ! module load mamba; then
        echo "Error: Failed to load mamba module." >&2
        exit 1
    fi

    if conda env list | grep -q "^r-4.4.2"; then
        source activate r-4.4.2
    else
        echo "Error: Environment r-4.4.2 not found." >&2
        exit 1
    fi
else
    echo "Not in SLURM environment. Skipping module and environment setup."
fi
