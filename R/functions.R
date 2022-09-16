#' @title ggsave for targets
#' @inheritParams ggplot2::ggsave
my_ggsave <- function(filename, plot, units = c("in", "cm",
        "mm", "px"), height = NA, width = NA, dpi = 300, ...) {
  ggsave(
    filename = paste0(filename, ".png"),
    plot = plot,
    height = height,
    width = width,
    units = units,
    dpi = dpi,
    ...
  )
  ggsave(
    filename = paste0(filename, ".pdf"),
    plot = plot,
    height = height,
    width = width,
    units = units,
    dpi = dpi,
    ...
  )
  str_c(filename, c(".png", ".pdf"))
}

#' @title write_csv for targets
#' @inheritParams readr::write_csv
my_write_csv <- function(x, path, append = FALSE, col_names = !append) {
    write_csv(x, path, append = FALSE, col_names = !append)
    paste(path)
}

#' @title Get posterior estimates mcmc summary
#' @param data data frame, summary of mcmc
#' @param row variable name (e.g., "theta")
#' @param col summary name (e.g., "mean", "q50")
#' @param digits integer indicating the number of decimal places
#' @param nsmall the minimum number of digits to the right of the decimal point
get_post_para <- function(data, row, col, digits = 2, nsmall = 2) {
  data |>
    mutate_if(is.numeric, \(x) round(x, digits = digits)) |>
    mutate_if(is.numeric, \(x) format(x, nsmall = nsmall)) |>
    filter(variable == {{row}}) |>
    pull({{col}})
}

#' @title Simulate data from the model.
#' @param tau tau parameter for the model.
simulate_schools_data <- function(tau = 5) {
  list(
    J = 8,
    y = c(28, 8, -3, 7, -1, 1, 18, 12),
    sigma = c(15, 10, 16, 11, 9, 11, 10, 18),
    tau = tau
    )
}

#' @title Fit the Stan model
#' @return dataframe of cmdstan customized summary with diagnostics
#' @param data list, a single simulated dataset.
#' @param model_file Path to the Stan model source file.
#' @references https://github.com/wlandau/targets-stan
fit_sim_model <- function(data, model_file,
                            iter_warmup = 1,
                            iter_sampling = 1,
                            adapt_delta = 0.9,
                            max_treedepth = 15,
                            chains = 4,
                            parallel_chains = 1,
                            refresh = 0,
                            seed = 123) {
  model <- cmdstan_model(model_file)
  fit <- model$sample(
    data = data,
    seed = seed,
    iter_warmup = iter_warmup,
    iter_sampling = iter_sampling,
    adapt_delta = adapt_delta,
    max_treedepth = max_treedepth,
    chains = chains,
    parallel_chains = parallel_chains,
    refresh = refresh)

  summary_ <- posterior::summarise_draws(fit,
    mean = ~mean(.x),
    sd = ~sd(.x),
    mad = ~mad(.x),
    ~posterior::quantile2(.x, probs = c(0.025, 0.05, 0.25, 0.5, 0.75, 0.95, 0.975)),
    posterior::default_convergence_measures())

  diagnostic_summary_ <- fit$diagnostic_summary()
  summary_ |>
    mutate(num_divergent = sum(diagnostic_summary_$num_divergent)) |>
    mutate(num_max_treedepth = sum(diagnostic_summary_$num_max_treedepth)) |>
    mutate(data_id = targets::tar_name()) |>
    mutate(tau = data$tau)
}

#' @title Compile a Stan model and return a path to the compiled model output.
#' @description We return the paths to the Stan model specification
#'   and the compiled model file so `targets` can treat them as
#'   dynamic files and compile the model if either file changes.
#' @return Path to the compiled Stan model, which is just an RDS file.
#'   To run the model, you can read this file into a new R session with
#'   `readRDS()` and feed it to the `object` argument of `sampling()`.
#' @param model_file Path to a Stan model file.
#'   This is a text file with the model spceification.
#' @references https://github.com/wlandau/targets-stan
#' @examples
#' library(cmdstanr)
#' compile_model("stan/model.stan")
compile_model <- function(model_file) {
  quiet(cmdstan_model(model_file))
  model_file
}

#' @title Suppress output and messages for code.
#' @description Used in the pipeline.
#' @return The result of running the code.
#' @param code Code to run quietly.
#' @references https://github.com/wlandau/targets-stan
#' @examples
#' library(cmdstanr)
#' library(tidyverse)
#' compile_model("stan/model.stan")
#' quiet(fit_model("stan/model.stan", simulate_data_discrete()))
#' out
quiet <- function(code) {
  sink(nullfile())
  on.exit(sink())
  suppressMessages(code)
}


theta_tau_line <- function(sim_fit) {
  theta <- sim_fit |>
    filter(str_detect(variable, "theta")) |>
    filter(!str_detect(variable, "_")) |>
    mutate(school = rep(LETTERS[1:8], 20))

  school_lab <- theta[97:104, ]

  ggplot(theta, aes(x = tau, y = mean)) +
    geom_line(aes(group = school)) +
    geom_text_repel(data = school_lab, aes(y = mean, label = school)) +
    ylab("Estiamted Treatment Effects") +
    theme_bw()
}

