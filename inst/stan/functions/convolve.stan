// convolve two vectors as a backwards dot product
// y vector should be reversed
// limited to the length of x and backwards looking for x indexes
vector convolve_with_rev_pmf(vector x, vector y, int len) {
    int xlen = num_elements(x);
    int ylen = num_elements(y);
    vector[len] z;
    if (xlen + ylen <= len) {
      reject("convolve_with_rev_pmf: len is longer then x and y combined");
    }
    for (s in 1:len) {
      z[s] = dot_product(
        x[max(1, (s - ylen + 1)):min(s, xlen)],
        y[max(1, ylen - s + 1):min(ylen, ylen + xlen - s)]
      );
    }
   return(z);
  }


// convolve latent infections to reported (but still unobserved) cases
vector convolve_to_report(vector infections,
                          vector delay_rev_pmf,
                          int seeding_time) {
  int t = num_elements(infections);
  vector[t - seeding_time] reports;
  vector[t] unobs_reports = infections;
  int delays = num_elements(delay_rev_pmf);
  if (delays) {
    unobs_reports = convolve_with_rev_pmf(unobs_reports, delay_rev_pmf, t);
    reports = unobs_reports[(seeding_time + 1):t];
  } else {
    reports = infections[(seeding_time + 1):t];
  }
  return(reports);
}
