library(crew)

ctrl <- crew_controller_local(workers = 12)
ctrl$start()

# grid of parameters to iterate over
pars <- expand.grid(
  n = c(20, 50, 100),
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
