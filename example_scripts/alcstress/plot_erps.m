%EEG1 = pop_loadset('/labs/burwellstudy/projects/testing-eeg-toolbox/output_data/201810291300_sub000502_ses01_run03_cnt_epoch_eeg.set');
%EEG2 = pop_loadset('/labs/burwellstudy/projects/testing-eeg-toolbox/output_data/201810291300_sub000502_ses01_run04_cnt_epoch_eeg.set'); EEG = pop_mergeset(EEG1,EEG2,1);
%EEG = pop_loadset('/labs/burwellstudy/projects/testing-eeg-toolbox/output_data/Acquisition 97_cnt_epoch_eeg.set');
EEG = pop_loadset('/labs/burwellstudy/projects/testing-eeg-toolbox/output_data/201812041510_sub000504_ses01_run03_cnt_epoch_npueeg.set');

channels = {'FZ','CZ','PZ','OZ'};


ylimits  = [  -40   40]; 
vistimes = [ -200, 500];
audtimes = [ 3800,4500]; 
%%%-------VISUAL
EEG = pop_rmbase(EEG,[-200,-1]);
figure;
for ii = 1:length(channels),
 subplot(length(channels),1,ii);
 plot(EEG.times(find(EEG.times>=vistimes(1) & EEG.times<=vistimes(2))), ...
      squeeze(mean(EEG.data(strmatch(channels{ii},{EEG.chanlocs.labels}),find(EEG.times>=vistimes(1) & EEG.times<=vistimes(2)),strmatch('4',{EEG.epoch.eventtype})),3)), ...
      'k:','LineWidth',2); hold on;
 plot(EEG.times(find(EEG.times>=vistimes(1) & EEG.times<=vistimes(2))), ...
      squeeze(mean(EEG.data(strmatch(channels{ii},{EEG.chanlocs.labels}),find(EEG.times>=vistimes(1) & EEG.times<=vistimes(2)),strmatch('5',{EEG.epoch.eventtype})),3)), ...
      'k-','LineWidth',2); 
 plot(EEG.times(find(EEG.times>=vistimes(1) & EEG.times<=vistimes(2))), ...
      squeeze(mean(EEG.data(strmatch(channels{ii},{EEG.chanlocs.labels}),find(EEG.times>=vistimes(1) & EEG.times<=vistimes(2)),strmatch('6',{EEG.epoch.eventtype})),3)), ...
      'k-.','LineWidth',2); 
 ylim(ylimits); title(['EEG site: ' channels{ii}]);
 if ii==1, legend('Neutral','Predictable','Unpredictable'); end
end 
xlabel('Latency (ms)'); ylabel('Potential (uV)'); suptitle('Visual ERPs'); 

%%%------AUDITORY
EEG = pop_rmbase(EEG,[3800,4000]);
figure;
for ii = 1:length(channels),
 subplot(length(channels),1,ii);
 plot(EEG.times(find(EEG.times>=audtimes(1) & EEG.times<=audtimes(2))) - 4000, ...
      squeeze(mean(EEG.data(strmatch(channels{ii},{EEG.chanlocs.labels}),find(EEG.times>=audtimes(1) & EEG.times<=audtimes(2)),strmatch('4',{EEG.epoch.eventtype})),3)), ...
      'k:','LineWidth',2); hold on;
 plot(EEG.times(find(EEG.times>=audtimes(1) & EEG.times<=audtimes(2))) - 4000, ...
      squeeze(mean(EEG.data(strmatch(channels{ii},{EEG.chanlocs.labels}),find(EEG.times>=audtimes(1) & EEG.times<=audtimes(2)),strmatch('5',{EEG.epoch.eventtype})),3)), ...
      'k-','LineWidth',2);
 plot(EEG.times(find(EEG.times>=audtimes(1) & EEG.times<=audtimes(2))) - 4000, ...
      squeeze(mean(EEG.data(strmatch(channels{ii},{EEG.chanlocs.labels}),find(EEG.times>=audtimes(1) & EEG.times<=audtimes(2)),strmatch('6',{EEG.epoch.eventtype})),3)), ...
      'k-.','LineWidth',2);
 ylim(ylimits); title(['EEG site: ' channels{ii}]);
 if ii==1, legend('Neutral','Predictable','Unpredictable'); end
end
xlabel('Latency (ms)'); ylabel('Potential (uV)'); suptitle('Startle-Probe ERPs');










