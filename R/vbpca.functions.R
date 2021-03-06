#' @title Regularized Variational Bayes Principal Compnent Analysis (vbpca). 
#'
#'
#' @aliases vbpca.default print.vbpca summary.vbpca is.vbpca print.summary.vbpca
#'
#'
#' @usage
#'
#' vbpca(X, D = 1, maxIter = 500, tolerance = 1e-05, verbose = FALSE, tau = 1,
#'      updatetau = FALSE, priorvar = 'invgamma', SVS = FALSE, priorInclusion = 0.5,
#'      global.var = FALSE, control = list(), suppressWarnings = FALSE)
#'
#' \method{vbpca}{default}(X, D = 1, maxIter = 500, tolerance = 1e-05, verbose = FALSE, tau = 1,
#'      updatetau = FALSE, priorvar = 'invgamma', SVS = FALSE, priorInclusion = 0.5,
#'      global.var = FALSE, control = list(), suppressWarnings = FALSE)
#'
#' \method{print}{vbpca}(x, ...)
#'
#' \method{summary}{vbpca}(object, ...)
#'
#' is.vbpca(object)
#'
#'
#' @description Estimation of regularized PCA with a Variational Bayes algorithm.
#'
#' @details
#' The function allows performing PCA decomposition of an \eqn{(I, J)} input matrix \eqn{X}.
#' For D principal components, the factorization occurs through:
#'
#' \deqn{ X = X W P^T + E }
#'
#' where \eqn{P} is the \eqn{(J, D)} orthogonal loading matrix (\eqn{P^T P = I}) and \eqn{W} is the
#' \eqn{(J, D)} weight matrix. E is an \eqn{(I, J)} residual matrix.
#' Principal components are defined by \eqn{X W}. In this context, focus of the inference is on the
#' weight matrix \eqn{W}. The Variational Bayes algorithm treats the elements
#' of \eqn{W} as latent variables; \eqn{P} and \code{sigma^2} (the variance of the residuals) are
#' fixed parameters instead.
#'
#' In order to regularize the elements of \eqn{W}, a Multivariate Normal (MVN) prior is assumed
#' for the columns of \eqn{W}. The multivariate normals have the  0-vector as mean, and diagonal
#' covariance matrix with variance \code{tau}. Different specifications of \code{tau} (either
#' fixed, updated via Type-II maximum likelihood, or random with Jeffrey's or Inverse Gamma priors)
#' allows achieving different levels of regularization on the elements of \eqn{W}. Furthermore,
#' \code{tau} can be updated with local information, or by sharing information with other elements
#' of the same components of the matrix \eqn{W} (\code{global.var = TRUE}). The latter option can be
#' useful when deciding how many components should be used during the estimation stage.
#' When Inverse Gamma priors are specified, its scale hyperparameter (\code{alphatau}) is regarded as fixed;
#' while its shape hyperparameter \code{betatau} can be fixed or random; in turn, a random
#' \code{betatau} can be updated with local, component-specific, or global hyperpriors.
#' See \code{\link{vbpca_control}} for further details on hyperparameter specification.
#'
#' When \code{SVS = TRUE}, a spike-and-slab priors allows for variable selection on the elements of
#' \eqn{W}. In particular, a mixture prior is imposed on the elements of W; \code{priorInclusion}
#' controls the proportions of such prior. Variables not included in the model are assumed to be
#' more likely to come from a Normal distributions with variance \code{tau} scaled by a factor
#' \code{v0} (see \code{\link{vbpca_control}} for the specification of the factor).
#' Similar to \code{tau}, \code{priorInclusion} can be fixed, or
#' or treated as a random variable with Beta priors. Furthermore, \code{priorInclusion} can
#' refer to prior probabilities  of the whole model (across all components) when specified as
#' a scalar, or to component-specific
#' prior probabilties when specified as a D-dimensional array.
#'
#'
#' @param X array_like; \cr
#'          a real \eqn{(I, J)} data matrix (or data frame) to be reduced.
#'
#' @param D integer; \cr
#'          the number of components to be computed.
#'
#' @param maxIter integer; \cr
#'                maximum number of variational algorithm iterations.
#'
#' @param tolerance float; \cr
#'                  stopping criterion for the variational algorithm
#'                  (relative differences between ELBO values).
#'
#' @param verbose bool; \cr
#'                logical value which indicates whether the estimation process
#'                information should be printed.
#'
#' @param tau float; \cr
#'            when \code{priorvar = 'fixed'}, the value to be used to fill the matrix of the
#' 			  prior precisions (inverse variances) of the elements \eqn{W}. 
#' 			  When \code{priorvar = 'invgamma'} or \code{priorvar = 'jeffrey'}, \code{tau} 
#' 			  is the starting value of the precisions
#'
#' @param updatetau bool; \cr
#'                  when \code{priorvar = 'fixed'}, it specifies whether the prior variances
#'                  of the elements of \eqn{W} should be updated via Type-II maximum likelihood.
#'
#' @param priorvar character; \cr
#'                 type of hyperprior for the prior variances of the elements in \eqn{W}:
#'                 no prior (\code{priorvar = 'fixed'}), Jeffrey's prior
#'                 (\code{priorvar = 'jeffrey'}), Inverse Gamma prior (\code{priorvar = 'invgamma'}).
#'                 See \code{\link{vbpca_control}} for the specification of the hyperparameters
#'                 of the Inverse Gamma distribution.
#'
#' @param SVS bool; \cr
#'        specifies whether Stochastic Variable Selection (a type of `spike-and-slab` prior)
#'        should be included in the computations of the Variational Bayes algorithm.
#'
#' @param priorInclusion float or array_like; \cr
#'                       in SVS, the prior inclusion probabilities; these can be fixed,
#'                       or random variables with Beta priors (see \code{\link{vbpca_control}}
#'                       for further information).
#'                       When not fixed, the value denotes the starting values
#'                       of the prior probabilities. The argument can be specified as a scalar, or as a
#'                       D-dimensional array, in which case the prior inclusion probabilities
#'                       will be regarded as component-specific.
#'
#' @param global.var bool; \cr
#'                   it specifies whether \code{tau} should be updated globally (component-specific
#'                   updates) or locally (element-specific updates).
#'
#' @param control list; \cr
#'                other control parameters. See \code{\link{vbpca_control}} for further details.
#'
#' @param suppressWarnings bool; \cr
#'                         boolean argument which hides function warnings when \code{TRUE}.
#'
#' @param x,object vbpca oject; \cr
#'                  an object of class \code{vbpca}, used as arguments for the \code{print}, \code{is.bayespca} and
#'                  \code{summary} functions.
#'
#' @param ... not used.
#'
#' @return a \code{vbpca} returns a `vbpca` object, which is a list containing the following elements:
#' \item{muW}{ array_like; \cr
#'        posterior means of the weight matrix; \eqn{(J, D)} dimensional array.
#' }
#'
#' \item{P}{ array_like; \cr
#'      point estimate of the (orthogonal) loading matrix; \eqn{(J, D)} dimensional array.
#' }
#'
#' \item{Tau}{ array_like; \cr
#'        the point estimates (or posterior means) of the inverse prior variances; depending on the
#'        specification of \code{tau}, it can be a D-dimensional vector or a \eqn{(J, D)} dimensional array.
#' }
#'
#' \item{sigma2}{ float; \cr
#'       point estimate of the variance of the residuals.
#' }
#'
#' \item{HPDI}{ list; \cr
#'       a list containing the high posterior density intervals of the elements of \eqn{W}.
#' }
#'
#' \item{priorAlpha}{ array_like; \cr
# a D-dimensional array (or a scalar) containing the values used for the shape hyperparameters of the
#'        Inverse Gamma priors.
#' }
#'
#' \item{priorBeta}{ array_like; \cr
#'       a \eqn{(J, D)} or \eqn{D} dimensional array (or a scalar), with the values used for the scale hyperparameters
#'       of the Inverse Gamma priors. When \code{betatau} is a random variable, its posterior means are returned.
#' }
#'
#' \item{priorInclusion}{ array_like; \cr
#'       scalar or \eqn{D} dimensional array containing the prior inclusion probabilities used (or estimated)
#'       by the model.
#' }
#'
#' \item{inclusionProbabilities}{ array_like; \cr
#'       an \eqn{(J, D)} dimensional array containing the estimated posterior inclusion probabilities
#'       of the elements of \eqn{W}.
#' }
#'
#' \item{elbo}{ float; \cr
#'       evidence lower bound of the model.
#' }
#'
#' \item{converged}{ bool; \cr
#'       boolean denoting whether the Variational Bayes algorithm converged within the required number of iterations.
#' }
#'
#' \item{time}{ array_like; \cr
#'       computation time of the algorithm.
#' }
#'
#' \item{priorvar}{ character; \cr
#'       type of prior variance specified as input by the user.
#' }
#'
#' \item{global.var}{ bool; \cr
#'       \code{global.var} specified as input by the user.
#' }
#'
#' \item{hypertype}{ character; \cr
#'       hyperprior type specified as input (in the \code{control} list) by the user.
#' }
#'
#' \item{SVS}{ bool; \cr
#'       boolean denoting whether stochastic variable selection was activated, as required by the user.
#' }
#'
#' \item{plot}{
#'       traceplot of the evidence lower bounds computed across the various iterations of the algorithm.
#' }
#'
#'
#'
#' @references
#' \itemize{
#'
#' \item [1] C. M. Bishop. 'Variational PCA'. In Proc. Ninth Int. Conf. on Artificial Neural Networks.
#' ICANN, 1999.
#'
#' \item [2] E. I. George, R. E. McCulloch (1993). 'Variable Selection via Gibbs Sampling'.
#' Journal of the American Statistical Association (88), 881-889.
#'
#'
#' }
#'
#' @author D. Vidotto <d.vidotto@@uvt.nl>
#'
#'
#' @seealso \code{\link{vbpca_control}}
#'
#'
#' @examples
#'
#' # Create a synthetic dataset
#' I <- 1e+3
#' X1 <- rnorm(I, 0, 50)
#' X2 <- rnorm(I, 0, 30)
#' X3 <- rnorm(I, 0, 10)
#'
#' X <- cbind(X1, X1, X1, X2, X2, X2, X3, X3 )
#' X <- X + matrix(rnorm(length(X), 0, 1), ncol = ncol(X), nrow = I )
#'
#' # Estimate the Bayesian PCA model, with Inverse Gamma priors for tau
#' # and SVS with Beta priors for priorInclusion
#' ctrl <- vbpca_control( alphatau = 1., betatau = 1e-2, beta1pi = 1., beta2pi = 1.  )
#' mod <- vbpca(X, D = 3, priorvar = 'invgamma', SVS = TRUE, control = ctrl )
#' summary(mod)
#' mod
#'
#'
#'
#'
#'


#' @export
vbpca <- function(X, D = 1, maxIter = 500, tolerance = 1e-05, verbose = FALSE, tau = 1, updatetau = FALSE, priorvar = "invgamma", SVS = FALSE, priorInclusion = 0.5, global.var = FALSE, 
    control = list(), suppressWarnings = FALSE) {
    
    UseMethod("vbpca")
    
}





#' @export
is.vbpca <- function(object) {
    
    class(object) == "vbpca"
    
}





#' @export
print.vbpca <- function(x, ...) {
    
    cat("Call:\n")
    print(x$call)
    cat("\n")
    cat("Final ELBO: ", x$elbo, "\n")
    cat("Elpsed time: ", x$time[[3]], "\n")
    
}



#' @export
summary.vbpca <- function(object, ...) {
    
    if (is.null(object) || class(object) != "vbpca") {
        stop("<object> must be a vbpca object.")
    }
    
    retSum <- c(list(call = object$call), object[1:16])
    
    class(retSum) <- "summary.vbpca"
    
    retSum
    
}


#' @export
print.summary.vbpca <- function(x, ...) {
    
    cat("Converged: ", x$converged, "\n")
    cat("ELBO: ", x$elbo, "\n")
    cat("Type Prior: ", x$priorvar, "\n")
    cat("Global Variance: ", x$global.var, "\n")
    cat("Stochastic Search: ", x$SVS, "\n")
    cat("\n")
    cat("Elapsed time: ", x$time[[3]], "\n")
    
    cat("\nCall:\n")
    print(x$call)
    cat("\n")
    
}
