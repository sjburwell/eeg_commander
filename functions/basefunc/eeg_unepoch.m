% eeg_unepoch() - concatenates epoched contiguous data-epochs 
%
% Usage: 
%   >> OUTEEG = eeg_unepoch(INEEG);
%
% Input:
%   INEEG     - input EEG data structure with non-overlapping epochs
%
% Output: 
%   OUTEEG    - output EEG data structure with concatenated data and
%               adjusted event fields
%
% See also:
%   eeg_regular_triggers, pop_epoch
%
% Scott Burwell, February 2011
function EEG = eeg_unepoch(EEG);


%-- Standard data reformat
NC = size(EEG.data,1);
NT = size(EEG.data,2);
NP = size(EEG.data,3);

EEG.trials  =                               1;
EEG.pnts    =                           NP*NT;
EEG.xmin    =                               0;
EEG.xmax    = (EEG.pnts-1)/EEG.srate+EEG.xmin;
EEG.times   =                              [];
if isa(EEG.data,'single'), 
 EEG.data    = single(reshape(permute(double(EEG.data), [2 3 1]), [NT*NP NC])');
else,
 EEG.data    =        reshape(permute(double(EEG.data), [2 3 1]), [NT*NP NC])';
end

%-- events, epochs
EEG    = eeg_checkset(EEG,'makeur');                          %SJB: added   8-21-2018
EEG    = pop_editeventvals( EEG, 'sort', {'latency' 0});
totevt = double([EEG.event.urevent]);
[x  i] = unique( totevt);
evtype = deblank({EEG.urevent(totevt(sort(i))).type});
totlat = double([EEG.event.latency]);
%[x  i] = unique( totlat);                                    %SJB: deleted 8-21-2018
%evtlat = totlat(sort(i));                                    %SJB: deleted 8-21-2018
evtlat = totlat;                                              %SJB: added   8-21-2018
[u, e] = eeg_mktriggers( [] , evtype, evtlat, 1);
EEG.urevent =  u  ;
EEG.event   =  e  ;
EEG.epoch   = [ ] ;
EEG    = pop_editeventvals( EEG, 'sort', {'latency' 0});


%%original below::: deleted 8-21-2018
%EEG    = pop_editeventvals( EEG, 'sort', {'latency' 0});
%totevt = double([EEG.event.urevent]);
%[x  i] = unique( totevt);
%evtype = deblank({EEG.urevent(totevt(sort(i))).type}); 
%totlat = double([EEG.event.latency]);
%[x  i] = unique( totlat);
%evtlat = totlat(sort(i));
%[u, e] = eeg_mktriggers( [] , evtype, evtlat, 1);
%EEG.urevent =  u  ;
%EEG.event   =  e  ;
%EEG.epoch   = [ ] ;
%EEG    = pop_editeventvals( EEG, 'sort', {'latency' 0});


