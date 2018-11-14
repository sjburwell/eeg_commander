%EEG1 = pop_loadset('/labs/burwellstudy/projects/testing-eeg-toolbox/output_data/201810291300_sub000502_ses01_run03_cnt_epoch_emg.set');
%EEG2 = pop_loadset('/labs/burwellstudy/projects/testing-eeg-toolbox/output_data/201810291300_sub000502_ses01_run04_cnt_epoch_emg.set'); EEG = pop_mergeset(EEG1,EEG2,1);
EEG  = pop_loadset('/labs/burwellstudy/projects/testing-eeg-toolbox/output_data/Acquisition 97_cnt_epoch_emg.set');

ylimits  = [   -5, 40 ];
audtimes = [ 3800,4500];
EEG = pop_rmbase(EEG,[3500,4000]);
EEG.data = abs(EEG.data);
EEG = pop_firws(EEG, 'fcutoff', 40, 'ftype', 'lowpass', 'wtype', 'kaiser', 'warg', 7.85726, 'forder',88);

%%%------AUDITORY
EEG = pop_rmbase(EEG,[3500,4000]);
figure;
 plot(EEG.times(find(EEG.times>=audtimes(1) & EEG.times<=audtimes(2))) - 4000, ...
      squeeze(mean(EEG.data(1,find(EEG.times>=audtimes(1) & EEG.times<=audtimes(2)),strmatch('4',{EEG.epoch.eventtype})),3)), ...
      'k:','LineWidth',2); hold on;
 plot(EEG.times(find(EEG.times>=audtimes(1) & EEG.times<=audtimes(2))) - 4000, ...
      squeeze(mean(EEG.data(1,find(EEG.times>=audtimes(1) & EEG.times<=audtimes(2)),strmatch('5',{EEG.epoch.eventtype})),3)), ...
      'k-','LineWidth',2);
 plot(EEG.times(find(EEG.times>=audtimes(1) & EEG.times<=audtimes(2))) - 4000, ...
      squeeze(mean(EEG.data(1,find(EEG.times>=audtimes(1) & EEG.times<=audtimes(2)),strmatch('6',{EEG.epoch.eventtype})),3)), ...
      'k-.','LineWidth',2);
 ylim(ylimits); 
xlabel('Latency (ms)'); ylabel('Integrated EMG'); suptitle('Startle Response');
legend('Neutral','Predictable','Unpredictable');










