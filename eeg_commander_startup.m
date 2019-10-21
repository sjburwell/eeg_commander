eeglab_working_dir = fileparts(which('eeglab'));
eeg_checkset_test = which('eeg_checkset');
if ~isempty(eeglab_working_dir) && ~isempty(eeg_checkset_test),
   display(['   eeg_commander_startup; required EEGLAB toolbox path added: ' eeglab_working_dir]);
else,
   display(['   eeg_commander_startup; please addpath to EEGLAB toolbox (>=v14.1.1b) and run command >>eeglab before starting eeg_commander']);
   return
end

commander_dir = fileparts(which('eeg_commander_startup'));
addpath(genpath(commander_dir));
display(['   eeg_commander_startup; required eeg_commander toolbox path added: ' commander_dir]);
