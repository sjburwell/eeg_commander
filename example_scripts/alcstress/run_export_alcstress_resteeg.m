clear

% process/CRIT VARS
process.name           = mfilename;
process.loaddir        = '/labs/ankerlab/projects/k01/rest.post/data_cache/';
process.loadflt        = '*cnt.set';
process.loadpop        = 1;
process.logfile        = 1;
process.abortif        = ['chanlocs = readlocs(''curry_sphrad1_n28.ced''); ' ...
                          'length(find(ismember({chanlocs.labels},{EEG.chanlocs.labels})))<15;'];
process.savedir        = process.loaddir;
process.savesfx        = '_epoch';

% config file (or struct variable)
cfg_export_alcstress_eeg;
config(1).userinput        = 'recode_alcstress_openclosed; PNSlabels= {''EKG'',''EMG'',''SCL''}; EEG = proc_select(EEG,''nochannel'',PNSlabels); ';
config(5).epoch.events     = {'1','2','3','4'}; % ('all','ALL',[]) or cellstr 
config(5).epoch.winsec     =                     [0 2]; % in sec
%config(5).epoch.events     = {'40' '41' '42' '43' '50' '51' '52' '53' '60' '61' '62' '63'}; % ('all','ALL',[]) or cellstr, or 'task_default' 
%config(5).epoch.winsec     =                     [-0.5 4.5]; % in sec

% run!
EEG = proc_commander(process, config);

