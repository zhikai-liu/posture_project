function process_raw_data_multi_unit(file_name)
S=load(file_name);
si=S.isi*1e-3;
x_select=1:length(S.data);

%%find channels
channel_names={'ECG100C','Custom','Whole'};
ECG=0;breathing=0;raw_nerve_signal=0;
        
for i=1:size(S.labels,1)
    if contains(S.labels(i,:),channel_names{1})
        ECG=S.data(x_select,i);
    end
end
for i=1:size(S.labels,1)
    if contains(S.labels(i,:),channel_names{2})
        breathing=S.data(x_select,i);
    end
end
for i=1:size(S.labels,1)
    if contains(S.labels(i,:),channel_names{3})
        raw_nerve_signal=S.data(x_select,i);
    end
end

%smoothing signals
ECG=ECG-fastsmooth(ECG,0.5/si,1,1);
breathing=breathing-fastsmooth(breathing,2/si,1,1);

x_l=1:length(ECG);
%heart rate calculation
[~,QRS_loc]=findpeaks(ECG,'MinPeakDistance',0.08/si,'MinPeakHeight',std(ECG)*2);

hr_ecg=calc_hr(QRS_loc,si,x_l);

% breathing rate calculation
[~,breathing_loc]=findpeaks(-breathing,'MinPeakDistance',0.7/si,'MinPeakHeight',std(breathing));
if length(breathing_loc)>2
    breath_rate=calc_hr(breathing_loc,si,x_l);
else
    breath_rate=nan;
end
breath_interval=median(diff(breathing_loc),'omitmissing');
breathing_window=(int32(-0.1*breath_interval):int32(0.3*breath_interval));
breathing_exclude=vectorize_loc_window(breathing_loc,breathing_window);

save(['analyzed_',file_name],...
    'si','breath_rate','hr_ecg',...
    'ECG','QRS_loc',...
    'breathing','breathing_loc','breathing_exclude',...
    'raw_nerve_signal');
end
function interp_hr=calc_hr(ecg_loc,si,x_l)
loc_interval=diff(ecg_loc);
hr_bpm=1./loc_interval./si*60;
interp_hr=interp1(ecg_loc(1:end-1),hr_bpm,x_l,'makima');
end

function vec=vectorize_loc_window(loc,win)
    v_l=length(loc);
    vec=zeros(v_l*length(win),1);
    for i=1:length(loc)
        vec(length(win)*(i-1)+1:length(win)*i)=loc(i)+win;
    end
end
