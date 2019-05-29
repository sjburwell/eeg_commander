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
%                          'channel'  = just artifact or missing full channels (i.e., not chan-epochs)
%
% Additional inputs ('key','val'):
%   'montage'   - file containing channel labels/locations.  
%                 If 'type'=='full', required as input.
%                 options: >> help readlocs()
%   'interpmaj' - if a channel is marked as artifact for >P% of time, 
%                 interpolate totally. P defined in "rejpctbad" below (default: 50%)
%                 options: yes = 1 (default); 
%                          no  = 0;
%   'rejpctbad' - maximum percent of time (epochs) for a given channel marked as artifact
%                 allowed before interpolating the whole thing
%                 options: integer value between 0 and 100,
%                          default = 50;
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
elseif ~isempty(strmatch('channel',args.type)),
   intfull = 0;
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
if ~isfield(args,'rejpctbad')||isempty(args.rejpctbad),
    args.rejpctbad = 50;
end
if ~isfield(args,'rejreject')||isempty(args.rejreject),
    args.rejreject =  0;
end

if args.rejthresh>50, 
   disp('   proc_interp;  resetting rejthresh to 50, cannot interpolate >50% of channels'); 
   args.rejthresh = 50;
end

% initiate interpE
if length(size(EEG.data))==3,
  EEG = eeg_rejsuperpose(EEG,1,1,1,1,1,1,1,1);
  if isempty(find(EEG.reject.rejglobalE)),
     interpE = zeros([EEG.nbchan  EEG.trials]);
  else,
     interpE = EEG.reject.rejglobalE;
  end
else 
  if isempty(find(EEG.reject.rejglobalE)) || size(EEG.reject.rejglobalE,2)==size(EEG.data,2),
     EEG = eeg_checkset(rmfield(EEG,'reject'));
     interpE = zeros([EEG.nbchan EEG.trials]);
  end
end

% whole-channel; total recode if >% artifact
if args.interpmaj>0,
   %recode1 = find(sum(interpE')>((args.rejpctbad/100)*EEG.trials));
   recode1 = find(sum(EEG.reject.rejglobalE')>((args.rejpctbad/100)*EEG.trials)); %changed 12-27-18 to accommodate the 'type'=='channel' option
   if ~isempty(recode1), interpE(recode1,:) = ''; EEG = proc_select(EEG,'nochannel',recode1); end
   %if ~isempty(recode1),
   %    interpE(recode1,:) = 1;
   %end
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
MISCHANS = find(~ismember({EEG.chanlocs.labels},{chanlocs.labels}));   % SJB 2019-05-13, in case of extra non-interpolated channels not in XSTCHANS
if ~isempty(find(interpE)) && ismember(args.type,{'full','artifact'}), % SJB 2019-01-22
   EEG = eeg_interp3d_spl(EEG, interpE); %chan-epoch
end

if ~isempty(ADDCHANS),
   EEG = eeg_interp(EEG, chanlocs); %whole-channel
   newE  = zeros(length(chanlocs), size(interpE,2));
   if ~isempty(MISCHANS), 
      interpEmis       = interpE(MISCHANS,:); 
      interpE(MISCHANS,:) = ''; 
   end
   newE(XSTCHANS,:) = interpE;
   newE(ADDCHANS,:) =       1;
   if ~isempty(MISCHANS), 
      newE = [newE; interpEmis];
      EEG.data     = [EEG.data;     EEG.data(1:length(MISCHANS),:,:)];
      EEG.data(1:length(MISCHANS),:,:) = '';
      EEG.chanlocs = [EEG.chanlocs EEG.chanlocs(1:length(MISCHANS))];
      EEG.chanlocs(1:length(MISCHANS)) = '';
   end
   interpE = newE;
end

% reject/interp accounting 
if ~isempty(find(rejT))&&args.rejreject==1,
   EEG = proc_select(EEG, 'notrial', find(rejT));
   EEG.reject.rejmanualE   = interpE(:,find(rejT==0));
   EEG.reject.rejmanual(find(sum(EEG.reject.rejmanualE))) = 1; % = find(sum(EEG.reject.rejmanualE)); 2019-03-06 SJB
   EEG.reject.rejmanualcol = [0.5 0.5 0.5];  
   EEG.reject.rejglobalE   = EEG.reject.rejmanualE;
   EEG.reject.rejglobal    = EEG.reject.rejmanual;
else,
   EEG.reject.rejglobal  =                 rejT;
   EEG.reject.rejglobalE =              interpE;
   EEG.reject.rejmanual(find(sum(interpE))) = 1; 
   EEG.reject.rejmanualE =              interpE;
   EEG.reject.rejmanualcol = [0.5 0.5 0.5];

   EEG.reject.rejmanual(   find(rejT)) = 1;
   EEG.reject.rejmanualE(:,find(rejT)) = 1;
   EEG.reject.rejglobal(   find(rejT)) = 1;
   EEG.reject.rejglobalE(:,find(rejT)) = 1;
end


