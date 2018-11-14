% NOTE: this function is deprecated, see its replacement >>help proc_subcomp 
%
% eeg_icartifact_blink() - detects and removes blinks, based on ICA
%                          temporospatial correlations
%
% Usage: 
%   >> OUTEEG = eeg_icartifact_blink(INEEG, stat, crit,ICWINV);
%
% Input:
%   INEEG     - input EEG data structure, ICA must be computed
%   stat      - thresholding routine (cellstr); 
%               options: see thresholder()
%   crit      - cutoff for threshold (numeric); 
%               options: see thresholder()
%   ICWINV    - a matfile with a structured variable (recommended!)
%               "ICWINV" containing of two fields defining the spatial
%               characteristics by which to filter out
%                          [.icwinv] = Nx1 component inverse-weights (double) 
%                          [.labels] = Nx1 channel lables (cellstr)
%               Default: "./misc/ic_templates/blink_ICWINV67.mat" based on 67 
%                        channels from Biosemi system, "blink" component 
%                        averaged across 10 participants
%
% ALSO NEED A CHANNEL LIST, or CELLSTR of channel pairs n stuff...
%
% Output: 
%   OUTEEG    - output EEG data structure with blinks removed
%
% See also:
%   ic_temporalspatial
%
% Steve Malone & Scott Burwell, March, 2011
function EEG = eeg_icartifact_blink(EEG, stat, crit);

%make sure ICA done!
if isempty(EEG.icaweights)||isempty(EEG.icasphere)
   disp(['No ICA computed for ' EEG.filename '!  Returning EEG variable without manipulations']);
   return
end

%threshold
THRESHOLD(1).stat = stat; THRESHOLD(1).crit = crit;
THRESHOLD(2).stat = stat; THRESHOLD(2).crit = crit;

%spatial component
SPATIAL    = 'blink_ICWINV67.mat';

%temporal component
CRIT_ELECS = [];
if ~isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&&~isempty(strmatch('Veog-',{EEG.chanlocs.labels}))
    CRIT_ELECS = {'Veog+'; 'Veog-'}
elseif ~isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&&isempty(strmatch('Veog-',{EEG.chanlocs.labels}))
    CRIT_ELECS = {'Veog+'}
elseif isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&&~isempty(strmatch('Veog-',{EEG.chanlocs.labels}))&&~isempty(strmatch('FP2',{EEG.chanlocs.labels})),
    CRIT_ELECS = { 'FP2';  'Veog-'}
elseif isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&&~isempty(strmatch('Veog-',{EEG.chanlocs.labels}))&&~isempty(strmatch('FP1',{EEG.chanlocs.labels})),
    CRIT_ELECS = { 'FP1';  'Veog-'}
elseif isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&&~isempty(strmatch('Veog-',{EEG.chanlocs.labels}))&&~isempty(strmatch('FPZ',{EEG.chanlocs.labels})),
    CRIT_ELECS = { 'FPZ';  'Veog-'}
elseif isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&& isempty(strmatch('Veog-',{EEG.chanlocs.labels}))&&~isempty(strmatch('FP2',{EEG.chanlocs.labels})),
    CRIT_ELECS = { 'FP2' }
elseif isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&& isempty(strmatch('Veog-',{EEG.chanlocs.labels}))&&~isempty(strmatch('FP1',{EEG.chanlocs.labels})),
    CRIT_ELECS = { 'FP1' }
elseif isempty(strmatch('Veog+',{EEG.chanlocs.labels}))&& isempty(strmatch('FP1',{EEG.chanlocs.labels}))  && isempty(strmatch('FP2',{EEG.chanlocs.labels})),
    if ~isempty(strmatch('FPZ',{EEG.chanlocs.labels})),
        CRIT_ELECS = { 'FPZ' }; 
    elseif ~isempty(strmatch('AF4',{EEG.chanlocs.labels})),
        CRIT_ELECS = { 'AF4' };
    elseif ~isempty(strmatch('AF3',{EEG.chanlocs.labels})),
        CRIT_ELECS = { 'AF3' };
    else,
        disp(['   eeg_icartifact_blink; No criterion channel found for ' EEG.filename ', aborting blink correction...']);
        return
    end
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
