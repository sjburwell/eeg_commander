clear

% process/CRIT VARS
process.name           = mfilename;
process.loaddir        = '/labs/burwellstudy/projects/testing-eeg-toolbox/output_data/';
process.loadflt        = '*cnt.set' ;
process.loadpop        = 1;
process.logfile        = 1;
process.abortif        = ['chanlocs = readlocs(''montage10-10_sphrad1_n61.ced''); ' ...
                          'length(find(ismember({chanlocs.labels},{EEG.chanlocs.labels})))<46;'];
process.savedir        = process.loaddir;
process.savesfx        = '_epoch';

% config file (or struct variable)
cfg_export_mctfr_rseeg;
config(1).userinput    = 'recode_openclosed;';
config(5).epoch.events =    {'1' '2' '3' '4'};
config(5).epoch.winsec =             [0    2];

% run!
EEG = proc_commander(process, config);

