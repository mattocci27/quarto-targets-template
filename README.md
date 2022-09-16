[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

**Disclaimer: This is not a minimal example.**

# Template for a reproducible R project with Quarto and {targets}

This is an example of a [`{targets}`](https://github.com/ropensci/targets) workflow that runs Bayesian analyses and rendering a manuscript using [`Quarto`](https://quarto.org/).
[`R/functions.R`]() contains some utility functions that are often used in my workflow.
[`ms/manuscript.qmd`]() contains examples of cross-referencing and parameterized texts.

## Requirements for running this demo

Option 1: running on local

- [R (>= 4.0.0)](https://cran.rstudio.com/)
- [Quarto](https://quarto.org/): An open-source scientific and technical publishing system built on Pandoc
- [cmdstan](https://mc-stan.org/users/interfaces/cmdstan): The shell interface to Stan
- [TinyTeX](https://yihui.org/tinytex/): A lightweight, cross-platform, portable, and easy-to-maintain LaTeX distribution based on TeX Live

- [`renv`](https://rstudio.github.io/renv/): A dependency management toolkit for R

Option 2: running on an Apptainer/Singularity container (Linux only)

-	[Apptainer/Singularity](http://apptainer.org/): the container system for secure high performance computing

## Usage

### Running code on local

To run analysis:

```
# To install R packages for the first run
# Rscript -e "renv::restore()"

run Rscript
```

To generate the manuscript:

```
make
```

Currently, it is easier to separate `Quarto` rendering from a `{targets}` workflow.
See [Quarto targets - indicate code chunk that causes error #99
](https://github.com/ropensci/tarchetypes/issues/99)

### Running code in Apptainer (Linux)

To build Apptainer containers:

```bash
sudo apptainer build radian.sif radian.def
```

```bash
apptainer exec --env RENV_PATHS_CACHE=/home/${USER}/renv \
	--env RENV_PATHS_PREFIX_AUTO=TRUE \
	radian.sif Rscript -e "renv::restore()"
```

To run analysis:

```bash
apptainer exec --env RENV_PATHS_CACHE=/home/${USER}/renv \
	--env RENV_PATHS_PREFIX_AUTO=TRUE \
	radian.sif Rscript run.R
```

`.Renviron` is ignored in git.
It is useful to add the following information to `.Renviron` to use `{renv}` caches on Linux.

```
#renv settings
RENV_PATHS_PREFIX_AUTO=TRUE
RENV_PATHS_CACHE=/home/${USER}/renv
```

## Optional

You can also generate Rd files under `man/` by running `roxygen2::roxygenise()`.

# Links

- [ulyngs/oxforddown](https://github.com/ulyngs/oxforddown)

- [wlandau/stantargets-example-validation](https://github.com/wlandau/stantargets-example-validation)

- [robertdj/renv-docker](https://github.com/robertdj/renv-docker)

- [Pakillo/template](https://github.com/Pakillo/template)

- [eveyp/renv_and_singularity.md](https://gist.github.com/eveyp/07b54986a2218d9ebb6085bb84f04cd1)

- [The {targets} R package user manual](https://books.ropensci.org/targets/)

- [Diagnosing Biased Inference with Divergences](https://betanalpha.github.io/assets/case_studies/divergences_and_bias.html)
