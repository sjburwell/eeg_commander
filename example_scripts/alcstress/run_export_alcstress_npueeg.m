clear

% process/CRIT VARS
process.name           = mfilename;
process.loaddir        = '/labs/burwellstudy/projects/testing-eeg-toolbox/output_data/';
process.loadflt        = '*cnt.set';
process.loadpop        = 1;
process.logfile        = 1;
process.abortif        = ['chanlocs = readlocs(''curry_sphrad1_n28.ced''); ' ...
                          'length(find(ismember({chanlocs.labels},{EEG.chanlocs.labels})))<15;'];
process.savedir        = process.loaddir;
process.savesfx        = '_epoch_npueeg';

% config file (or struct variable)
cfg_export_alcstress_eeg;
config(1).userinput        = 'recode_npu; PNSlabels= {''EKG'',''EMG'',''SCL''}; EEG = proc_select(EEG,''nochannel'',PNSlabels); ';
config(5).epoch.events     = {'40' '41' '42' '43' '50' '51' '52' '53' '60' '61' '62' '63'}; % ('all','ALL',[]) or cellstr, or 'task_default' 
config(5).epoch.winsec     =                     [-0.5 4.5]; % in sec
config(9).interp.type      =                     'artifact'; % 'full' or 'artifact'
config(9).interp.montage   =        'curry_sphrad1_n28.ced'; % see readlocs
config(9).interp.interpmaj =                            0  ; % if >50% bad, interp all
config(9).interp.rejthresh =                          100  ; % lower-bound (pct)
config(9).interp.rejreject =                            1  ; % reject non-interpolated

% run!
EEG = proc_commander(process, config);

