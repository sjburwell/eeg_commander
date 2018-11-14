% default_reref - re-reference EEG data structure based on lab preferences and contingent
%                 on prior channel deletion
%
% Usage:
%   >> default_reref;
%
% Information 
%   Script, no input but EEG structure must be in memory (named accordingly).  
%   Re-referencing priorities: [Ref1&Ref2], [Ref1|Ref2], CZ, FZ, none
%   *reference label(s) recorded in field EEG.ref
% 
% Scott Burwell, April 2011
%
% See also: pop_reref

 chanlocs = EEG.chanlocs;
 %averaged ears, one ear if bad
 REF1 = []; REF2 = [];
 if ~isempty(strmatch('M1',{chanlocs.labels})); REF1 = strmatch('M1',{chanlocs.labels}); end
 if ~isempty(strmatch('M2',{chanlocs.labels})); REF2 = strmatch('M2',{chanlocs.labels}); end
 REF = [REF1  REF2];

 %alternatively, try other popular scalp references
 if isempty(REF)&~isempty(strmatch('CZ',{chanlocs.labels})),
    REF = strmatch('CZ',{chanlocs.labels}); 
 end
 if isempty(REF)&~isempty(strmatch('FZ',{chanlocs.labels})),
    REF = strmatch('FZ',{chanlocs.labels}); 
 end
 if isempty(REF), 
    disp(['No viable refernce [ears, CZ, FZ] available for: ' EEG.filename ', skipping referencing.']);
    EEG = eeg_hist(EEG, '*** NO VIABLE REFERENCE [ears, CZ, FZ], REFERENCING SKIPPED ***');
    return
 end
 EEG     = pop_reref(EEG, REF);

 %log
 refstring = [];
 for R = 1:size(REF,2), refstring = [refstring ' ' char({chanlocs(REF(R)).labels})]; end
 EEG     = eeg_hist( EEG, ['EEG = pop_reref(EEG, ' num2str(REF) '); % ref-label: ' refstring ]);
 disp(['EEG = pop_reref(EEG, ' num2str(REF) '); % ref-label: ' refstring ]);
 EEG.ref = {chanlocs(REF).labels};

 %remove bad channels designated for referencing
 if ~isempty(strmatch('Ref', {EEG.chanlocs.labels})),
    EEG = pop_select(EEG, 'nochannel', strmatch('Ref', {EEG.chanlocs.labels}));
 end

 % remove from reject
 if ~isempty(EEG.reject.rejmanualE),
    EEG.reject.rejmanualE(REF,:) = '';
 end
 clear REF chanlocs REF1 REF2 refstring

