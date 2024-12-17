library(crew)
library(dplyr)

ctrl <- crew_controller_local(workers = 12, seconds_idle = 30)
ctrl$start()

# grid of parameters to iterate over
pars <- expand.grid(
  n = c(20, 50, 100),
  kappa = seq(1, 16, 0.2),
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


res <- ctrl$map(
  command = recover_mixture2p(n, kappa, p_mem),
  iterate = pars,
  packages = c('dplyr','bmm'),
  globals = list(recover_mixture2p = recover_mixture2p)
)

ctrl$terminate()

microbenchmark::microbenchmark(
  purrr::pmap_dfr(pars, recover_mixture2p),
  times = 10
)
