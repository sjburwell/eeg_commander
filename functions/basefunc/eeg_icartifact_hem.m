function EEG = eeg_icartifact_hem(EEG, stat, crit);
% EEG = eeg_icartifact_hem(EEG, stat, crit);
% NOTE: this function is deprecated, see its replacement >>help proc_subcomp 
%make sure ICA done!
if isempty(EEG.icaweights)||isempty(EEG.icasphere)
   disp(['No ICA computed for ' EEG.filename '!  Returning EEG variable without manipulations']);
   return
end


%threshold
THRESHOLD(1).stat = stat; THRESHOLD(1).crit = crit;
THRESHOLD(2).stat = stat; THRESHOLD(2).crit = crit;

%spatial component
SPATIAL    = 'hem_ICWINV67.mat';

%temporal component
CRIT_ELECS = [];
if     ~isempty(strmatch('Heogr',{EEG.chanlocs.labels})) && ~isempty(strmatch('Heogl',{EEG.chanlocs.labels}))
    CRIT_ELECS = {'Heogr'; 'Heogl'};
elseif ~isempty(strmatch('Heogr',{EEG.chanlocs.labels})) &&  isempty(strmatch('Heogl',{EEG.chanlocs.labels}))
    CRIT_ELECS = {'Heogr'};
elseif ~isempty(strmatch('Heogl',{EEG.chanlocs.labels})) &&  isempty(strmatch('Heogr',{EEG.chanlocs.labels}))
    CRIT_ELECS = {'Heogl'};
elseif ~isempty(strmatch(   'F8',{EEG.chanlocs.labels})) && ~isempty(strmatch(   'F7',{EEG.chanlocs.labels}))
    CRIT_ELECS = {   'F8';    'F7'};
else
    disp(['   eeg_icartifact_hem; No criterion channel found for ' EEG.filename ', aborting horizontal eye movement correction...']);
    return
end

% first pass
if ~isempty(ic_temporalspatial(EEG, SPATIAL, CRIT_ELECS, THRESHOLD, 0));
    disp([EEG.filename '; threshold(s): [' num2str([THRESHOLD.crit]) ']'])
    ICs = ic_temporalspatial(EEG, SPATIAL, CRIT_ELECS, THRESHOLD, 1);
    disp('Removing independent component...');
    EEG = pop_subcomp(EEG, ICs);
else
    cache_thresh = THRESHOLD;
    THRESHOLD(1).crit = THRESHOLD(1).crit/2;
    THRESHOLD(2).crit = THRESHOLD(2).crit*2;
    if ~isempty(ic_temporalspatial(EEG, SPATIAL, CRIT_ELECS, THRESHOLD, 0));
        disp([EEG.filename '; threshold(s): [' num2str([THRESHOLD.crit]) ']'])
        ICs = ic_temporalspatial(EEG, SPATIAL, CRIT_ELECS, THRESHOLD, 1);
        disp('Removing independent component...');
        EEG = pop_subcomp(EEG, ICs);
    else,
        THRESHOLD = cache_thresh;
        THRESHOLD(1).crit = THRESHOLD(1).crit*2;
        THRESHOLD(2).crit = THRESHOLD(2).crit/2;
        if ~isempty(ic_temporalspatial(EEG, SPATIAL, CRIT_ELECS, THRESHOLD, 0));
            disp([EEG.filename '; threshold(s): [' num2str([THRESHOLD.crit]) ']'])
            ICs = ic_temporalspatial(EEG, SPATIAL, CRIT_ELECS, THRESHOLD, 1);
            disp('Removing independent component...');
            EEG = pop_subcomp(EEG, ICs);
        else, 
            disp([EEG.filename '; no temporal-spatial ICs identified, skipping IC-removal.']);
        end
    end
end
EEG = eeg_checkset(EEG);
