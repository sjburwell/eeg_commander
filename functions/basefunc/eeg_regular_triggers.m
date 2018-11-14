function EEG = eeg_regular_triggers(EEG, regularity, value, start_trigger, overwrite);

%EEG = eeg_regular_triggers(EEG, regularity, value, start_trigger);
% Insert events into EEG.event and EEG.urevent structures at regular intervals.
%               ***N.B. rounds-down to nearest sample.
% 
% INPUTS:
%  EEG	         - EEGLAB structured variable
%  regularity    - period [samples] between each event
%  value         - event-type, routinely converted to string (default: 'X')
%  start_trigger - first event's latency to be used for starting point (default: 1pt)
%  overwrite     - [Y/N] overwrite original triggers
%
% OUTPUTS:
%  EEG           - EEGLAB structured variable w/ modified event-fields
%
% SJBURWELL, February, 2011

%check/define input variables
if nargin<2, disp('Must define variable: "regularity"')
   help eeg_regular_triggers; 
   return 
end
if nargin>=2, 
   if      ~exist('value')||isempty(value), value = 'X';
   elseif isnumeric(value),      value = num2str(value); 
   elseif    iscell(value),      value = char(value)   ; 
   end
end
if        (exist('start_trigger') && ~isempty(start_trigger)) &&   ...
       ~isempty(strmatch(start_trigger,{EEG.urevent.type},'exact')),
   start_urec = min(strmatch(start_trigger,{EEG.urevent.type},'exact'));
   start_urpt = floor(EEG.urevent(start_urec).latency);
   disp(['   eeg_regular_triggers; Inserting triggers starting at urevent no. ' num2str(start_urec) ]);
else,
   start_urec = 1;
   start_urpt = 1;
   disp( '   eeg_regular_triggers; No start_trigger exists, default to first sample of data');
end

%compile info and send to eeg_mktriggers
evtlat = [start_urpt : regularity : EEG.pnts];
if length(evtlat)>floor((EEG.pnts-start_urpt+1)/regularity), evtlat = evtlat(1:end-1); end
evtype = repmat({value}, [1 length(evtlat)]);
disp(['   eeg_regular_triggers; Triggers added with floor(sample) precision; value: "' value '"' ]);
[EEG.urevent, EEG.event] = eeg_mktriggers(EEG, evtype, evtlat, overwrite);

EEG = pop_editeventvals( EEG, 'sort', {'latency' 0}); 
