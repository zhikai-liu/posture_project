function [event_index,event_peak,amps] = Event_detection(data_s,si,amp_thre,diff_gap,diff_thre,event_duration)
%% calculate the difference between a time window as "1st derivative" to detect event
diff_gap = diff_gap/si;
event_duration =event_duration/si;
diff_ = data_s(1+diff_gap:end)-data_s(1:end-diff_gap)-diff_thre; % calculate the difference between a time window
crossing_ = diff_(1:end-1).*diff_(2:end)<0;% find the crossing points
r_index = find(crossing_.*(diff_(1:end-1)>0)); % find the on-rise crossing point
f_index = find(crossing_.*(diff_(1:end-1)<0)); % find the on-fall crossing point
if length(r_index) ~= length(f_index)
    warning('rising and falling not match')
    if length(r_index) == length(f_index)+1
        r_index(end)=[];
    elseif length(f_index) == length(r_index)+1
        f_index(1)=[];
    end
end

%% calculate amplitude for each events detected
raw_index=r_index;
raw_l = length(raw_index);
amp_raw = zeros(raw_l,1);
peak_index = zeros(raw_l,1);
for i = 2:raw_l-1
    duration = min(raw_index(i+1)-raw_index(i),event_duration);% Duration of event is the smaller one of either the pre-defined event durantion or before next event comes
    [peak_value,peak_index(i)] = max(data_s(raw_index(i):raw_index(i)+duration));
    [min_value,~] = min(data_s(raw_index(i):raw_index(i)+duration));
    % Calculate the amplitude of each event
    amp_raw(i)=peak_value-min_value;
    peak_index(i)=raw_index(i)+peak_index(i)-1;
    
end

%% set amplitudes threshold for event detection
amps = amp_raw(amp_raw>amp_thre);
event_index = r_index(amp_raw>amp_thre);
event_peak=peak_index(amp_raw>amp_thre);
end