library(crew)

# initialize the controller
ctrl <- crew_controller_local(workers = 4, seconds_idle = 5)

# start the controller. THis launches a single R process
ctrl$start()

# Use `push()` to submit a task to the controller
ctrl$push(name = "task 1", command = {
  Sys.sleep(5)
  ps::ps_pid()
  }) 
ctrl$push(name = "task 2", command = {
  Sys.sleep(5)
  ps::ps_pid()
  }) 
ctrl$push(name = "task 3", command = {
  Sys.sleep(5)
  ps::ps_pid()
  }) 
ctrl$push(name = "task 4", command = {
  Sys.sleep(5)
  ps::ps_pid()
  }) 
ctrl$push(name = "task 5", command = {
  Sys.sleep(5)
  ps::ps_pid()
  }) 

ctrl$wait(mode = "all")

res <- ctrl$collect()
res
res$result

ctr$summary()
