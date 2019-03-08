%%% CONFIGURATION FOR EXPORTING DATA %%%

% -- insert 2-second events
config(1).userinput = '%%PLACE-HOLDER%%';

% -- excise artifact from continuous data
config(2).userinput =  '%EEG = eeg_eegrej(EEG, EEG.reject.rejmanualtimes); %drop for meantime, because likely to throw out shock epochs...';

% -- filter
config(3).userinput  = [ ...
 'EEG = pop_firws(EEG, ''fcutoff'', 30, ''ftype'', ''highpass'', ''wtype'', ''kaiser'', ''warg'', 7.85726, ''forder'',1286);';
 ];

% -- epoch
config(4).epoch.events =          'all'; % ('all','ALL',[]) or cellstr, or 'task_default' 
config(4).epoch.winsec =     [-1.0 2.0]; % in sec
config(4).epoch.rmbase =             []; % in msec, or 'no'/'NO', or []
config(4).epoch.rdcevt =              1; % reduces out all other events

config(5).artifact.type         =     'matrix'; % see artifact_channels, thresholder
config(5).artifact.datafilt     =           0 ; % use only non-tagged epochs/channels
config(5).artifact.pthreshchan  =         .75 ;
config(5).artifact.minchans     =           1 ;
config(5).artifact.rejchan      =           1 ;
config(5).artifact.rejtrial     =           0 ; 
config(5).artifact.opts(1).meas =   { 'range' 'Vmedian'}; % large deviation 
config(5).artifact.opts(1).stat =   {  'nMAD'    'nMAD'};
config(5).artifact.opts(1).crit =   {     [2]       [2]}; 
config(5).artifact.opts(1).joint=           1 ;
