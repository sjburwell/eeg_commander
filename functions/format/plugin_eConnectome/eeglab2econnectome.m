function EEG = eeglab2econnectome(EEG);
eConnectome_path = '/mtfs/shared_apps/eConnectome-V2';
addpath(genpath(eConnectome_path));

% conversion
tmp.name      = EEG.filename;
tmp.type      =   'EEG'     ;
tmp.nbchan    =   EEG.nbchan;
tmp.points    = size(EEG.data,2);
tmp.srate     =   EEG.srate ;
tmp.labeltype =   'standard';
tmp.labels    = {EEG.chanlocs.labels}';
tmp.data      =   EEG.data  ;
tmp.start     =          1  ;
tmp.end       =   EEG.pnts  ;
tmp.dispchans =   EEG.nbchan;
tmp.vidx      = 1:EEG.nbchan;
tmp.bad       =         []  ;
tmp.unit      =        'uV' ;
if strcmp(tmp.labeltype,'standard'),
   tmp.locations = stdLocations(tmp.labels);
   vidx          = ~cellfun(@isempty, {tmp.locations(:).X});
   tmp.vidx      = find(vidx==1);
end; clear vidx
vdata = tmp.data(tmp.vidx,:);
if ~isfield(tmp,'min') | isempty(tmp.min)
    tmp.min = min(min(vdata));
end
if ~isfield(tmp,'max') | isempty(tmp.max)
    tmp.max = max(max(vdata));
end; clear vdata
if isfield(EEG,'event') && ~isempty(EEG.event),
   for ee = 1:length(EEG.event),
       tmp.event(ee).name = EEG.event(ee).type;
       tmp.event(ee).time = EEG.event(ee).latency;
   end; clear ee
end

%cache eeglab fields, excluding data
EEG = rmfield(EEG,'data') ;
tmp.eeglab_fields = EEG   ; clear EEG
EEG = tmp; clear tmp
