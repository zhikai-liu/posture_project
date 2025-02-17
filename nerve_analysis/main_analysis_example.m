%Example code for analysis
M_file='ZL240626_M1_example_rec_baseline.mat';
addpath('./utility/')
process_raw_data_multi_unit(M_file);
process_multi_unit(['analyzed_' M_file],[],[],[],[]);
process_normalize_cardiac_cycle(['multi_unit_analyzed_' M_file])
plot_normalized_hist(['multi_unit_analyzed_' M_file])
