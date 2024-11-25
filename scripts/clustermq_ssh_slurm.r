# The script is used to run the simulation study in parallel on a local machine using the multiprocess scheduler
# This is a toy example testing the `clustermq` package with the `multiprocess` scheduler

library(clustermq)
options(clustermq.scheduler = "slurm")

# grid of parameters to iterate over
pars <- expand.grid(
  n = c(20, 50),
  kappa = seq(1, 16, 2),
  p_mem = seq(0.6, 1, 0.1)
)

# function to recover the parameters of the mixture model
recover_mixture2p <- function(n, kappa, p_mem) {
  transform_for_mixtur <- function(error) {
    data.frame(response = error, target = 0, id = 1)
  }

  suppressMessages(
    bmm::rmixture2p(n, kappa = kappa, p_mem = p_mem) |>
      transform_for_mixtur() |>
      mixtur::fit_mixtur(model = "2_component", unit = "radians") |>
      select(kappa, p_t) |>
      rename(kappa_est = kappa, p_mem_est = p_t) |>
      mutate(n = n, kappa = kappa, p_mem = p_mem)
  )
}

# run the simulation study in parallel on 10 cores
Q(fun = recover_mixture2p,
  n = pars$n, 
  kappa = pars$kappa, 
  p_mem = pars$p_mem,
  pkgs = c("dplyr"),
  n_jobs = 10
)
