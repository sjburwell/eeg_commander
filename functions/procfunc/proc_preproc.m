% proc_preproc() - prepares EEG data structure for subsequent steps of 
%                  processing routine
%
% Usage: 
%   >> OUTEEG = proc_preproc(EEG, varargin);
%
% Inputs:
%   INEEG       - input EEG data structure
%
% Optional inputs:
%   'trimends'      - time (sec) to delete from edges of data.  For purposes
%                     of filter/recording artifact.
%                     default =      3;
%   'eventtype'     - character input, label for inserted contiguous processing triggers
%                     default = 'proc';
%   'eventduration' - length (in sec) of contiguous processing epochs
%                     default =      1;
%
% Outputs:
%   OUTEEG          - output EEG data structure
%
% Scott Burwell, April 2011
%
% See also: pop_select, eeg_regular_triggers, pop_epoch
function EEG = proc_preproc(EEG, varargin);

if nargin<2,
   disp('Insufficient input, abort');
end
if length(varargin)==1,
   args = varargin{:};
else,
   args = struct(varargin);
end
if ~isfield(args,'trimends')||isempty(args.trimends),
    args.trimends = 3;
end
if ~isfield(args,'eventtype')||isempty(args.eventtype),
    args.eventtype = 'proc';
end
if ~isfield(args,'eventduration')||isempty(args.eventduration),
    args.eventduration = 1;
end
EEG = eeg_hist(EEG, ['EEG = ' mfilename '(EEG, ' arg2str(args) ');'] );

% trim ends
if args.trimends>0,
   EEG = pop_select(EEG, 'nopoint', [EEG.pnts-(args.trimends*EEG.srate)  EEG.pnts-1]);
   EEG = pop_select(EEG, 'nopoint', [1                      args.trimends*EEG.srate]);
end

% contiguous processing triggers/epochs
durpts = floor(args.eventduration*EEG.srate);
EEG = eeg_regular_triggers(EEG, durpts, args.eventtype, [], 0);
EEG = pop_epoch(EEG, cellstr(args.eventtype), [0  durpts/EEG.srate]);


