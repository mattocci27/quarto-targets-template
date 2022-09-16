data {
  int<lower=0> J;
  vector[J] y;
  vector<lower=0>[J] sigma;
  real<lower=0> tau;
}

parameters {
  real mu;
  real theta_tilde[J];
}

transformed parameters {
  real theta[J];
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
