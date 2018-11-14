%%% CONFIGURATION FOR IMPORTING PSYCHOPHYS DATA %%%

% standardize elec locations, separate PNS channels from EEG channels
config(1).userinput            = ...
['stdize_chanlocs_32scalp_03PNS; ' ...
 'clear PNSEEG; ' ...
 'PNSlabels= {''EKG'',''EMG'',''SCL''}; '                                                                                                       ...
 'if ~isempty(find(ismember({EEG.chanlocs.labels},PNSlabels))), PNSEEG = pop_select(EEG,  ''channel'',PNSlabels); '                             ...
 '                                                                 EEG = pop_select(EEG,''nochannel'',PNSlabels); '                             ...
 '                                                              PNSEEG.data = PNSEEG.data - repmat(median(PNSEEG.data,2),1,PNSEEG.pnts); end;'  ... 
 'EEG = pop_firws(EEG,''fcutoff'',.1,''ftype'',''highpass'',''wtype'',''kaiser'',''warg'',7.85726,''forder'',1286); '                           ...
 'if exist(''PNSEEG''); EEG.nbchan = EEG.nbchan+PNSEEG.nbchan; EEG.data = [EEG.data; PNSEEG.data]; EEG.chanlocs = [EEG.chanlocs PNSEEG.chanlocs]; end;' ...
];

% -- process preparation 
config(2).preproc.eventtype    = 'proc'; % label for processing triggers
config(2).preproc.eventduration=  1    ; % duration of each contiguous epoch
config(2).preproc.trimends     =  3    ; % trim edges of data (filter/recording artifact) 

config(3).userinput             = [...
 'if ~isempty(find(ismember({EEG.chanlocs.labels},PNSlabels))), PNSEEG = pop_select(EEG,  ''channel'',PNSlabels); '      ...
 '                                                                 EEG = pop_select(EEG,''nochannel'',PNSlabels); end; ' ...
];

% -- artifact electrodes; sample-wide "too big/small"
config(4).artifact.type         =      'matrix'; % see artifact_channels, thresholder
config(4).artifact.datafilt     =            0 ; % use only non-tagged epochs/channels
config(4).artifact.pthreshchan  =          .75 ;
config(4).artifact.minchans     =            1 ;
config(4).artifact.rejchan      =            1 ;
config(4).artifact.rejtrial     =            0 ; 
config(4).artifact.opts(1).meas =    {'minvar'}; % too close to CMS voltage (e.g., electrolyte-bridged, "dead")
config(4).artifact.opts(1).stat =      { 'abs'}; %  *value empirically derived by histogram of channel-medians*
config(4).artifact.opts(1).crit =      {   [2]};
config(4).artifact.opts(1).joint=            0 ;
config(4).artifact.opts(2).meas = {'Vdist-min'}; % inter-electrode electrolyte-bridging
config(4).artifact.opts(2).stat =      { 'abs'}; %  *value empirically derived by histogram of channel-medians*
config(4).artifact.opts(2).crit =      {   [2]};
config(4).artifact.opts(2).joint=            0 ;

config(5).artifact.type         =      'matrix'; % see artifact_channels, thresholder
config(5).artifact.datafilt     =            0 ; % use only non-tagged epochs/channels
config(5).artifact.pthreshchan  =          .75 ;
config(5).artifact.minchans     =            1 ;
config(5).artifact.rejchan      =            1 ;
config(5).artifact.rejtrial     =            0 ;
config(5).artifact.opts(1).meas = {'Vdist-nearest'     'var'}; % too large for system, USE ELECTRICAL DISTANCE INSTEAD!
config(5).artifact.opts(1).stat = {          'abs'     'abs'}; %  *value empirically derived by histogram of channel-medians/means*
config(5).artifact.opts(1).crit = {          [100]    [1000]};
config(5).artifact.opts(1).joint=            1 ;

config(6).artifact.type         =       'epoch'; % see artifact_epochs, thresholder
config(6).artifact.datafilt     =            0 ; % use only non-tagged epochs/channels
config(6).artifact.rejchan      =            0 ;
config(6).artifact.rejtrial     =            0 ;
config(6).artifact.opts(1).meas = {'fqvar'  'range'}; %
config(6).artifact.opts(1).stat = {   'EM'    'abs'}; %
config(6).artifact.opts(1).crit = {    [1]    [200]}; %
config(6).artifact.opts(1).joint=            1 ;

% -- re-reference
config(7).userinput = 'default_reref_alcstress;'; % lab preferences for process re-reference

% -- ICA decomposition
config(8).ica.type     = 'runica'; % only option now
config(8).ica.datafilt =       1 ; % use only clean data for ICA
config(8).ica.opts     = {'extended',1,'verbose','on'};

% -- make continuous, transfer artifact information
config(9).userinput = [ ...
                        'atvec = sum(EEG.reject.rejmanualE)==EEG.nbchan; ' ...
                        'if exist(''PNSEEG''); ' ...
                        '   EEG.nbchan = EEG.nbchan+PNSEEG.nbchan; EEG.data = [EEG.data; PNSEEG.data]; EEG.chanlocs = [EEG.chanlocs PNSEEG.chanlocs]; ' ...
                        '   EEG.reject.rejmanualE = [EEG.reject.rejmanualE; repmat(atvec,PNSEEG.nbchan,1)]; ' ...
                        '   EEG.reject.rejglobalE = [EEG.reject.rejglobalE; repmat(atvec,PNSEEG.nbchan,1)]; ' ...
                        'end; ' ...
                        'EEG.reject.rejmanualtimes = trials2lats(EEG, find(atvec)); ' ...
                        'EEG = eeg_unepoch(EEG); ' ...
                        'EEG = artifact2proc(EEG, atvec);' ]; % mark artifactual epochs, epoch-2-cnt
