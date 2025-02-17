function process_normalize_cardiac_cycle(filename)
    S=load(filename);
    results=S.results;
    si = results.si;
    ECG = results.ECG;
    der = results.der;
    hr=mean(results.hr_ecg,'omitnan');
    RR_interval=1/hr*60;
    breathing_exclude = results.breathing_exclude;
    loc_x_l=results.loc_x_l;
        % Pre-allocate arrays
        x_zero = -0.1/si : 0.1/si;
    ECG_each_trial = zeros(length(x_zero), length(loc_x_l));
    event_total = [];
    amps_total = [];
    count_cycle = 1;
    
    for i = 2:length(loc_x_l)-2
        x_plot = loc_x_l(i) - 0.1/si : loc_x_l(i) + 0.1/si;
        is_breathing=intersect(loc_x_l(i):loc_x_l(i+1),breathing_exclude);
        event_index = der.event_peak(der.event_peak > loc_x_l(i) - 0.1/si & der.event_peak < loc_x_l(i) + 0.1/si);
        amps = der.amps(der.event_peak > loc_x_l(i) - 0.1/si & der.event_peak < loc_x_l(i) + 0.1/si);
        if isempty(is_breathing)
            ECG_each_trial(:, i) = ECG(x_plot) - ECG(loc_x_l(i));
            event_total = [event_total; event_index - loc_x_l(i)];
            amps_total = [amps_total; amps];
            count_cycle = count_cycle + 1;
        else
            ECG_each_trial(:, i) = nan;
        end
    end

    mean_ECG = mean(ECG_each_trial, 2, 'omitnan');
    [ECG_peak, peak_index] = findpeaks(mean_ECG, 'MinPeakProminence', 0.3*std(mean_ECG), 'MinPeakDistance', 0.02/si);
    peak_index_zero=peak_index-(length(mean_ECG)+1)/2;
    P1wave_cutoff=RR_interval*0.8;
    P2wave_cutoff=RR_interval*0.9;
    peak_index=peak_index(peak_index_zero>-P1wave_cutoff/si&peak_index_zero<P2wave_cutoff/si);
    ECG_peak=ECG_peak(peak_index_zero>-P1wave_cutoff/si&peak_index_zero<P2wave_cutoff/si);
    peak_index_zero=peak_index_zero(peak_index_zero>-P1wave_cutoff/si&peak_index_zero<P2wave_cutoff/si);
    if length(peak_index) < 3
        warning('Npeaks is less than 3 for %s.', filename);
    end
    
    % Step 1: Normalize time based on QRS complexes
    peak_index1 = peak_index_zero(1);  % P wave
    peak_index2 = peak_index_zero(2);  % QRS complex (set to time 0)
    
    % Calculate the normalization factor
    time_range = peak_index2 - peak_index1;
    
    % Normalize the locs_QRS times
    %peak_index_normalized = peak_index / time_range;
    time_normalized=(-(length(mean_ECG)-1)/2:(length(mean_ECG)-1)/2) / time_range;
    
    % Normalize event times based on peak_index boundaries
    valid_events = event_total(event_total >= peak_index1);% & event_total <= peak_indexend);
    normalized_events = (valid_events - peak_index2) / time_range;
    normalized_peak_index = (peak_index_zero - peak_index2) / time_range;
    results.time_normalized=time_normalized;
    results.mean_ECG = mean_ECG;
    results.normalized_events = normalized_events;
    results.count_cycle=count_cycle;
    results.peak_index_zero=peak_index_zero;
    results.normalized_peak_index=normalized_peak_index;
    results.ECG_peak=ECG_peak;
    save(filename,'results');
end