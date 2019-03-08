%%% CONFIGURATION FOR EXPORTING DATA %%%

% -- insert 2-second events
config(1).userinput = '%%PLACE-HOLDER%%';

% -- excise artifact from continuous data
config(2).userinput =  '%EEG = eeg_eegrej(EEG, EEG.reject.rejmanualtimes); %drop for meantime, because likely to throw out shock epochs...';

% -- ICA-spatial-temporal filter
config(3).subcomp.spatial( 1).icwinv = 'blink_ICWINV30Curry.mat';
config(3).subcomp.temporal(1).chans  = {{'VEOG'}; {'FP1'}; {'FP2'}; {'HEOG'}};
config(3).subcomp.spatial( 2).icwinv = 'hem_ICWINV30Curry.mat';
config(3).subcomp.temporal(2).chans  = {{'HEOG'}; {'FT8'}; {'FT7'}; {'VEOG'}};
config(3).subcomp.threshold(1).stat  = 'EM';
config(3).subcomp.threshold(1).crit  =   1 ;

% -- filter
config(4).userinput  = [ ...
 'tmpdata = EEG.data./mean(mad(EEG.data(ismember({EEG.chanlocs.type},''EEG''),:)'',1)); ' ...
 'if ~isempty(find((sum(tmpdata(ismember({EEG.chanlocs.labels},{''FP1'',''FP2'',''F3'',''F4'',''FZ''}),:)''>3)./EEG.pnts)>.10)), ' ...
 '   pop_topoplot(EEG,0,1:size(EEG.icawinv,2)); pop_eegplot(EEG,1,0,0); pop_eegplot(EEG,0,0,0); EEG = pop_subcomp(EEG); close all; ' ...
 'end; ' ...
 'EEG = pop_firws(EEG, ''fcutoff'', 55, ''ftype'', ''lowpass'', ''wtype'', ''kaiser'', ''warg'', 7.85726, ''forder'',88);' ...
 ];

% -- epoch
config(5).epoch.events =          'all'; % ('all','ALL',[]) or cellstr, or 'task_default' 
config(5).epoch.winsec =     [-1.0 2.0]; % in sec
config(5).epoch.rmbase =             []; % in msec, or 'no'/'NO', or []
config(5).epoch.rdcevt =              1; % reduces out all other events

% -- remove blink channels
config(6).userinput = 'EEG = proc_select(EEG,''nochannel'',{''VEOG'' ''HEOG''});';

% -- artifact elec-sweeps
config(7).artifact.type         =     'matrix'; % see artifact_channels, thresholder
config(7).artifact.datafilt     =           0 ; % use only non-tagged epochs/channels
config(7).artifact.pthreshchan  =         .75 ; 
config(7).artifact.minchans     =          15 ;
config(7).artifact.rejchan      =           1 ;
config(7).artifact.rejtrial     =           1 ;
config(7).artifact.opts(1).meas =           {    'minvar'}; % salt-bridging, sample-wide
config(7).artifact.opts(1).stat =                { 'abs'};
config(7).artifact.opts(1).crit =                {  [1] };
config(7).artifact.opts(1).joint=                      0 ;
config(7).artifact.opts(2).meas =           {'Vdist-min'}; % salt-bridging, sample-wide
config(7).artifact.opts(2).stat =                { 'abs'};
config(7).artifact.opts(2).crit =                {  [1] };
config(7).artifact.opts(2).joint=                      0 ;

config(8).artifact.type         =     'matrix'; % see artifact_channels, thresholder
config(8).artifact.datafilt     =           0 ; % use only non-tagged epochs/channels
config(8).artifact.pthreshchan  =         .75 ;
config(8).artifact.minchans     =          15 ;
config(8).artifact.rejchan      =           1 ;
config(8).artifact.rejtrial     =           0 ; %usually 1, but shock or startle probe screwed up this
config(8).artifact.opts(1).meas = { 'Vdist-nearest'   'var'}; % large deviation 
config(8).artifact.opts(1).stat = {          'nMAD'  'nMAD'};
config(8).artifact.opts(1).crit = {             [4]     [4]}; 
config(8).artifact.opts(1).joint=                        1 ;
config(8).artifact.opts(2).meas = {         'range' 'fqvar'}; % muscle 
config(8).artifact.opts(2).stat = {          'nMAD'  'nMAD'};
config(8).artifact.opts(2).crit = {             [4]     [4]};
config(8).artifact.opts(2).joint=                        1 ;

%config(10).userinput            = '%compute_ica_multidipfit; %tmprly interp,convt avg-ref,ICA (#ICs=rank(data),in EEG.etc.newica*),dipfit,revert to orig dims & refs'; 

%%% -- interpolation
%config(11).interp.type      =                         'full'; % or 'artifact'
%config(11).interp.montage   = '/labs/mctfr-psyphys/data/public/sburwell/scripts/umnpsychiatry/data_cache/curry29.ced'; % see readlocs
%config(11).interp.interpmaj =                            0  ; % if >50% bad, interp all
%config(11).interp.rejthresh =                          100  ; % lower-bound (pct)
%config(11).interp.rejreject =                            1  ; % reject non-interpolated

