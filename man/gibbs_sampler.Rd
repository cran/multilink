% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gibbs_sampler.R
\name{gibbs_sampler}
\alias{gibbs_sampler}
\title{Gibbs Sampler for Posterior Inference}
\usage{
gibbs_sampler(
  comparison_list,
  prior_list,
  n_iter = 2000,
  Z_init = 1:sum(comparison_list$file_sizes),
  seed = 70,
  single_likelihood = FALSE,
  chaperones_info = NA,
  verbose = TRUE
)
}
\arguments{
\item{comparison_list}{The output from a call to
\code{\link{create_comparison_data}} or \code{\link{reduce_comparison_data}}.}

\item{prior_list}{The output from a call to \code{\link{specify_prior}}.}

\item{n_iter}{The number of iterations of the Gibbs sampler to run.}

\item{Z_init}{Initialization of the partition of records, represented as an
\code{integer} vector of arbitrary labels of length
\code{sum(comparison_list$file_sizes)}. The default initialization places
each record in its own cluster. See \code{\link{initialize_partition}} for an
alternative initialization when there are no duplicates in each file.}

\item{seed}{The seed to use while running the Gibbs sampler.}

\item{single_likelihood}{A \code{logical} indicator of whether to use a
single likelihood for comparisons for all file pairs, or whether to use a
separate likelihood for comparisons for each file pair. When
\code{single_likelihood=TRUE}, a single likelihood is used, and the prior
hyperparameters for \code{m} and \code{u} from the first file pair are used.
We do not recommend using a single likelihood in general.}

\item{chaperones_info}{If \code{chaperones_info} is set to \code{NA}, then
Gibbs updates to the partition are used during the Gibbs sampler, as
described in Aleshin-Guendel & Sadinle (2022). Else, Chaperones updates,
as described in Miller et al. (2015) and Betancourt et al. (2016), are used
and \code{chaperones_info} should be a \code{list} with five elements
controlling Chaperones updates to the partition during the Gibbs sampler:
\code{chap_type}, \code{num_chap_iter}, \code{nonuniform_chap_type},
\code{extra_gibbs}, \code{num_restrict}. \code{chap_type} is \code{0} if
using a uniform Chaperones distribution, and \code{1} if
using a nonuniform Chaperones distribution. \code{num_chap_iter} is the
number of Chaperones updates to the partition that are made during each
iteration of the Gibbs sampler. When using a nonuniform Chaperones
distribution, \code{nonuniform_chap_type} is \code{0} if using the exact
version, or \code{1} if using the partial version. \code{extra_gibbs} is a
\code{logical} indicator of whether a Gibbs update to the partition should be
done after the Chaperones updates, at each iteration of the Gibbs sampler.
\code{num_restrict} is the number of restricted Gibbs steps to take during
each Chaperones update to the partition.}

\item{verbose}{A \code{logical} indicator of whether progress messages should
be print (default \code{TRUE}).}
}
\value{
a list containing:
\describe{
  \item{\code{m}}{Posterior samples of the \code{m} parameters. Each column
  is one sample.}
  \item{\code{u}}{Posterior samples of the \code{u} parameters. Each column
  is one sample.}
  \item{\code{partitions}}{Posterior samples of the partition. Each column
  is one sample. Note that the partition is represented as an \code{integer}
  vector of arbitrary labels of length
  \code{sum(comparison_list$file_sizes)}.}
  \item{\code{contingency_tables}}{Posterior samples of the overlap table.
  Each column is one sample. This incorporates counts of records determined
  not to be candidate matches to any other records using
  \code{\link{reduce_comparison_data}}.}
  \item{\code{cluster_sizes}}{Posterior samples of the size of each cluster
  (associated with an arbitrary label from \code{1} to
  \code{sum(comparison_list$file_sizes)}). Each column is one sample.}
  \item{\code{sampling_time}}{The time in seconds it took to run the
  sampler.}
}
}
\description{
Run a Gibbs sampler to explore the posterior distribution of partitions of
records.
}
\details{
Given the prior specified using \code{\link{specify_prior}}, this function
runs a Gibbs sampler to explore the posterior distribution of partitions of
records, conditional on the comparison data created using
\code{\link{create_comparison_data}} or \code{\link{reduce_comparison_data}}.
}
\examples{
# Example with small no duplicate dataset
data(no_dup_data_small)

# Create the comparison data
comparison_list <- create_comparison_data(no_dup_data_small$records,
 types = c("bi", "lv", "lv", "lv", "lv", "bi", "bi"),
 breaks = list(NA,  c(0, 0.25, 0.5),  c(0, 0.25, 0.5),
               c(0, 0.25, 0.5), c(0, 0.25, 0.5),  NA, NA),
 file_sizes = no_dup_data_small$file_sizes,
 duplicates = c(0, 0, 0))

# Specify the prior
prior_list <- specify_prior(comparison_list, mus = NA, nus = NA, flat = 0,
 alphas = rep(1, 7), dup_upper_bound = c(1, 1, 1),
 dup_count_prior_family = NA, dup_count_prior_pars = NA,
 n_prior_family = "uniform", n_prior_pars = NA)

# Find initialization for the matching (this step is optional)
# The following line corresponds to only keeping pairs of records as
# potential matches in the initialization for which neither gname nor fname
# disagree at the highest level
pairs_to_keep <- (comparison_list$comparisons[, "gname_DL_3"] != TRUE) &
 (comparison_list$comparisons[, "fname_DL_3"] != TRUE)
Z_init <- initialize_partition(comparison_list, pairs_to_keep, seed = 42)

# Run the Gibbs sampler
{
results <- gibbs_sampler(comparison_list, prior_list, n_iter = 1000,
 Z_init = Z_init, seed = 42)
}

# Example with small duplicate dataset
data(dup_data_small)

# Create the comparison data
comparison_list <- create_comparison_data(dup_data_small$records,
 types = c("bi", "lv", "lv", "lv", "lv", "bi", "bi"),
 breaks = list(NA,  c(0, 0.25, 0.5),  c(0, 0.25, 0.5),
               c(0, 0.25, 0.5), c(0, 0.25, 0.5),  NA, NA),
 file_sizes = dup_data_small$file_sizes,
 duplicates = c(1, 1, 1))

# Reduce the comparison data
# The following line corresponds to only keeping pairs of records for which
# neither gname nor fname disagree at the highest level
pairs_to_keep <- (comparison_list$comparisons[, "gname_DL_3"] != TRUE) &
 (comparison_list$comparisons[, "fname_DL_3"] != TRUE)
reduced_comparison_list <- reduce_comparison_data(comparison_list,
 pairs_to_keep, cc = 1)

# Specify the prior
prior_list <- specify_prior(reduced_comparison_list, mus = NA, nus = NA,
 flat = 0, alphas = rep(1, 7), dup_upper_bound = c(10, 10, 10),
 dup_count_prior_family = c("Poisson", "Poisson", "Poisson"),
 dup_count_prior_pars = list(c(1), c(1), c(1)), n_prior_family = "uniform",
 n_prior_pars = NA)

# Run the Gibbs sampler
{
results <- gibbs_sampler(reduced_comparison_list, prior_list, n_iter = 1000,
 seed = 42)
}
}
\references{
Serge Aleshin-Guendel & Mauricio Sadinle (2022). Multifile Partitioning for Record Linkage and Duplicate Detection. \emph{Journal of the
American Statistical Association}. [\doi{https://doi.org/10.1080/01621459.2021.2013242}][\href{https://arxiv.org/abs/2110.03839}{arXiv}]

Jeffrey Miller, Brenda Betancourt, Abbas Zaidi, Hanna Wallach, & Rebecca C. Steorts (2015).
Microclustering: When the cluster sizes grow sublinearly with the size of the data set.
\emph{NeurIPS Bayesian Nonparametrics: The Next Generation Workshop Series}. [\href{https://arxiv.org/abs/1512.00792}{arXiv}]

Brenda Betancourt, Giacomo Zanella, Jeffrey Miller, Hanna Wallach, Abbas Zaidi, & Rebecca C. Steorts (2016).
Flexible Models for Microclustering with Application to Entity Resolution.
\emph{Advances in neural information processing systems}. [\href{https://proceedings.neurips.cc/paper/2016/hash/670e8a43b246801ca1eaca97b3e19189-Abstract.html}{Published}] [\href{https://arxiv.org/abs/1610.09780}{arXiv}]
}
