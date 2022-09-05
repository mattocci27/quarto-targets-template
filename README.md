# Template for R project with Quarto and {targets}

This is an example of a [`{targets}`](https://github.com/ropensci/targets) workflow that runs Bayesian analyses and rendering a manuscript using [`Quarto`](https://quarto.org/).
`R/functions.R` and `_targets.R` contain some utility functions and R packages that are often used in my workflow.

## Usage

### Running code on local

To run analysis:

```
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

To run analysis:

```bash
apptainer exec --env RENV_PATHS_CACHE=/home/${USER}/renv \
	--env RENV_PATHS_PREFIX_AUTO=TRUE \
	radian.sif Rscript run.R
```

`.Renviron` is ignored in git.
It is useful to add the following information to `.Renviron` to use `{renv}` caches on Linux (`{renv}` is not initialized in this repo though).

```
#renv settings
RENV_PATHS_PREFIX_AUTO=TRUE
RENV_PATHS_CACHE=/home/${USER}/renv
```

# References

- [ulyngs/oxforddown](https://github.com/ulyngs/oxforddown)

- [wlandau/stantargets-example-validation](https://github.com/wlandau/stantargets-example-validation)

- [robertdj/renv-docker](https://github.com/robertdj/renv-docker)

- [eveyp/renv_and_singularity.md](https://gist.github.com/eveyp/07b54986a2218d9ebb6085bb84f04cd1)

- [The {targets} R package user manual](https://books.ropensci.org/targets/)

- [Diagnosing Biased Inference with Divergences](https://betanalpha.github.io/assets/case_studies/divergences_and_bias.html)
