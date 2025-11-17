function process_raw_data(file_name,if_plot)
S=load(file_name);
si=S.isi*1e-3;
x_select=1:length(S.data);
% Preallocate arrays for ECG, breathing, and BP data
ECG = zeros(length(x_select), 1);
breathing = zeros(length(x_select), 1);
carotid_BP = zeros(length(x_select), 1);
accel_x = zeros(length(x_select), 1);
accel_y = zeros(length(x_select), 1);
accel_z = zeros(length(x_select), 1);

% Convert character array to cell array of strings
S.labels = cellstr(S.labels);

% Extract channels more efficiently
channel_names = {'ECG', 'Custom', 'TSD104A', ' CH X', 'CH Y','CH Z'};
for i = 1:length(channel_names)
    idx = contains(S.labels, channel_names{i}, 'IgnoreCase', true);  % Use IgnoreCase to handle case sensitivity
    if any(idx)
        switch i
            case 1, ECG = S.data(x_select, find(idx));
            case 2, breathing = S.data(x_select, find(idx));
            case 3, carotid_BP = S.data(x_select, find(idx));
            case 4, accel_x = S.data(x_select, find(idx));
            case 5, accel_y = S.data(x_select, find(idx));
            case 6, accel_z = S.data(x_select, find(idx));
        end
    end
end

% Smooth signals
ECG = ECG - fastsmooth(ECG, 0.5/si);
breathing = breathing - fastsmooth(breathing, 2/si);

% Calculate heart rate and breathing rate
[~, ecg_loc] = findpeaks(-ECG, 'MinPeakDistance', 0.09/si);
hr_ecg = calc_hr(ecg_loc, si, 1:length(ECG));

[~, breathing_loc] = findpeaks(breathing, 'MinPeakDistance', 0.7/si);
breath_rate = calc_hr(breathing_loc, si, 1:length(breathing));

%% BP calculation
% Systole
[sys_val, sys_loc] = findpeaks(carotid_BP, 'MinPeakDistance', 0.09/si);
hr_sys = calc_hr(sys_loc, si, 1:length(carotid_BP));

% Diastole
[dia_val,dia_loc]=findpeaks(-carotid_BP,'MinPeakDistance',0.09/si);

% Calculate MAP (Mean Arterial Pressure) from systolic and diastolic values
sys_BP = interp1(sys_loc, sys_val, 1:length(carotid_BP));
dia_BP = interp1(dia_loc, -dia_val, 1:length(carotid_BP));
MAP = (sys_BP + 2 * dia_BP) / 3;

% Tilt angle calculation
g_vec = accel_z + 1i*accel_x;
tilt_angle = angle(g_vec * exp(1i * pi/2)) / pi * 180;

save(['analyzed_' file_name], 'si', 'g_vec', 'hr_ecg', 'MAP', 'breath_rate', 'hr_sys');


if if_plot
    figure;
    subplot(4, 1, 1); plot((1:length(tilt_angle)) * si, tilt_angle); title('Tilt Angle');
    subplot(4, 1, 2); plot((1:length(breath_rate)) * si, breath_rate); title('Breathing Rate');
    subplot(4, 1, 3); plot((1:length(hr_sys)) * si, hr_sys); title('Heart Rate');
    subplot(4, 1, 4); plot((1:length(MAP)) * si, MAP); title('Mean Arterial Pressure (MAP)');
end
end

function interp_hr = calc_hr(locs, si, x_l)
loc_interval = diff(locs);
hr_bpm = 1 ./ loc_interval / si * 60;
%smooth_hr = smooth(hr_bpm, 6);
interp_hr = interp1(locs(1:end-1), hr_bpm, x_l,'makima');
end

