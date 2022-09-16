data {
  int<lower=0> J;
  vector[J] y;
  vector<lower=0>[J] sigma;
}

parameters {
  real mu;
  real<lower=0,upper=pi()/2> tau_unif;
  real theta_tilde[J];
}

transformed parameters {
  real<lower=0> tau;
  real theta[J];
  tau = 5 * tan(tau_unif);
  for (j in 1:J)
    theta[j] = mu + tau * theta_tilde[j];
}

model {
  mu ~ normal(0, 5);
  theta_tilde ~ std_normal();
  y ~ normal(theta, sigma);
}

generated quantities {
  vector[J] log_lik;
  for (j in 1:J) log_lik[j] = normal_lpdf(y[j] | theta[j], sigma[j]);
}
