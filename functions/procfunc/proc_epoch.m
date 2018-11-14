% proc_epoch() - epoch about task-specific events and remove epoch baselines (optional)
%
% Usage:
%   >> OUTEEG = proc_epoch(INEEG, varargin);
%
% Inputs:
%   INEEG     - input EEG dataset
%   'events'  - specify events to epoch around
%                 ['ALL'|'all']  = unique({EEG.event.type}); (default)
%                 'task_default' = lab defaults (coded here function as cellstr; uses EEG.condition)
%                 INPUT_EVTS     = cellstr of event types
%   'winsec'  - [min  max] time (in sec) to epoch peri-event
%
% Optional inputs ('key','val'):
%   'rdcevt'  - reduce event field to 'events' only
%   'rmbase'  - [min  max] time (in msec) for mean-removal, 0=none (default) 
%               *see pop_rmbase() for min/max params
%
% Scott Burwell, June 2011
%
% See also: proc_epoch, pop_epoch, pop_rmbase
function EEG = proc_epoch(EEG, varargin);

if nargin<2,
   disp('Insufficient input, abort');
end
if length(varargin)==1,
   args = varargin{:};
else,
   args = struct(varargin);
end
EEG = eeg_hist(EEG, ['EEG = ' mfilename '(EEG, ' arg2str(args) ');'] );

if isfield(args,'events')&&~isempty(args.events),
   if  iscellstr(args.events)&&~isempty(ismember({EEG.event.type}, args.events)),
       eventtypes = args.events;
       eventtypes = strtrim(eventtypes);
       for XX = 1:length({EEG.event.type}),
           EEG.event(XX).type = strtrim(EEG.event(XX).type);
       end
   elseif ischar(args.events),
       switch args.events,
        case {'ALL' 'all'}, eventtypes = unique({EEG.event.type});
        case 'task_default',
         switch EEG.condition,
          case 'beg',
           eventtypes = {'1' '2' '3' '4' '5' '11' '12' '13' '14' '95'};
          case 'nogo', 
           eventtypes = {'N' 'n' 'C' 'E' 'L' 'M' 'O' 'P' 'l' 'm' 'o' 'p' 'x' 'y' 'z'};
          case 'flanker', 
           eventtypes = {'C' 'E' 'S' 's' 'X' 'Y' 'Z' 'T' 'U' 'V' 'W'}; 
          case 'rhon',
           eventtypes = {'T' 'F' 'P' 'U' 'N' 'O' 'L' 'R' 'E' 'H' '1' '2'};
          otherwise, eventtypes = unique({EEG.event.type}); 
         end
        otherwise, eventtypes = unique({EEG.event.type});
       end
   end
end

if isfield(args,'winsec')&&~isempty(args.winsec),
   epochlatency = args.winsec;
else,
   epochlatency = [-1  2];
end

if isfield(args,'rdcevt')&&args.rdcevt>0,
   EEG = pop_selectevent(EEG,'type', [eventtypes 'boundary'],'deleteevents','on'); %SJB added "boundary" 05-01-2018
end

%epoch!
EEG = pop_epoch(EEG, eventtypes, epochlatency);

%rmbase
if isfield(args,'rmbase')&&~isempty(args.rmbase)&&args.rmbase~=0,
   blnrmv = args.rmbase;
elseif isfield(args,'rmbase')&&~isempty(args.rmbase)&&args.rmbase==0,
   return
else, 
   blnrmv = [];
end

%baseline
EEG = pop_rmbase(EEG, blnrmv);



