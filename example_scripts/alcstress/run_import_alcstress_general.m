clear

% process/CRIT VARS
process.name           = mfilename;
process.loaddir        = '/labs/ankerlab/data/k01/npu/';
process.loadflt        = '*.cdt';
process.loadpop        = 1;
process.logfile        = 1;
process.abortif        = ['chanlocs = readlocs(''curry_sphrad1_n28.ced''); ' ...
                          'length(find(ismember({chanlocs.labels},{EEG.chanlocs.labels})))<15;'];
process.savedir        = '/labs/ankerlab/projects/k01/npu/data_cache/';
process.savesfx        = '_cnt';
process.opts.resample  =    256;

% config file (or struct variable)
cfg_import_alcstress_general;

% run!
EEG = proc_commander(process, config);

