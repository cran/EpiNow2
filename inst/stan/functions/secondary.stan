// Calculate secondary reports condition only on primary reports
vector calculate_secondary(vector reports, array[] int obs, array[] real frac_obs,
                           vector delay_rev_pmf, int cumulative, int historic,
                           int primary_hist_additive, int current,
                           int primary_current_additive, int predict) {
  int t = num_elements(reports);
  int obs_scale = num_elements(frac_obs);
  vector[t] scaled_reports;
  vector[t] conv_reports = rep_vector(1e-5, t);
  vector[t] secondary_reports = rep_vector(0.0, t);
  // scaling of reported cases by fraction
  if (obs_scale) {
    scaled_reports = scale_obs(reports, frac_obs[1]);
  }else{
    scaled_reports = reports;
  }
  // convolve from reports to contributions from these reports
  conv_reports = conv_reports +
    convolve_to_report(scaled_reports, delay_rev_pmf, 0);
  // if predicting and using a cumulative target
  // combine reports with previous secondary data
  for (i in 1:t) {
    // update cumulative target
    if (cumulative && i > 1) {
      if (i > predict) {
        secondary_reports[i] = secondary_reports[i - 1];
      }else{
        secondary_reports[i] = obs[i - 1];
      }
    }
    // update based on previous primary reports
    if (historic) {
      if (primary_hist_additive) {
        secondary_reports[i] += conv_reports[i];
      }else{
        if (conv_reports[i] > secondary_reports[i]) {
          conv_reports[i] = secondary_reports[i];
        }
        secondary_reports[i] -= conv_reports[i];
      }
    }
    // update based on current primary reports
    if (current) {
      if (primary_current_additive) {
        secondary_reports[i] += scaled_reports[i];
      }else{
        secondary_reports[i] -= scaled_reports[i];
      }
    }
    secondary_reports[i] = 1e-6 + secondary_reports[i];
  }
  return(secondary_reports);
}
