clear

% process/CRIT VARS
process.name           = mfilename;
process.loaddir        = '/labs/burwellstudy/projects/testing-eeg-toolbox/output_data/';
process.loadflt        = '*cnt.set';
process.loadpop        = 1;
process.logfile        = 1;
process.abortif        ='';
process.savedir        = process.loaddir;
process.savesfx        = '_epoch_npuemg';

% config file (or struct variable)
cfg_export_alcstress_emg;
config(1).userinput        = 'recode_npu; EEG = proc_select(EEG,''channel'',{''EMG''}); ';
config(4).epoch.events     = {'40' '41' '42' '43' '50' '51' '52' '53' '60' '61' '62' '63'}; % ('all','ALL',[]) or cellstr, or 'task_default' 
config(4).epoch.winsec     =                     [-0.5 4.5]; % in sec

% run!
EEG = proc_commander(process, config);

