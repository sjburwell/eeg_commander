% eeg_mktriggers() - Produce EEGLAB fields 'urevent' and 'event' 
%
% Usage:
%   >> [urevent, event] = eeg_mktriggers( EVTSTRCT, evtype, evtlat, overwrite)
%
% Inputs: 
%   EVTSTRCT  - structured variable containing fields: [.urevent, .event]
%               *see EEG structure for subfields
%               *if empty "[]", creates anew
%   evtype    - [1xN] cell array of strings (labels)
%   evtlat    - [1xN] numeric array of latencies (samples)
%   overwrite - overwrite existing input events 0 = no  (default)
%                                               1 = yes
%
% Outputs:
%   urevent   - structured variable with modified fields
%   event     - structured variable with modified fields
%
% Scott Burwell, February, 2011
function [urevent, event] = eeg_mktriggers(EVTSTRCT, evtype, evtlat, overwrite);

if nargin<3, 
   help mfilename;
   return
end
if nargin>=3,
   if isempty(EVTSTRCT), 
      overwrite = 1;
   end
   if ~exist('overwrite')||isempty(overwrite)||overwrite==0,
      overwrite = 0; 
      ovrwrtstr = '   eeg_mktriggers; Appending'  ;
   else
      overwrite = 1;
      ovrwrtstr = '   eeg_mktriggers; Overwriting';
   end
end   

%initiate loop variables
 if overwrite==0,
    event  = EVTSTRCT.event;
    urevent= EVTSTRCT.urevent;
    evtot  = length(event);
    urtot  = length(urevent);
 elseif overwrite==1,
    event  = struct('type', [], ...
                 'latency', [], ...
                 'urevent', []);
    urevent= struct('type', [], ...
                 'latency', []);
    evtot  = 0;
    urtot  = 0;
 end

disp([ovrwrtstr ' ' num2str(length(evtype))  ' events. ']);
%recode!
 for K = 1:length(evtlat),
     event(evtot+K).type      = char(evtype(K));
     event(evtot+K).latency   = evtlat(K);
     event(evtot+K).urevent   =   urtot+K;
     event(evtot+K).duration  =         0;     

     urevent(urtot+K).type    = char(evtype(K));
     urevent(urtot+K).latency = evtlat(K);
 end

%%added 5/19/15 by SJB, otherwise, if eeg_rejeeg() occurs it may screw-up ordering
%DROPPED 6/23/15 by SJB, JBH discovered that eeg_unepoch() and other dependences rely on 
%EEG.urevent, and thus this re-sorting screwed up the order of triggers eventually.
% if overwrite==0, 
%    [junk, idx] = sort([event.latency], 'ascend');
%    event       = event(  idx);
%    urevent     = urevent(idx);
%    for K = 1:length(event), event(K).urevent = K; end
% end


