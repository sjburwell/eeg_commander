% ic_temporalspatial() - match temporal and spatial features in dataset to input spatial-
%                        template and input channels
%
% Usage:
%   >> [ICs corrvals] = ic_temporalspatial(EEG, spatial, crit_elecs, thrshld, verbose)
%
% Inputs: 
%   EEG        - input EEG data structure
%   spatial    - see proc_subcomp()
%   crit_elecs - see proc_subcomp()
%   thrshld    - see proc_subcomp()
%   verbose    - [0 1] report output (1) or not (0)
%
% Outputs:
%   ICs        - indices of matched IC inverse weights 
%   corrvals   - raw correlation coefficients from spatial (first column) and temporal
%                (second column) matching
%
% Steve Malone & Scott Burwell, March, 2011
function [ICs corrvals] = ic_temporalspatial(EEG, spatial, crit_elecs, thrshld, verbose);

%make sure ICA done!
if isempty(EEG.icaweights)||isempty(EEG.icasphere)
   disp(['No ICA computed for ' EEG.filename '!  Returning EEG variable without manipulations']);
   return
end

%verbose
if ~exist('verbose')||isempty(verbose),
    V = 1;
else,
    V = verbose;
end

%-- load/prep data matrices
if V>0, disp('Preparing data matrices:'); end
Np   = EEG.pnts;
Nc   = EEG.nbchan;
Nt   = EEG.trials;
if length(size(EEG.data))==3, 
   if V>0, disp('  Restructuring data to 2D...'); end
   data = single(reshape(permute(double(EEG.data), [2 3 1]), [Nt*Np Nc])');
else
   data = EEG.data;
end
if V>0, disp('  Computing ICA activations...'); end
icact = EEG.icaweights*EEG.icasphere*data(EEG.icachansind,:);

%-- load/prep spatial component
if isnumeric('spatial'),
   ICWINV = spatial;
elseif ischar('spatial'),
   load(spatial);
end
if size(EEG.icawinv,2)>size(ICWINV.icwinv,1),
   disp('Invalid spatial input, exceeds size of available IC-matrices.');
   return
elseif size(EEG.icawinv,2)<size(ICWINV.icwinv,1),
   if V>0, disp('  Adjusting inverse weights from spatial input to match existing chanlocs...'); end
   rdcidx = find(ismember(ICWINV.labels,{EEG.chanlocs.labels})); % assumes sorted the same, maybe change
   icwinvtemp = ICWINV.icwinv;  clear ICWINV
   ICWINV = icwinvtemp(rdcidx); clear icwinvtemp
else,
   icwinvtemp = ICWINV.icwinv;  clear ICWINV
   ICWINV = icwinvtemp; clear icwinvtemp
end

%-- prepare temporal component
if size(crit_elecs,1)==2&&size(crit_elecs,2)==1, 
   if V>0, disp('  Creating bi-polar data from criterion channels...'); end
   tscrt = data(strmatch(crit_elecs(1),{EEG.chanlocs.labels},'exact'),:)- ...
           data(strmatch(crit_elecs(2),{EEG.chanlocs.labels},'exact'),:);
elseif size(crit_elecs,1)==1&&size(crit_elecs,2)==2,
   if V>0, disp('  Averaging data from criterion channels...'); end
   tscrt = mean([data(strmatch(crit_elecs(1),{EEG.chanlocs.labels},'exact'),:);  ...
                 data(strmatch(crit_elecs(2),{EEG.chanlocs.labels},'exact'),:)]);
elseif size(crit_elecs,1)==1&&size(crit_elecs,2)==1,
   if V>0, disp('  One criterion channel selected, using for temporal feature identification...'); end
   tscrt = data(strmatch(crit_elecs(1),{EEG.chanlocs.labels},'exact'),:);
else
   disp('Criterion electrodes not valid, exiting function.');
end


%%----------------------------------%%
%%-- Spatial-temporal IC-matching --%%
%%----------------------------------%%
if V>0, disp('Joint spatial-temporal IC-feature matching:'); end

%-- Spatial-IC matching
if V>0, disp('  Spatial feature matching; IC-weight correlations'); end
Sr = corr(ICWINV, EEG.icawinv)';
corrvals = Sr;
Sr = abs(atanh(Sr)); %Switched to absolute on 9/28/14, SJB %Sr = Sr.^2; %added 5/23/12
[Sr, Scrit] = thresholder(thrshld(1).stat, Sr, thrshld(1).crit);

%-- Temporal-IC matching
if V>0, disp('  Temporal feature matching; IC-activation, EEG time-series correlations'); end
% blink samples
EVENTZ  = 3; 
Ztscrt  = (tscrt-mean(tscrt)) ./ std(tscrt);
blink_samples = find(abs(Ztscrt)>=EVENTZ)';
plusminus = [-.125, .125];
padding = round(plusminus(1)*EEG.srate):round(plusminus(2)*EEG.srate);
blink_samples = repmat(blink_samples,[1 length(padding)]) + repmat(padding,[length(blink_samples), 1]);
blink_samples = unique(blink_samples)'; 
blink_samples(blink_samples<1) = ''; blink_samples(blink_samples>length(Ztscrt)) = '';

% correlate
if ~isempty(blink_samples)
  Tr = corr( icact(:,logical(blink_samples))', tscrt(logical(blink_samples))' );
  corrvals = [corrvals Tr];
  Tr = abs(atanh(Tr)); %Switched to absolute on 9/28/14, SJB %Tr = Tr.^2; %added 5/23/12
  [Tr, Tcrit] = thresholder(thrshld(2).stat, Tr, thrshld(2).crit);
  ICs = intersect(find(abs(Sr)>abs(Scrit)), find(abs(Tr)>abs(Tcrit)))';
  if V>0, disp(['Spatial-temporal ICs matched: ' num2str(ICs)]); end
else
  if V>0, disp('No temporal-event samples identified, aborting spatial-temporal IC-matching.'); end
  ICs = []; corrvals = []; 
end


