clear

% process/CRIT VARS
process.name           = mfilename;
process.loaddir        = '/labs/burwellstudy/data/anker_k01_tmp/';
process.loadflt        = '*.cdt';
process.loadpop        = 1;
process.logfile        = 1;
process.abortif        = ['chanlocs = readlocs(''curry_sphrad1_n28.ced''); ' ...
                          'length(find(ismember({chanlocs.labels},{EEG.chanlocs.labels})))<15;'];
process.savedir        = '/labs/burwellstudy/projects/testing-eeg-toolbox/output_data/';
process.savesfx        = '_cnt';
process.opts.resample  =    256;

% config file (or struct variable)
cfg_import_alcstress_general;

% run!
EEG = proc_commander(process, config);

