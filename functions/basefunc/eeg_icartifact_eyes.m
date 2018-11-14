function EEG = eeg_icartifact_eyes(EEG, stat, crit);
% EEG = eeg_icartifact_eyes(EEG, stat, crit);
% NOTE: this function is deprecated, see its replacement >>help proc_subcomp 
%make sure ICA done!
if isempty(EEG.icaweights)||isempty(EEG.icasphere)
   disp(['No ICA computed for ' EEG.filename '!  Returning EEG variable without manipulations']);
   return
end

%
%
%
% ------------------------- Vertical Ocular Movement ----------------------
%
%
%

%threshold
THRESHOLD(1).stat = stat; THRESHOLD(1).crit = crit;
THRESHOLD(2).stat = stat; THRESHOLD(2).crit = crit;

%spatial component
SPATIAL    = 'blink_ICWINV67.mat';

%temporal component
CRIT_ELECS = [];
if ~isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&&~isempty(strmatch('Veog-',{EEG.chanlocs.labels}))
    CRIT_ELECS = {'Veog+'; 'Veog-'};
elseif ~isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&&isempty(strmatch('Veog-',{EEG.chanlocs.labels}))
    CRIT_ELECS = {'Veog+'};
elseif isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&&~isempty(strmatch('Veog-',{EEG.chanlocs.labels}))&&~isempty(strmatch('FP2',{EEG.chanlocs.labels})),
    CRIT_ELECS = { 'FP2';  'Veog-'};
elseif isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&&~isempty(strmatch('Veog-',{EEG.chanlocs.labels}))&&~isempty(strmatch('FP1',{EEG.chanlocs.labels})),
    CRIT_ELECS = { 'FP1';  'Veog-'};
elseif isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&&~isempty(strmatch('Veog-',{EEG.chanlocs.labels}))&&~isempty(strmatch('FPZ',{EEG.chanlocs.labels})),
    CRIT_ELECS = { 'FPZ';  'Veog-'};
elseif isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&& isempty(strmatch('Veog-',{EEG.chanlocs.labels}))&&~isempty(strmatch('FP2',{EEG.chanlocs.labels})),
    CRIT_ELECS = { 'FP2' };
elseif isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&& isempty(strmatch('Veog-',{EEG.chanlocs.labels}))&&~isempty(strmatch('FP1',{EEG.chanlocs.labels})),
    CRIT_ELECS = { 'FP1' };
elseif isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&& isempty(strmatch('FP1',{EEG.chanlocs.labels}))  && isempty(strmatch('FP2',{EEG.chanlocs.labels})),
    if ~isempty(strmatch('FPZ',{EEG.chanlocs.labels})),
        CRIT_ELECS = { 'FPZ' }; 
    elseif ~isempty(strmatch('AF4',{EEG.chanlocs.labels})),
        CRIT_ELECS = { 'AF4' };
    elseif ~isempty(strmatch('AF3',{EEG.chanlocs.labels})),
        CRIT_ELECS = { 'AF3' };
    else,
        disp(['   eeg_icartifact_eyes; No criterion channel found for ' EEG.filename ', aborting blink correction...']);
        return
    end
end
[ICs, blink_corrs] = ic_temporalspatial(EEG, SPATIAL, CRIT_ELECS, THRESHOLD, 0);

%
%
%
% ------------------------- Horizontal Ocular Movement ----------------------
%
%
%

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
    disp(['   eeg_icartifact_eyes; No criterion channel found for ' EEG.filename ', aborting horizontal eye movement correction...']);
    return
end
[ICs, hem_corrs] = ic_temporalspatial(EEG, SPATIAL, CRIT_ELECS, THRESHOLD, 0);



%
%
%
% ------------------------- Just do it. ----------------------
%
%
%

eyespace  = abs(atanh([blink_corrs(:,1); hem_corrs(:,1)]));
[spacemeas,spacecrit] = thresholder(stat, eyespace, crit);

eyetime   = abs(atanh([blink_corrs(:,2); hem_corrs(:,2)])); 
[timemeas ,timecrit ] = thresholder(stat, eyetime , crit);

all_ics = [1:length(EEG.icawinv), 1:length(EEG.icawinv)];
if ~isempty(intersect(find(spacemeas>spacecrit),find(timemeas>timecrit)));
    disp([EEG.filename '; threshold(s): [' num2str([THRESHOLD.crit]) ']'])
    ICs = all_ics(intersect(find(spacemeas>spacecrit),find(timemeas>timecrit)));
    ICs = unique(ICs);
    disp(['Spatial-temporal ICs matched: ' num2str(ICs)]);
    disp('Removing independent component...');
    EEG = pop_subcomp(EEG, ICs);
else
    [spacemeas,spacecrit] = thresholder(stat, eyespace, crit/2);
    [timemeas ,timecrit ] = thresholder(stat, eyetime , crit*2);
    if ~isempty(intersect(find(spacemeas>spacecrit),find(timemeas>timecrit)));
        disp([EEG.filename '; threshold(s): [' num2str([crit/2 crit*2]) ']'])
        ICs = all_ics(intersect(find(spacemeas>spacecrit),find(timemeas>timecrit)));
        ICs = unique(ICs);
        disp(['Spatial-temporal ICs matched: ' num2str(ICs)]);
        disp('Removing independent component...');
        EEG = pop_subcomp(EEG, ICs);
    else,
        [spacemeas,spacecrit] = thresholder(stat, eyespace, crit*2);
        [timemeas ,timecrit ] = thresholder(stat, eyetime , crit/2);
        if ~isempty(intersect(find(spacemeas>spacecrit),find(timemeas>timecrit)));
            disp([EEG.filename '; threshold(s): [' num2str([crit*2 crit/2]) ']'])
            ICs = all_ics(intersect(find(spacemeas>spacecrit),find(timemeas>timecrit)));
            ICs = unique(ICs);
            disp(['Spatial-temporal ICs matched: ' num2str(ICs)]);
            disp('Removing independent component...');
            EEG = pop_subcomp(EEG, ICs);
        else,
            disp([EEG.filename '; no temporal-spatial ICs identified, skipping IC-removal.']);
        end
    end
end
EEG = eeg_checkset(EEG);
