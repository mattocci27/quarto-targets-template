library(targets)
library(tarchetypes)
library(tidyverse)
library(stantargets)
library(cmdstanr)
library(furrr)
library(bayesplot)

source("R/functions.R")

# parallel computing on local or on the same node
plan(multicore)
options(clustermq.scheduler = "multicore")

tar_option_set(packages = c(
  "tidyverse",
  "bayesplot",
  "ggrepel",
  "patchwork",
  "janitor",
  "loo"
))

# keep memory usage down to a minimum
tar_option_set(
  garbage_collection = TRUE,
  memory = "transient"
)

# check if it's inside a container
if (file.exists("/.dockerenv") | file.exists("/.singularity.d/startscript")) {
  Sys.setenv(CMDSTAN = "/opt/cmdstan/cmdstan-2.29.2")
  set_cmdstan_path("/opt/cmdstan/cmdstan-2.29.2")
}

cmdstan_version()

list(
  # eight schools
  tar_target(
    schools_data,
    list(
      J = 8,
      y = c(28, 8, -3, 7, -1, 1, 18, 12),
      sigma = c(15, 10, 16, 11, 9, 11, 10, 18))
  ),
  # fit a single stan model
  tar_stan_mcmc(
    fit,
    "stan/model.stan",
    data = schools_data,
    refresh = 0,
    chains = 4,
    parallel_chains = getOption("mc.cores", 4),
    iter_warmup = 2000,
    iter_sampling = 2000,
    adapt_delta = 0.9,
    max_treedepth = 15,
    seed = 123,
    return_draws = TRUE,
    return_diagnostics = TRUE,
    return_summary = TRUE,
    summaries = list(
      mean = ~mean(.x),
      sd = ~sd(.x),
      mad = ~mad(.x),
      ~posterior::quantile2(.x, probs = c(0.025, 0.05, 0.25, 0.5, 0.75, 0.95, 0.975)),
      posterior::default_convergence_measures()
    )
  ),
  # prepare different tau values to pass dynamic branches
  tar_target(
    sim_tau,
    seq(0.01, 40, length = 20)
  ),
  # schools data with different tau values (dynamic branches)
  tar_target(
    simulated_schools_data,
    simulate_schools_data(sim_tau),
    pattern = map(sim_tau)
  ),
  # compile stan model so that targets can track
  tar_target(
    simulation_stan,
    compile_model("stan/simulation.stan"),
    format = "file"
  ),
  # fit stan model to each simulated data (dynamic branches)
  tar_target(
    sim_fit,
    fit_sim_model(
      data = simulated_schools_data,
      simulation_stan,
      refresh = 0,
      chains = 4,
      parallel_chains = 1,
      iter_warmup = 2000,
      iter_sampling = 2000,
      adapt_delta = 0.9,
      max_treedepth = 15,
      seed = 123),
    pattern = map(simulated_schools_data)
  ),
  # export summary csv
  tar_target(
    summary_csv,
    my_write_csv(fit_summary_model, "data/fit_summary_model.csv"),
    format = "file"
  ),
  # produce png and pdf figures
  tar_target(
    theta_tau_line_plot, {
      p <- theta_tau_line(sim_fit)
      my_ggsave(
        "figs/theta_tau_line",
        p,
        height = 3.5,
        width = 3.5
      )
    },
    format = "file"
  ),
  tar_target(
    theta_intervals_plot, {
      p <- mcmc_intervals(fit_draws_model, regex_pars = "theta\\[")
      my_ggsave(
        "figs/theta_intervals",
        p,
        height = 3.5,
        width = 3.5
      )
    },
    format = "file"
  ),

  # it's hard to debug quarto using targets at the moment

  # tar_quarto(
  #   manuscript_pdf,
  #   "ms/manuscript.qmd"
  # ),

  # putting NULL makes easy to remove tar_target from this list
  NULL
)
