%% Data exploration of PPG Timeseries

% first we load the data and smooth it to remove quantization effects
close all;
cd('/home/mona/dev/ppg');
filename = 'PPG_nohdr/opensignals_98D311FD1F39_2022-04-03_19-01-35.txt';
%filename = 'PPG_nohdr/opensignals_98D311FD1F39_2022-04-03_19-15-40.txt';
%filename = 'PPG_nohdr/opensignals_98D311FD1F39_2022-04-03_19-04-03.txt';
data_array = read_custom_textfile(filename);
data_array = smoothdata(data_array);

% visualize the time series
Fs = 1e3;                   % [Hz] 1kHz sampling rate known apriori
plot_timeseries(data_array, Fs, 1);

% use a highpass filter to remove the baseline wander and smooth again to

N  = 10;       % Filter Order
Fc = 0.25;     % Cutoff Frequency
% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.highpass('N,F3dB', N, Fc, Fs);
Hd = design(h, 'butter');
sz = size(data_array);
data_array_filt = zeros(sz);
% filter the entire timeseries for now
for i=1:sz(1)
    data_array_filt(i,:)=filtfilt(Hd.sosMatrix,Hd.ScaleValues,data_array);
end

% Plot the filtered timeseries
plot_timeseries(smoothdata(data_array_filt), Fs, 2)

% Find peaks within the timeseries corresponding to local maxima, i.e. the
% centre of each beat
[peaks, locs] = findpeaks(smoothdata(data_array_filt, 'SmoothingFactor', 0.25));
figure(2); hold on;
tbasis = (1:1:length(data_array_filt))/Fs;
scatter(tbasis(locs), peaks)

% now that we've found the peaks, let's compute the HR
% in the experiment, the first 60 seconds are free thought (condition = 0)
% and in the remainder of the experiment (t > 60 seconds) the subject
% focuses on a specific thought or memory (condition = 1)

pulse_times = tbasis(locs);
first_epoch = pulse_times(pulse_times <= 60);
second_epoch = pulse_times(pulse_times > 60);

% Calculate Heart Rates (beats per second)
HR_1 = length(first_epoch)/60
HR_2 = length(second_epoch)/(max(tbasis-60))

% average +/- std of interbeat interval in first epoch
IBI_1_mu = mean(diff(first_epoch))
IBI_1_sd = std(diff(first_epoch))

% average +/- std of interbeat interval in second epoch
IBI_2_mu = mean(diff(second_epoch))
IBI_2_sd = std(diff(second_epoch))

% supporting functions

function [] = plot_timeseries(data_array_in, fs, fig_num)
% a function to make a nice plot
    time_axis = (1:1:length(data_array_in))/fs;
    figure(fig_num); hold on;
        set(gcf,'Color','w'); 
        plot(time_axis, data_array_in, 'k');
        xlabel('Time (sec)'); ylabel('Amplitude (a.u.)');
        set(gca, 'LineWidth', 2, 'FontWeight', 'b', ...
                 'FontSize', 14);        
        box on;
        axis tight;
        
end

function data_array_out = read_custom_textfile(filename_in)
% function read in data from a header-stripped textfile
    fprintf('Reading file %s ...\n', filename_in);
    
    % since we don't know in advance how long each file is, brute force and
    % append to an empty array using a while loop.
    data_array_out = [];
    cnt = 1;

    fid=fopen(filename_in,'r');
    curr_line = fgetl(fid);
    while ischar(curr_line)
        tline_split = strsplit(curr_line);
        data_array_out(cnt) = str2double(tline_split{6});
        curr_line = fgetl(fid);
        cnt = cnt + 1;
    end
    fclose(fid);
    disp('Done.');
end
