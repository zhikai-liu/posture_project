function process_multi_unit(filename)
% Load data from the .mat file
S = load(filename);
si = S.si;
    start_t=1;
    end_t=length(S.ECG);

ECG = S.ECG(start_t:end_t);
hr=S.hr_ecg(start_t:end_t);
raw_nerve_signal = S.raw_nerve_signal(start_t:end_t);
breathing_exclude = S.breathing_exclude(S.breathing_exclude>=start_t&S.breathing_exclude<=end_t)-start_t+1;
if isfield(S,'QRS_loc')
    ecg_loc = S.QRS_loc(S.QRS_loc>=start_t&S.QRS_loc<=end_t)-start_t+1;
elseif isfield(S,'ecg_loc')
    ecg_loc = S.ecg_loc(S.ecg_loc>=start_t&S.ecg_loc<=end_t)-start_t+1;
else
    warning('no ecg loc detected')
end

results = struct();

loc_x_l = ecg_loc(ecg_loc > 1 & ecg_loc < length(ECG));
% Pre-allocate arrays

count = 1;
count_lim = 100;
std_raw_nerve = [];

% Calculate the std of signals to determine the noise level
for i = 2:length(loc_x_l)-2
    is_breathing=intersect(loc_x_l(i):loc_x_l(i+1),breathing_exclude);
    if isempty(is_breathing) && count <= count_lim
        raw_nerve_each_trial = raw_nerve_signal(loc_x_l(i):loc_x_l(i+1));
        std_raw_nerve(i) = std(raw_nerve_each_trial);
        count = count + 1;
    end
end
data_s = raw_nerve_signal;
si_us = si * 1e6;  % Convert sample interval to microseconds
diff_gap = 250;
event_duration = 500;
std_noise=median(std_raw_nerve,'omitmissing');
% determine noise level
amp_thre = 4 * std_noise;
diff_thre = 3 * std_noise;
% event detection
der=struct();
[der.event_index, der.event_peak, der.amps] = Event_detection(-data_s, si_us, amp_thre, diff_gap, diff_thre, event_duration);
der.event_index=der.event_index(2:end-1);
der.event_peak=der.event_peak(2:end-1);
der.amps=der.amps(2:end-1);

%calculate spikes per cycle
Data = data_s;
spikerate_each_cycle =[];
valid_cycle=[];
cycle_count=1;
for i = 2:length(loc_x_l)-2
    is_breathing=intersect(loc_x_l(i):loc_x_l(i+1),breathing_exclude);
    if isempty(is_breathing)
        valid_cycle(cycle_count,1)=loc_x_l(i);
        events_within_cycle = der.event_index(der.event_index>loc_x_l(i)&der.event_index<loc_x_l(i+1));
        spikerate_each_cycle(cycle_count,1) = length(events_within_cycle)/(loc_x_l(i+1)-loc_x_l(i))/si;
        cycle_count=cycle_count+1;
    end
end

% Save the results of the current file into the structure
results.filename = filename;
results.ECG = ECG;
results.hr_ecg = hr;
results.si = si;
results.der = der;
results.loc_x_l= loc_x_l;
results.breathing_exclude=breathing_exclude;
results.std_noise=std_noise;
results.amp_thre=amp_thre;
results.diff_thre=diff_thre;
results.Data = Data;
results.si_us = si_us;
results.valid_cycle = valid_cycle;
results.spikes_each_cycle=spikerate_each_cycle;

save(['multi_unit_' filename], 'results');

end