% proc_subcomp() - ICA-based artifact removal for the processing stream. Utilizes
%                  lower-level functions ic_temporalspatial and thresholder. Requires 
%                  that ICA has been run on the dataset prior to initiation, and ICA
%                  weights are stored in EEG.icaweights and EEG.icasphere. This function
%                  computes correlations of obtained spatial (channel inverse weights)
%                  and temporal (component time-series) features with those from 
%                  stereotyped artifacts identified by the user (e.g., group mean blink
%                  component). It is built to handle simultaneous matching of multiple 
%                  types of artifacts (e.g., horizontal and vertical EOG artifacts in 
%                  one step). Artifacts that are identified are subsequently removed
%                  within the function and retured in OUTEEG.
%                         
%
% Usage:
%   >> OUTEEG = proc_subcomp(INEEG, args);
%  
% Inputs:
%   INEEG      - input EEG data structure
%
% Arguments (as structured variable):
%   'spatial'  - (required) 1xN struct array, where N corresponds to the N stereotyped
%                artifacts to be detected. This field currently requires 1 subfield:
%                [.icwinv] = string that points to an existing mat-file which defines 
%                the spatial properties of the artifact to be matched. The mat-file 
%                should contain two subfields:
%                          [.icwinv] = Lx1 component inverse-weights (double) 
%                          [.labels] = Lx1 channel lables (cellstr)
%                                      NB: L needn't be equal to EEG.nbchan
%   'temporal' - (required) 1xN struct array, where N corresponds to the N stereotyped
%                artifacts to be detected. Should contain a cell array of channel labels 
%                (or channel-pair labels) in order of most- to least-preferred for temporal
%                matching. Within each element of CHAN_TS, there may be Kx1 options for 
%                individual channels (to be used as unipolar) and paired channels (to be 
%                used as bipolar). (See below example.)
%   'threshold'- (required) 1x1 struct array, must have two subfields:
%                          [.stat] = thresholding routine (cellstr); 
%                                    options: see thresholder()
%                          [.crit] = cutoff for threshold (numeric); 
%                                    options: see thresholder()
%   'trymore'  - (optional) if "no", only the user-specified threshold is used and frequently
%                returns no artifacts detected; if "yes", the function will try two alternative
%                cutoffs if no artifacts are detected by the user-specified threshold.
%                0 = no 
%                1 = yes (default)
%
% Outputs:
%   OUTEEG     - output EEG data structure
%
% See also: ic_temporalspatial, thresholder, eeg_icartifact_eyes
%
% EXAMPLE:
% args.spatial(1).icwinv = 'blink_ICWINV67.mat';
% args.spatial(2).icwinv = 'hem_ICWINV67.mat';
% args.temporal(1).chans = { ...                      % N{1} = blinks
% {'Veog+'; 'Veog-'};                   %blink: bipolar derivation (Veog+ minus Veog-) #1 preferred
% {'Veog+'};                            %blink: unipolar derivation                    #2 preferred
% { 'FP2';  'Veog-'};                   %blink: bipolar derivation (FP2 minus Veog-)   #3 preferred
% { 'FP1';  'Veog-'};                   % etc.
% { 'FPZ';  'Veog-'};
% { 'FP2' };
% { 'FPZ' };
% { 'AF4' };
% { 'AF3' }
% };
% args.temporal(2).chans = { ...                              % N{2} = saccades
% {'Heogr'; 'Heogl'};                   %saccade: bipolar derivation (Heogr - Heogl)   #1 preferred
% {'Heogr'};                            %saccade: unipolar derivation                  #2 preferred
% {'Heogl'};                            % etc.
% {   'F8';    'F7'}
% };
% args.threshold.stat = 'EM';
% args.threshold.crit =   1 ;
% OUTEEG = proc_subcomp(INEEG, args); %run the function!
%
% Developed by Scott Burwell & Steve Malone, March, 2011; re-wrapped eeg_icartifact_eyes into this
%    function (proc_subcomp) by Scott Burwell to more flexibly handle different datasets and 
%    stereotyped artifacts (2018-11-07).
function EEG = proc_subcomp(EEG, args);

if isempty(EEG.icaweights)||isempty(EEG.icasphere)
   disp(['No ICA computed for ' EEG.filename '!  Returning EEG variable without manipulations']);
   return
end
if ~isfield(args,'trymore'),
  args.trymore = 1;
end

args2hist = [];
for aa = 1:length(args.spatial),
  args2hist = [args2hist, [arg2str(args.spatial(aa)) ',' arg2str(args.temporal(aa)) ',' arg2str(args.threshold(1)) ',']];
end
args2hist = [args2hist, arg2str(args)];
EEG = eeg_hist(EEG, ['EEG = ' mfilename '(EEG, ' args2hist ');'] );

temp_spat_corrs = [];
for ii = 1:length(args.spatial),
  %spatial component
  SPATIAL    = args.spatial(ii).icwinv;

  %temporal component
  CRIT_ELECS = [];
  for jj = 1:length(args.temporal(ii).chans),
    if length(find(ismember({EEG.chanlocs.labels},args.temporal(ii).chans{jj})))==length(args.temporal(ii).chans{jj}) && ...
       isempty(CRIT_ELECS),
      CRIT_ELECS = args.temporal(ii).chans{jj};
    end
  end
  if isempty(CRIT_ELECS), 
    disp(['   eeg_icartifact_eyes; No criterion channel found for ' EEG.filename ', aborting blink correction...']);
    return
  end

  %threshold; here, actually does only a temporary thresholding, not used for final exclusion
  THRESHOLD(1).stat = args.threshold(1).stat; THRESHOLD(1).crit = args.threshold(1).crit;
  THRESHOLD(2).stat = args.threshold(1).stat; THRESHOLD(2).crit = args.threshold(1).crit;

  [~, corrs] = ic_temporalspatial(EEG, SPATIAL, CRIT_ELECS, THRESHOLD, 0);
  temp_spat_corrs = cat(3,temp_spat_corrs,corrs);
end

%
% combine spatial correlations, combine temporal correlations, do a single thresholding
%

space  = abs(atanh(  reshape(temp_spat_corrs(:,1,:),[prod(size(temp_spat_corrs(:,1,:))) 1]) ));
time   = abs(atanh(  reshape(temp_spat_corrs(:,2,:),[prod(size(temp_spat_corrs(:,2,:))) 1]) ));
[spacemeas,spacecrit] = thresholder(args.threshold(1).stat, space, args.threshold(1).crit);
[timemeas ,timecrit ] = thresholder(args.threshold(1).stat, time , args.threshold(1).crit);

all_ics = repmat([1:length(EEG.icawinv)],[1,length(args.spatial)]);
if ~isempty(intersect(find(spacemeas>spacecrit),find(timemeas>timecrit)));
    disp([EEG.filename '; threshold(s): [' num2str([THRESHOLD.crit]) ']'])
    ICs = all_ics(intersect(find(spacemeas>spacecrit),find(timemeas>timecrit)));
    ICs = unique(ICs);
    disp(['Spatial-temporal ICs matched: ' num2str(ICs)]);
    disp('Removing independent component...');
    EEG = pop_subcomp(EEG, ICs);
else
   if args.trymore==0,
      disp([EEG.filename '; no temporal-spatial ICs identified, skipping IC-removal.']);
      return
   else,
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
end
EEG = eeg_checkset(EEG);
