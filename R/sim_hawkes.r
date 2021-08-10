setClassUnion("numeric_or_missing", c("numeric", "missing"))
setClassUnion("logical_or_missing", c("logical", "missing"))
setClassUnion("character_or_missing", c("character", "missing")) 
#' Function to simulate a self-exciting Hawkes process.
#'
#' There are two methods to simulate the process: if \code{method = "1"} sumiualtes a
#' univariate hawkes process as \code{R}  package \code{hawkes}';
#' if \code{method = "2"} as per algorithm defined in
#' \url{https://radhakrishna.typepad.com/mle-of-hawkes-self-exciting-process.pdf}
#'
#' @docType methods
#' @rdname sim_hawkes
#' @param mu numeric integer specifying base rate of the hawkes process
#' @param alpha numeric integer specifying intensity jump after an event occurence
#' @param beta numeric integer specifying exponential intensity decay
#' @param n numeric depending on method: if \code{method = "1"} specifying end of the time
#' line within which to simulate the proces, or \code{method = "2"}. By default = 100.
#' specifying the number of timepoints to simulate.
#' @param plot logical if \code{TRUE} data plotted along with the intensity. By default is \code{FALSE}.
#' @param seed seed by default = 123
#' @param method a character "1" or "2" specifying the method (see above) to simulate hawkes process.
#' By default = "1".
#' @export
setGeneric("sim_hawkes",
           function(mu, alpha, beta, n, plot, seed, method){
               standardGeneric("sim_hawkes")
           })

setMethod("sim_hawkes",
          c(mu = "numeric",alpha = "numeric" ,
            beta  = "numeric",n = "numeric_or_missing" , plot = "logical_or_missing" ,
            seed = "numeric_or_missing",
            method = "character_or_missing"),
          function(mu, alpha ,beta, n, plot, seed, method){
              if(alpha >= beta){
                  stop("alpha must be less then beta to ensure intensity decreases quicker than new events increase it")
              }
              if(missing(n)) n = 100
              if(missing(seed)) seed = 123
              if(missing(plot)) plot = FALSE
              if(missing(method)) method = "1"
              if(!method %in% c("1","2")){stop("method should be either \"1\" or \"2\"")}
              set.seed(seed)
              times = numeric()
              if(method == "1"){
                  s = 0
                  t = 0
                  lambda_star = mu
                  s = s -log(runif(1))/lambda_star
                  t = s
                  dlambda = alpha
                  times = c(times, t)
                  while(s < n) {
                      U = runif(1)
                      s = s -log(U)/lambda_star
                      u = stats::runif(1)
                      if(u <= (mu + dlambda*exp(-beta*(s-t)))/lambda_star){
                          dlambda = alpha + dlambda*exp(-beta*(s-t))
                          lambda_star = lambda_star + alpha
                          t = s
                          times = c(times, t)
                      }
                  }
                  if(plot) show_hawkes(times, mu, alpha, beta)
                  return(times)
              }else{
                  if(method == "2"){
                      eps = 1e-6
                      S = function(k){
                          if(k==1) return(1)
                          return( 1 + S(k-1)* exp(-beta * (times[k]- times[k - 1])) )
                      }
                      fu = function(u, U, k){
                          return(log(U) + mu*(u - times[k]) +
                                 alpha/beta * S(k) * (1 - exp(-beta * (u - times[k]))))
                      }
                      fu_prime = function(u, U , k){
                          return(mu + alpha * S(k) * (exp(-beta * (u - times[k]))))
                      }
                      solve_u = function(U,k) {
                          u_prev = times[k] - log(U)/mu
                          u_next = u_prev - fu(u_prev, U, k)/ fu_prime(u_prev, U, k)
                          while( abs(u_next - u_prev) > eps){
                              u_prev = u_next
                              u_next = u_prev - fu(u_prev, U, k)/fu_prime(u_prev, U, k)
                          }
                          return(0.5 * (u_prev + u_next))
                      }
                      t1 = -log(runif(1))/mu
                      times = c( times, t1)
                      k = length(times)
                      while(k < n) {
                          U = stats::runif(1)
                          t_next = solve_u( U, k)
                          times = c(times, t_next)
                          k = length(times)
                      }
                      if(plot) show_hawkes(times, mu, alpha, beta)
                      return(times)
                  }
              }   
          }
          )




