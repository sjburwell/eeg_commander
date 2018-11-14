%%% CONFIGURATION FOR EXPORTING ERP/EEG DATA %%%

% -- recode events (if desired) in run script
config(1).userinput = '%%PLACE-HOLDER%%';

% -- excise artifact from continuous data
config(2).userinput =  'EEG = eeg_eegrej(EEG, EEG.reject.rejmanualtimes);';

% -- ICA-spatial-temporal filter
config(3).subcomp.spatial( 1).icwinv = 'blink_ICWINV67.mat'; % ./misc/ic_templates/blink_ICWINV67.mat
config(3).subcomp.temporal(1).chans  = { ...                -- Blinks
                                       {'Veog+'; 'Veog-'}; %blink: bipolar derivation (Veog+ minus Veog-) #1 preferred
                                       {'Veog+'};          %blink: unipolar derivation                    #2 preferred
                                       { 'FP2';  'Veog-'}; %blink: bipolar derivation (FP2 minus Veog-)   #3 preferred
                                       { 'FP1';  'Veog-'}; % etc.
                                       { 'FPZ';  'Veog-'};
                                       { 'FP2' };
                                       { 'FPZ' };
                                       { 'AF4' };
                                       { 'AF3' }
                                       };
config(3).subcomp.spatial( 2).icwinv = 'hem_ICWINV67.mat'; % ./misc/ic_templates/hem_ICWINV67.mat
config(3).subcomp.temporal(2).chans  = { ...               -- Saccades
                                       {'Heogr'; 'Heogl'}; %saccade: bipolar derivation (Heogr - Heogl)   #1 preferred
                                       {'Heogr'};          %saccade: unipolar derivation                  #2 preferred
                                       {'Heogl'};          % etc.
                                       {   'F8';    'F7'}
                                       };
config(3).subcomp.threshold(1).stat  = 'EM';               %expectation-maximization thresholding (cf. Mognon et al., 2010)
config(3).subcomp.threshold(1).crit  =   1 ;

% -- highpass filter
config(4).userinput  = 'EEG = pop_firws(EEG, ''fcutoff'', 1, ''ftype'', ''highpass'', ''wtype'', ''kaiser'', ''warg'', 7.85726, ''forder'',1286);';

% -- epoch
config(5).epoch.events =         'ALL' ; % ('all','ALL',[]) or cellstr, or 'task_default' 
config(5).epoch.winsec =       [-2   2]; % in sec
config(5).epoch.rmbase =             []; % in msec, or 'no'/'NO', or []
config(5).epoch.rdcevt =              1; % reduces out all other events

% -- remove blink channels
config(6).userinput = 'EEG = pop_select(EEG,''nochannel'',{''Veog+'' ''Veog-'' ''Heogr'' ''Heogl''});';

% -- artifact elec-sweeps
config(7).artifact.type         =     'matrix'; % see artifact_channels, thresholder
config(7).artifact.datafilt     =           0 ; % use only non-tagged epochs/channels
config(7).artifact.pthreshchan  =         .75 ; 
config(7).artifact.minchans     =           1 ;
config(7).artifact.rejchan      =           1 ;
config(7).artifact.rejtrial     =           1 ;
config(7).artifact.opts(1).meas =           {    'minvar'}; % salt-bridging, sample-wide
config(7).artifact.opts(1).stat =                 { 'abs'};
config(7).artifact.opts(1).crit =                 {  [1] };
config(7).artifact.opts(1).joint=                       0 ;
config(7).artifact.opts(2).meas =            {'Vdist-min'}; % salt-bridging, sample-wide
config(7).artifact.opts(2).stat =                 { 'abs'};
config(7).artifact.opts(2).crit =                 {  [1] };
config(7).artifact.opts(2).joint=                       0 ;
config(7).artifact.opts(3).meas = {'Vdist-nearest'  'var'}; % large deviation 
config(7).artifact.opts(3).stat = {          'abs' 'nMAD'};
config(7).artifact.opts(3).crit = {          [100]    [4]};
config(7).artifact.opts(3).joint=                       1 ;
config(7).artifact.opts(4).meas = {       'fqvar' 'range'}; % muscle 
config(7).artifact.opts(4).stat = {        'nMAD'   'abs'};
config(7).artifact.opts(4).crit = {           [4]   [200]};
config(7).artifact.opts(4).joint=                       1 ;

%% -- run AMICA on clean data, compute dipole locations
%config(8).userinput             = 'compute_amica_multidipfit; %tmprly interp,convt avg-ref,ICA (#ICs=rank(data),in EEG.etc.newica*),dipfit,revert to orig dims & refs';
 
%% -- interpolation
%config(8).interp.type      =                         'full'; % or 'artifact'
%config(8).interp.montage   = 'montage10-10_sphrad1_n61.ced'; % see readlocs
%config(8).interp.interpmaj =                            0  ; % if >50% bad, interp all
%config(8).interp.rejthresh =                          100  ; % lower-bound (pct)
%config(8).interp.rejreject =                            1  ; % reject non-interpolated

