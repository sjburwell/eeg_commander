clear

% process/CRIT VARS
process.name           = mfilename;
process.loaddir        = '/labs/mctfr-psyphys/data/raw/biosemi/resting.open-closed/e11f23-x/';
process.loadflt        = '*_rest.bdf'; 
process.loadpop        = 1;
process.logfile        = 1;
process.abortif        = ['chanlocs = readlocs(''montage10-10_sphrad1_n61.ced''); ' ...
                          'length(find(ismember({chanlocs.labels},{EEG.chanlocs.labels})))<46;'];;
process.savedir        = '/labs/burwellstudy/projects/testing-eeg-toolbox/output_data/';
process.savesfx        = '_cnt';
process.opts.bdf2eeg   = {'swap_elecs','esmf_unused-as-of-2018-02-20.txt', ...
                          'lowfreq', 0.1, 'verbose', 0}; 

% config file (or struct variable)
config = 'cfg_import_mctfr_general';

% run!
EEG = proc_commander(process, config);

