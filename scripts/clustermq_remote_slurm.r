# This is a testing script to make sure I can get clustermq running on the UZH cluster.
# No extra packages used for simplicity

library(clustermq)

# grid of parameters to iterate over
pars <- expand.grid(
  n = c(20, 50),
  mean = runif(10, -10, 10),
  sd = runif(10, 0.5, 2)
)

# function to recover the parameters of the mixture model
parameter_recovery <- function(n, mean, sd) {
  ll <- function(x) {
    function(pars) {
      mean <- pars[1]
      sd <- exp(pars[2])
      -sum(dnorm(x, mean, sd, log = TRUE))
    }
  }

  fit <- optim(par = c(0, 0), fn = ll(rnorm(n, mean, sd)))
  data.frame(mean = fit$par[1], sd = exp(fit$par[2]))
}

# run the simulation study in parallel on 10 cores
res <- Q(fun = parameter_recovery,
  n = pars$n, 
  mean = pars$mean, 
  sd = pars$sd,
  n_jobs = 10
)

if (!dir.exists("output")) {
  dir.create("output")
}
saveRDS(do.call(rbind, res), "output/parameter_recovery.rds")
