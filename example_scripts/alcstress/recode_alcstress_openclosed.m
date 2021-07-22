Ninsert = 60;
ecstart = strmatch('1',strtrim({EEG.event.type})); %eyes-closed indices
eostart = strmatch('2',strtrim({EEG.event.type})); %eyes-open indicess

eclats1  = [];
eclats2  = [];
for ijk = 1:length(ecstart),
    eclats1 = [eclats1 ...
                ceil(EEG.event(ecstart(ijk)).latency):(2*EEG.srate):((Ninsert*EEG.srate)+ceil(EEG.event(ecstart(ijk)).latency))];
    eclats2 = [eclats2 ...
      EEG.srate+ceil(EEG.event(ecstart(ijk)).latency):(2*EEG.srate):((Ninsert*EEG.srate)+ceil(EEG.event(ecstart(ijk)).latency))];
end

eolats1  = []; 
eolats2  = [];
for ijk = 1:length(eostart),
    eolats1 = [eolats1 ...
                ceil(EEG.event(eostart(ijk)).latency):(2*EEG.srate):((Ninsert*EEG.srate)+ceil(EEG.event(eostart(ijk)).latency))];
    eolats2 = [eolats2 ...
      EEG.srate+ceil(EEG.event(eostart(ijk)).latency):(2*EEG.srate):((Ninsert*EEG.srate)+ceil(EEG.event(eostart(ijk)).latency))];
end

eclats1 = eclats1((eclats1>(EEG.srate*EEG.xmax))==0);
eclats2 = eclats2((eclats2>(EEG.srate*EEG.xmax))==0);
eolats1 = eolats1((eolats1>(EEG.srate*EEG.xmax))==0);
eolats2 = eolats2((eolats2>(EEG.srate*EEG.xmax))==0);
ectype1 = repmat({'1'},[1 length(eclats1)]);
ectype2 = repmat({'2'},[1 length(eclats2)]);
eotype1 = repmat({'3'},[1 length(eolats1)]);
eotype2 = repmat({'4'},[1 length(eolats2)]);

elats = [eclats1 eclats2 eolats1 eolats2];
etype = [ectype1 ectype2 eotype1 eotype2];
[junk, sortidx] = sort(elats);
elats = elats(sortidx);
etype = etype(sortidx);
[EEG.urevent,EEG.event] = eeg_mktriggers(EEG,etype,elats,1);


