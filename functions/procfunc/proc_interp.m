% proc_interp - interpolate artifact or missing data using EEGLAB's
%               spherical-spline interpolation
%
% Usage:
%   >> OUTEEG = proc_interp(INEEG, varargin);
%
% Inputs:
%   INEEG       - input EEG data structure
%   'type'      - interpolate just artifact ('artifact'; i.e. EEG.reject.*TYPE*E==1) 
%                 and/or restore full channel montage. *REQUIRED INPUT*
%                 options: 'full'     = total montage restored and artifact corrected
%                          'artifact' = just artifact indices interpolated
%
% Additional inputs ('key','val'):
%   'montage'   - file containing channel labels/locations.  
%                 If 'type'=='full', required as input.
%                 options: >> help readlocs()
%   'interpmaj' - if a channel is marked as artifact for majority of dataset, 
%                 interpolate totally.
%                 options: yes = 1 (default); 
%                          no  = 0;
%   'rejthresh' - maximum percent of channels within an epoch before skipping 
%                 and tagging epoch as artifact
%                 options: integer value between 0 and 100, 
%                          default = 25; (Tenke et al., 2010, Psyphys., 47)
%   'rejreject' - delete skipped epochs from 'rejthresh'
%                 options: yes = 1; 
%                          no  = 0 (default);
%
% Outputs:
%   OUTEEG      - output EEG data structure
%
% Scott Burwell, July 2011
% 
% See also: eeg_interp3d_spl, eeg_interp
function EEG = proc_interp(EEG, varargin);

if nargin<2,
   disp('Insufficient input, abort');
   return
end
if length(varargin)==1,
   args = varargin{:};
else,
   args = struct(varargin);
end
EEG = eeg_hist(EEG, ['EEG = ' mfilename '(EEG, ' arg2str(args) ');'] );

% vitals
if ~isfield(args,'type'),
    disp('Required field "type" not defined.');
    return
elseif isempty(strmatch('full',args.type))&&(~isfield(args,'montage')||isempty(args.montage)),
    disp('Argument "montage" is required when args.type is set "full".');
    return
end

% type
if ~isempty(strmatch('full',args.type)),
   intfull  = 1;
   if exist(args.montage,'file'),
      chanlocs = readlocs(args.montage); if isempty(chanlocs), disp('  chanlocs invalid!'); end
      fldiff = setdiff(fieldnames(chanlocs), fieldnames(EEG.chanlocs));
      if ~isempty(fldiff),
         for ff = 1:length(fldiff),
             chanlocs = rmfield(chanlocs, fldiff{ff});
         end
      end
   else
      disp(['Cannot find file: ' args.montage]);
      return
   end
elseif ~isempty(strmatch('artifact',args.type)),
   intfull = 0;
   chanlocs = EEG.chanlocs;
end
   
% other
if ~isfield(args,'interpmaj')||isempty(args.interpmaj),
    args.interpmaj =  1;
end
if ~isfield(args,'rejthresh')||isempty(args.rejthresh),
    args.rejthresh = 25;
end
if ~isfield(args,'rejreject')||isempty(args.rejreject),
    args.rejreject =  0;
end

% initiate interpE
EEG = eeg_rejsuperpose(EEG,1,1,1,1,1,1,1,1);
%EEG = eeg_hist(EEG, 'EEG = eeg_rejsuperpose(EEG,1,1,1,1,1,1,1,1);');
if isempty(find(EEG.reject.rejglobalE))&&intfull==0,
   disp('Rejected channels empty, abort operation');
   return
elseif isempty(find(EEG.reject.rejglobalE))&&intfull==1,
   interpE = zeros([EEG.nbchan  EEG.trials]);
else,
   interpE = EEG.reject.rejglobalE;
end

% whole-channel; total recode if >50% artifact
if args.interpmaj>0,
   recode1 = find(sum(interpE')>(.5*EEG.trials));
   if ~isempty(recode1),
       interpE(recode1,:) = 1;
   end
end

% channel-epoch; skip trial if >*pct* w/ in trial artifact, output: rejT
recode2 = find(sum(interpE)>=((args.rejthresh/100)*length(chanlocs))); %SJB 2018-09-05, ">" --> ">="
if ~isempty(recode2),
    interpE(:,recode2) = 0;
    rejT = zeros(1, EEG.trials);
    rejT(recode2) = 1;
else
    rejT = zeros(1, EEG.trials);
end

% interpolate
XSTCHANS = find( ismember({chanlocs.labels},{EEG.chanlocs.labels}));
ADDCHANS = find(~ismember({chanlocs.labels},{EEG.chanlocs.labels}));
if ~isempty(find(interpE)),
   EEG = eeg_interp3d_spl(EEG, interpE); %chan-epoch
   %EEG = eeg_hist(EEG, 'EEG = eeg_interp3d_spl(EEG, EEG.reject.rejglobalE)');
end
if ~isempty(ADDCHANS),
   EEG = eeg_interp(EEG, chanlocs); %whole-channel
   %EEG = eeg_hist(EEG, 'EEG = eeg_interp(EEG, args.montage);');
   newE  = zeros(length(chanlocs), size(interpE,2));
   newE(XSTCHANS,:) = interpE;
   newE(ADDCHANS,:) =       1;
   interpE = newE;
end

% reject/interp accounting 
if ~isempty(find(rejT))&&args.rejreject==1,
   EEG = pop_select(EEG, 'notrial', find(rejT));
   EEG.reject.rejmanualE   = interpE(:,find(rejT==0));
   EEG.reject.rejmanual    = find(sum(EEG.reject.rejmanualE));
   EEG.reject.rejmanualcol = [0.5 0.5 0.5];  
else,
   EEG.reject.rejglobal  =                 rejT;
   EEG.reject.rejglobalE =              interpE;
   EEG.reject.rejmanual(find(sum(interpE))) = 1; 
   EEG.reject.rejmanualE =              interpE;
end


