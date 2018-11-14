function EEG = ptb2eeglab(erp, chanlocs); %, sample);
% EEG = ptb2eeglab(erp, chanlocs);  -- "chanlocs" must be readable by readlocs(), or already chanlocs struct
% WARNING: requires that chanlocs be consistent with channels in erp variable

% -- load and format chanloc information
if ~isstruct(chanlocs),
   chanlocs = readlocs(chanlocs);
end 
chans2keep = find(ismember({chanlocs.labels},cellstr(erp.elecnames)));
chanlocs   = chanlocs(chans2keep);

% -- re-format data
% way to salvage subnum, subname, catcode, sweep info?
nelec   = length(unique(erp.elec));
npts    = size(erp.data,2);
trial_index = reshape(find(ones(nelec, size(erp.data,1)/nelec)), [nelec, size(erp.data,1)/nelec]);
newdata = zeros(nelec, npts, size(trial_index,2)); clear epoch
for trial_count = 1:size(trial_index,2), 
    data_idx = trial_index(:,trial_count);
    newdata(1:nelec, 1:npts, trial_count) = erp.data(data_idx,:);
    %epoch(trial_count).event         = trial_count;
    %epoch(trial_count).eventduration = {[0]};
    %epoch(trial_count).eventlatency  = {[0]};
    %epoch(trial_count).eventtype     = ['subnum'  unique(erp.subnum(data_idx)),       ...
    %                                    'catcode' unique(erp.stim.catcodes(data_idx)), ...
    %                                    'sweep'   unique(erp.sweep(data_idx))]; 
end

%%-- build EEGLAB structure
EEG = eeg_emptyset;
EEG.nbchan   = length(chanlocs);
EEG.trials   = size(newdata,3);
EEG.pnts     = size(newdata,2);
EEG.srate    = erp.samplerate;
EEG.data     = newdata;
EEG.chanlocs = chanlocs;
EEG.xmin  = EEG.xmin- (((erp.tbin-1)/erp.samplerate));
EEG.xmax  = EEG.xmax- (((erp.tbin-1)/erp.samplerate));
EEG.times = EEG.times-(((erp.tbin-1)/erp.samplerate));
%EEG.xmin  = EEG.xmin- ((erp.tbin/erp.samplerate));
%EEG.xmax  = EEG.xmax- ((erp.tbin/erp.samplerate));
%EEG.times = EEG.times-((erp.tbin/erp.samplerate));
%if exist(epoch),
%   EEG.epoch = epoch;
%   [EEG.urevent, EEG.event] = eeg_mktriggers([],{epoch.eventtype}, zeros(1,EEG.trials));
%end
EEG = eeg_checkset(EEG);


