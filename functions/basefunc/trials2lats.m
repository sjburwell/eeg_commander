% trials2lats() - convert trial number boundries to latencies; assumes that trials
%                 are non-overlapping.  For use in the processing routine.
%
% Usage: 
%   >> seglats = trials2lats(EEG, trials);
%
% Inputs:
%   EEG        - input EEG data structure
%   trials     - trial indices to retrieve latencies
%
% Outputs:
%   seglats    - latency boundaries, Nseg x [beglat  endlat]
%
% Scott Burwell, February 2011
%
% See also: eeg_unepoch, eeg_eegrej, eeg_regular_triggers
function seglats = trials2lats(EEG, trials); 

TIMEWIN      = [(find(EEG.times==0)*-1)+1  EEG.pnts-find(EEG.times==0)];
seglats  = [];
for E = 1:length(trials),
    PLACE  = find(cell2mat(EEG.epoch(trials(E)).eventlatency)==0,1,'first');
    EVTLAT = EEG.urevent(EEG.epoch(trials(E)).eventurevent{PLACE}).latency ;
    seglats = [seglats;  TIMEWIN+EVTLAT];
end

%
%timewin = [(find(EEG.times==0)*-1)+1  EEG.pnts-find(EEG.times==0)];
%seglats = [];


