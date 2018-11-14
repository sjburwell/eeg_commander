%%% CONFIGURATION FOR IMPORTING ERP/EEG DATA %%%

% -- process preparation 
config(1).preproc.eventtype    = 'proc'; % label for processing triggers
config(1).preproc.eventduration=  1    ; % duration of each contiguous epoch
config(1).preproc.trimends     =  3    ; % trim edges of data (filter/recording artifact) 

% -- artifact electrodes; sample-wide "too big/small"
config(2).artifact.type         =      'matrix'; % see artifact_channels, thresholder
config(2).artifact.datafilt     =            0 ; % use only non-tagged epochs/channels
config(2).artifact.pthreshchan  =          .75 ;
config(2).artifact.minchans     =            1 ;
config(2).artifact.rejchan      =            1 ;
config(2).artifact.rejtrial     =            0 ; 
config(2).artifact.opts(1).meas =    {'minvar'}; % too close to CMS voltage (e.g., electrolyte-bridged, "dead")
config(2).artifact.opts(1).stat =      { 'abs'}; %  *value empirically derived by histogram of channel-medians*
config(2).artifact.opts(1).crit =      {   [2]};
config(2).artifact.opts(1).joint=            0 ;

config(3).artifact.type         =      'matrix'; % see artifact_channels, thresholder
config(3).artifact.datafilt     =            0 ; % use only non-tagged epochs/channels
config(3).artifact.pthreshchan  =          .75 ;
config(3).artifact.minchans     =            1 ;
config(3).artifact.rejchan      =            1 ;
config(3).artifact.rejtrial     =            0 ;
config(3).artifact.opts(1).meas = {'Vdist-min'}; % inter-electrode electrolyte-bridging
config(3).artifact.opts(1).stat =      { 'abs'}; %  *value empirically derived by histogram of channel-medians*
config(3).artifact.opts(1).crit =      {   [2]};
config(3).artifact.opts(1).joint=            0 ;

config(4).artifact.type         =      'matrix'; % see artifact_channels, thresholder
config(4).artifact.datafilt     =            0 ; % use only non-tagged epochs/channels
config(4).artifact.pthreshchan  =          .75 ;
config(4).artifact.minchans     =            1 ;
config(4).artifact.rejchan      =            1 ;
config(4).artifact.rejtrial     =            0 ;
config(4).artifact.opts(1).meas = {'Vdist-nearest'     'var'}; % too large for system, USE ELECTRICAL DISTANCE INSTEAD!
config(4).artifact.opts(1).stat = {          'abs'     'abs'}; %  *value empirically derived by histogram of channel-medians/means*
config(4).artifact.opts(1).crit = {          [100]    [1000]};
config(4).artifact.opts(1).joint=            1 ;

config(5).artifact.type         =       'epoch'; % see artifact_epochs, thresholder
config(5).artifact.datafilt     =            0 ; % use only non-tagged epochs/channels
config(5).artifact.rejchan      =            0 ;
config(5).artifact.rejtrial     =            0 ;
config(5).artifact.opts(1).meas = {'fqvar' 'range'}; %
config(5).artifact.opts(1).stat = {   'EM'   'abs'}; %
config(5).artifact.opts(1).crit = {    [1]   [200]};
config(5).artifact.opts(1).joint=            1 ;

% -- re-reference
config(6).userinput = 'default_reref_mctfr'; % lab preferences for process re-reference

% -- ICA decomposition
config(7).ica.type     = 'runica'; % only option now
config(7).ica.datafilt =       1 ; % use only clean data for ICA
config(7).ica.opts     = {'extended',1,'verbose','on'};

% -- make continuous, transfer artifact information
config(8).userinput = ['EEG.reject.rejmanualtimes = trials2lats(EEG, find(sum(EEG.reject.rejmanualE)==EEG.nbchan)); ' ...
                       'EEG = eeg_unepoch(EEG);' ...
                       'atvec = sum(EEG.reject.rejmanualE)==EEG.nbchan; EEG = artifact2proc(EEG, atvec);' ]; % mark artifactual epochs, epoch-2-cnt
