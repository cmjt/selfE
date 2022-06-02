/* Modified version of estimating Hawkes process */
/* The simulation code is added on 20/05/2021. */
/* Generic Inhomogenous Self-exciting Hawke's processes 23/05/2022 */
#include <TMB.hpp>
#include <vector>
#include <iostream>
template<class Type>
Type objective_function<Type>::operator() ()
{
  using namespace Eigen;
  // vector of time
  DATA_VECTOR(times);
  DATA_VECTOR(lambda);
  DATA_VECTOR(marks);
  Type marks_mean = marks.sum()/marks.size(); // Average mark
  DATA_SCALAR(lambda_integral);
  
  // parameters of the hawkes process
  PARAMETER(logit_abratio);
  PARAMETER(log_beta);

  Type beta = exp(log_beta);
  Type alpha = exp(logit_abratio) / (Type(1.) + exp(logit_abratio)) * (beta/marks_mean); // enforcing 0<=alpha<=beta

  vector<Type> A = vector<Type>::Zero(times.size());
  
  
  Type nll = 0;
  for(int i = 1; i < times.size(); ++i){
    // Page 28 of https://pat-laub.github.io/pdfs/honours_thesis.pdf
    A[i] = exp(-beta * (times[i] - times[i - 1])) * (marks[i-1] + A[i - 1]);
  }
  vector<Type> term_3vec = log(lambda + alpha * A);
  nll = lambda_integral - ((alpha/beta)*A.template tail<1>()[0])+ ((alpha / beta) * Type(sum(marks)-marks.template tail<1>()[0])) - sum(term_3vec);

  //SIMULATE {
    //Type eps = 1e-10, t = 0, M = mu, U;
    //int index = 0;
    //while (index < times.size()){
      //M = mu + alpha * (-beta * (t + eps - times.array().head(index))).exp().sum();
      //t += rexp(Type(1.) / M); U = runif(Type(0.), M); // There is currently a bug as at TMB-1.7.20, 14/05/2021.
      //if (U <= mu + alpha * (-beta * (t - times.array().head(index))).exp().sum()){
        //times[index] = t;
        //index++;
      //}
    //}
    //REPORT(times);
  //}

  ADREPORT(alpha);
  ADREPORT(beta);

  return nll;
}