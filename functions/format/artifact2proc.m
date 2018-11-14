function EEG = artifact2proc(EEG, atvec, proctrig); 
%Usage: EEG = artifact2proc(EEG, atvec, proctrig);
% Take information from a logical vector (e.g. artifact) and replace the names of 'proc' events
% to '-1' (clean data) and '-9' (artifact data)
%
% atvec = EEG.reject.rejmanual
% N.B. you must have latest EEGLAB in your path (v9)
% Sburwell, 1/30/12

if nargin<3,
   proctrig = 'proc'; %proc trigger
end

ntype = repmat({'at'},size(atvec)); %dummy vector for new event names
ntype(atvec==0) = {'-1'};           %fill in logical 0s with '-1'
ntype(atvec==1) = {'-9'};           %fill in logical 1s with '-9'
%nlats = [EEG.event(find(ismember({EEG.event.type},proctrig))).latency];%latencies of proc-triggers %SJB: deleted for below 8-21-2018
nlats = unique([EEG.event(find(ismember({EEG.event.type},proctrig))).latency]);
EEG = pop_selectevent(EEG, 'omittype', proctrig ,'deleteevents','on'); %<-EEGLAB v9, moved from below eeg_mktriggers
[EEG.urevent, EEG.event] = eeg_mktriggers( EEG, ntype, nlats, 0);      %<-sburwell
