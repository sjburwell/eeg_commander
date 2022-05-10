clear REC

photodiode    = {'16','1200001'};
diodecritpt   =  round(.100 * EEG.srate); % "photodiode" must precede "visualcues" by ~100 milliseconds
visualcues    = {'40','41','42','43','50','51','52','53','60','61','62','63', ...
                 '44','45','46','47','48','49','50','51', ...
                 '10','11','12','13','14','15','17','18', ...
                 '20','21','22','23','24','25','26','27', ...
                 '30','31','32','33','34','35','36','37'};
cueonsets     = find(ismember({EEG.event.type},visualcues));
dropcues      = [];
for ijk = 1:length(cueonsets), 
  mydiffs = EEG.event(cueonsets(ijk)).latency - [EEG.event(find(ismember({EEG.event.type},photodiode))).latency];
  %mydiffs = [EEG.event(find(ismember({EEG.event.type},photodiode))).latency] - EEG.event(cueonsets(ijk)).latency;
  mydiffs(mydiffs<0) = 99999999;
  if min(mydiffs)>=diodecritpt, 
    dropcues = [dropcues, cueonsets(ijk)];
  end
end
EEG = pop_editeventvals(EEG,'delete',dropcues);
EEG = eeg_checkset(EEG,'makeur');

bndrysamples  = [EEG.event(strmatch('boundary',{EEG.event.type})).latency];

EEG.etc.no_photodiode = 0;

%version of npu task (i.e., before or after Feb 1, 2019)
if contains(EEG.filename,{'A1','B1','C1','D1','E1','F1'}), %before Feb 1, 2019

% original recode w/ photodiode requirement
REC(1).label  = {'boundary'}; REC(1).template  = {  '800001'};      REC(1).position  = 1;
REC(2).label  =     {  '40'}; REC(2).template  = {'16' '40'};       REC(2).position  = 1; %visual cues
REC(3).label  =     {  '41'}; REC(3).template  = {'16' '41'};       REC(3).position  = 1;
REC(4).label  =     {  '42'}; REC(4).template  = {'16' '42'};       REC(4).position  = 1;
REC(5).label  =     {  '43'}; REC(5).template  = {'16' '43'};       REC(5).position  = 1;
REC(6).label  =     {  '50'}; REC(6).template  = {'16' '50'};       REC(6).position  = 1;
REC(7).label  =     {  '51'}; REC(7).template  = {'16' '51'};       REC(7).position  = 1;
REC(8).label  =     {  '52'}; REC(8).template  = {'16' '52'};       REC(8).position  = 1;
REC(9).label  =     {  '53'}; REC(9).template  = {'16' '53'};       REC(9).position  = 1;
REC(10).label =     {  '60'}; REC(10).template = {'16' '60'};       REC(10).position = 1;
REC(11).label =     {  '61'}; REC(11).template = {'16' '61'};       REC(11).position = 1;
REC(12).label =     {  '62'}; REC(12).template = {'16' '62'};       REC(12).position = 1;
REC(13).label =     {  '63'}; REC(13).template = {'16' '63'};       REC(13).position = 1;
REC(14).label =     { '840'}; REC(14).template = {'16' '40' '128'}; REC(14).position = 3; %auditory probes during cue
REC(15).label =     { '841'}; REC(15).template = {'16' '41' '128'}; REC(15).position = 3;
REC(16).label =     { '842'}; REC(16).template = {'16' '42' '128'}; REC(16).position = 3;
REC(17).label =     { '843'}; REC(17).template = {'16' '43' '128'}; REC(17).position = 3;
REC(18).label =     { '850'}; REC(18).template = {'16' '50' '128'}; REC(18).position = 3;
REC(19).label =     { '851'}; REC(19).template = {'16' '51' '128'}; REC(19).position = 3;
REC(20).label =     { '852'}; REC(20).template = {'16' '52' '128'}; REC(20).position = 3;
REC(21).label =     { '853'}; REC(21).template = {'16' '53' '128'}; REC(21).position = 3;
REC(22).label =     { '860'}; REC(22).template = {'16' '60' '128'}; REC(22).position = 3;
REC(23).label =     { '861'}; REC(23).template = {'16' '61' '128'}; REC(23).position = 3;
REC(24).label =     { '862'}; REC(24).template = {'16' '62' '128'}; REC(24).position = 3;
REC(25).label =     { '863'}; REC(25).template = {'16' '63' '128'}; REC(25).position = 3;
REC(26).label =     { '710'}; REC(26).template = {'16' '10' '128'}; REC(26).position = 3; %auditory probes during iti
REC(27).label =     { '711'}; REC(27).template = {'16' '11' '128'}; REC(27).position = 3; 
REC(28).label =     { '712'}; REC(28).template = {'16' '12' '128'}; REC(28).position = 3; 
REC(29).label =     { '713'}; REC(29).template = {'16' '13' '128'}; REC(29).position = 3; 
REC(30).label =     { '714'}; REC(30).template = {'16' '14' '128'}; REC(30).position = 3; 
REC(31).label =     { '715'}; REC(31).template = {'16' '15' '128'}; REC(31).position = 3; 
REC(32).label =     { '716'}; REC(32).template = {'16' '17' '128'}; REC(32).position = 3; %<-purposefully mismatched
REC(33).label =     { '717'}; REC(33).template = {'16' '18' '128'}; REC(33).position = 3; %<-purposefully mismatched
REC(34).label =     { '720'}; REC(34).template = {'16' '20' '128'}; REC(34).position = 3; 
REC(35).label =     { '721'}; REC(35).template = {'16' '21' '128'}; REC(35).position = 3; 
REC(36).label =     { '722'}; REC(36).template = {'16' '22' '128'}; REC(36).position = 3;
REC(37).label =     { '723'}; REC(37).template = {'16' '23' '128'}; REC(37).position = 3;
REC(38).label =     { '724'}; REC(38).template = {'16' '24' '128'}; REC(38).position = 3;
REC(39).label =     { '725'}; REC(39).template = {'16' '25' '128'}; REC(39).position = 3;
REC(40).label =     { '726'}; REC(40).template = {'16' '26' '128'}; REC(40).position = 3;
REC(41).label =     { '727'}; REC(41).template = {'16' '27' '128'}; REC(41).position = 3; 
REC(42).label =     { '730'}; REC(42).template = {'16' '30' '128'}; REC(42).position = 3; 
REC(43).label =     { '731'}; REC(43).template = {'16' '31' '128'}; REC(43).position = 3;
REC(44).label =     { '732'}; REC(44).template = {'16' '32' '128'}; REC(44).position = 3;
REC(45).label =     { '733'}; REC(45).template = {'16' '33' '128'}; REC(45).position = 3;
REC(46).label =     { '734'}; REC(46).template = {'16' '34' '128'}; REC(46).position = 3;
REC(47).label =     { '735'}; REC(47).template = {'16' '35' '128'}; REC(47).position = 3;
REC(48).label =     { '736'}; REC(48).template = {'16' '36' '128'}; REC(48).position = 3;
REC(49).label =     { '737'}; REC(49).template = {'16' '37' '128'}; REC(49).position = 3;

elseif contains(EEG.filename,{'A2','B2','C2','D2','E2','F2'}) && sum(ismember({EEG.event.type},{'1200001'}))>0, % added 4-10-2022

% recode w/ photodiode requirement
REC(1).label  = {'boundary'}; REC(1).template  = {  '800001'};      REC(1).position  = 1;
REC(2).label  =     {  '40'}; REC(2).template  = {'1200001' '40'};       REC(2).position  = 1; %visual cues
REC(3).label  =     {  '41'}; REC(3).template  = {'1200001' '41'};       REC(3).position  = 1;
REC(4).label  =     {  '42'}; REC(4).template  = {'1200001' '42'};       REC(4).position  = 1;
REC(5).label  =     {  '43'}; REC(5).template  = {'1200001' '43'};       REC(5).position  = 1;
REC(6).label  =     {  '50'}; REC(6).template  = {'1200001' '44'};       REC(6).position  = 1;
REC(7).label  =     {  '51'}; REC(7).template  = {'1200001' '45'};       REC(7).position  = 1;
REC(8).label  =     {  '52'}; REC(8).template  = {'1200001' '46'};       REC(8).position  = 1;
REC(9).label  =     {  '53'}; REC(9).template  = {'1200001' '47'};       REC(9).position  = 1;
REC(10).label =     {  '60'}; REC(10).template = {'1200001' '48'};       REC(10).position = 1;
REC(11).label =     {  '61'}; REC(11).template = {'1200001' '49'};       REC(11).position = 1;
REC(12).label =     {  '62'}; REC(12).template = {'1200001' '50'};       REC(12).position = 1;
REC(13).label =     {  '63'}; REC(13).template = {'1200001' '51'};       REC(13).position = 1;
REC(14).label =     { '840'}; REC(14).template = {'1200001' '40' '1000001'}; REC(14).position = 3; %auditory probes during cue
REC(15).label =     { '841'}; REC(15).template = {'1200001' '41' '1000001'}; REC(15).position = 3;
REC(16).label =     { '842'}; REC(16).template = {'1200001' '42' '1000001'}; REC(16).position = 3;
REC(17).label =     { '843'}; REC(17).template = {'1200001' '43' '1000001'}; REC(17).position = 3;
REC(18).label =     { '850'}; REC(18).template = {'1200001' '44' '1000001'}; REC(18).position = 3;
REC(19).label =     { '851'}; REC(19).template = {'1200001' '45' '1000001'}; REC(19).position = 3;
REC(20).label =     { '852'}; REC(20).template = {'1200001' '46' '1000001'}; REC(20).position = 3;
REC(21).label =     { '853'}; REC(21).template = {'1200001' '47' '1000001'}; REC(21).position = 3;
REC(22).label =     { '860'}; REC(22).template = {'1200001' '48' '1000001'}; REC(22).position = 3;
REC(23).label =     { '861'}; REC(23).template = {'1200001' '49' '1000001'}; REC(23).position = 3;
REC(24).label =     { '862'}; REC(24).template = {'1200001' '50' '1000001'}; REC(24).position = 3;
REC(25).label =     { '863'}; REC(25).template = {'1200001' '51' '1000001'}; REC(25).position = 3;
REC(26).label =     { '710'}; REC(26).template = {'1200001' '10' '1000001'}; REC(26).position = 3; %auditory probes during iti
REC(27).label =     { '711'}; REC(27).template = {'1200001' '11' '1000001'}; REC(27).position = 3;
REC(28).label =     { '712'}; REC(28).template = {'1200001' '12' '1000001'}; REC(28).position = 3;
REC(29).label =     { '713'}; REC(29).template = {'1200001' '13' '1000001'}; REC(29).position = 3;
REC(30).label =     { '714'}; REC(30).template = {'1200001' '14' '1000001'}; REC(30).position = 3;
REC(31).label =     { '715'}; REC(31).template = {'1200001' '15' '1000001'}; REC(31).position = 3;
REC(32).label =     { '716'}; REC(32).template = {'1200001' '17' '1000001'}; REC(32).position = 3; %<-purposefully mismatched
REC(33).label =     { '717'}; REC(33).template = {'1200001' '18' '1000001'}; REC(33).position = 3; %<-purposefully mismatched
REC(34).label =     { '720'}; REC(34).template = {'1200001' '20' '1000001'}; REC(34).position = 3;
REC(35).label =     { '721'}; REC(35).template = {'1200001' '21' '1000001'}; REC(35).position = 3;
REC(36).label =     { '722'}; REC(36).template = {'1200001' '22' '1000001'}; REC(36).position = 3;
REC(37).label =     { '723'}; REC(37).template = {'1200001' '23' '1000001'}; REC(37).position = 3;
REC(38).label =     { '724'}; REC(38).template = {'1200001' '24' '1000001'}; REC(38).position = 3;
REC(39).label =     { '725'}; REC(39).template = {'1200001' '25' '1000001'}; REC(39).position = 3;
REC(40).label =     { '726'}; REC(40).template = {'1200001' '26' '1000001'}; REC(40).position = 3;
REC(41).label =     { '727'}; REC(41).template = {'1200001' '27' '1000001'}; REC(41).position = 3;
REC(42).label =     { '730'}; REC(42).template = {'1200001' '30' '1000001'}; REC(42).position = 3;
REC(43).label =     { '731'}; REC(43).template = {'1200001' '31' '1000001'}; REC(43).position = 3;
REC(44).label =     { '732'}; REC(44).template = {'1200001' '32' '1000001'}; REC(44).position = 3;
REC(45).label =     { '733'}; REC(45).template = {'1200001' '33' '1000001'}; REC(45).position = 3;
REC(46).label =     { '734'}; REC(46).template = {'1200001' '34' '1000001'}; REC(46).position = 3;
REC(47).label =     { '735'}; REC(47).template = {'1200001' '35' '1000001'}; REC(47).position = 3;
REC(48).label =     { '736'}; REC(48).template = {'1200001' '36' '1000001'}; REC(48).position = 3;
REC(49).label =     { '737'}; REC(49).template = {'1200001' '37' '1000001'}; REC(49).position = 3;

else,

% recode w/o photodiode requirement
EEG.etc.no_photodiode = 1;

% insert a "dummy" photodiode
visual_events = ismember({EEG.event.type},visualcues);
visual_timing = [EEG.event.latency];
visual_timing = visual_timing(visual_events==1); % times of visual stimuli in samples
pdiode_timing = visual_timing - (diodecritpt * .5); % times where dummy photodiode will be inserted
pdiode_labels = repmat({'1200001'},size(pdiode_timing));
[EEG.urevent, EEG.event] = eeg_mktriggers(EEG, pdiode_labels, pdiode_timing, 0); % insert the dummy triggers
EEG = pop_editeventvals(EEG, 'sort', {'latency' 0}); %CRUCIAL - sort by latencies

% recode w/ dummy photodiode - this is actually the same as the above ifelse block, so can probs refactor in some way.
REC(1).label  = {'boundary'}; REC(1).template  = {  '800001'};      REC(1).position  = 1;
REC(2).label  =     {  '40'}; REC(2).template  = {'1200001' '40'};       REC(2).position  = 1; %visual cues
REC(3).label  =     {  '41'}; REC(3).template  = {'1200001' '41'};       REC(3).position  = 1;
REC(4).label  =     {  '42'}; REC(4).template  = {'1200001' '42'};       REC(4).position  = 1;
REC(5).label  =     {  '43'}; REC(5).template  = {'1200001' '43'};       REC(5).position  = 1;
REC(6).label  =     {  '50'}; REC(6).template  = {'1200001' '44'};       REC(6).position  = 1;
REC(7).label  =     {  '51'}; REC(7).template  = {'1200001' '45'};       REC(7).position  = 1;
REC(8).label  =     {  '52'}; REC(8).template  = {'1200001' '46'};       REC(8).position  = 1;
REC(9).label  =     {  '53'}; REC(9).template  = {'1200001' '47'};       REC(9).position  = 1;
REC(10).label =     {  '60'}; REC(10).template = {'1200001' '48'};       REC(10).position = 1;
REC(11).label =     {  '61'}; REC(11).template = {'1200001' '49'};       REC(11).position = 1;
REC(12).label =     {  '62'}; REC(12).template = {'1200001' '50'};       REC(12).position = 1;
REC(13).label =     {  '63'}; REC(13).template = {'1200001' '51'};       REC(13).position = 1;
REC(14).label =     { '840'}; REC(14).template = {'1200001' '40' '1000001'}; REC(14).position = 3; %auditory probes during cue
REC(15).label =     { '841'}; REC(15).template = {'1200001' '41' '1000001'}; REC(15).position = 3;
REC(16).label =     { '842'}; REC(16).template = {'1200001' '42' '1000001'}; REC(16).position = 3;
REC(17).label =     { '843'}; REC(17).template = {'1200001' '43' '1000001'}; REC(17).position = 3;
REC(18).label =     { '850'}; REC(18).template = {'1200001' '44' '1000001'}; REC(18).position = 3;
REC(19).label =     { '851'}; REC(19).template = {'1200001' '45' '1000001'}; REC(19).position = 3;
REC(20).label =     { '852'}; REC(20).template = {'1200001' '46' '1000001'}; REC(20).position = 3;
REC(21).label =     { '853'}; REC(21).template = {'1200001' '47' '1000001'}; REC(21).position = 3;
REC(22).label =     { '860'}; REC(22).template = {'1200001' '48' '1000001'}; REC(22).position = 3;
REC(23).label =     { '861'}; REC(23).template = {'1200001' '49' '1000001'}; REC(23).position = 3;
REC(24).label =     { '862'}; REC(24).template = {'1200001' '50' '1000001'}; REC(24).position = 3;
REC(25).label =     { '863'}; REC(25).template = {'1200001' '51' '1000001'}; REC(25).position = 3;
REC(26).label =     { '710'}; REC(26).template = {'1200001' '10' '1000001'}; REC(26).position = 3; %auditory probes during iti
REC(27).label =     { '711'}; REC(27).template = {'1200001' '11' '1000001'}; REC(27).position = 3;
REC(28).label =     { '712'}; REC(28).template = {'1200001' '12' '1000001'}; REC(28).position = 3;
REC(29).label =     { '713'}; REC(29).template = {'1200001' '13' '1000001'}; REC(29).position = 3;
REC(30).label =     { '714'}; REC(30).template = {'1200001' '14' '1000001'}; REC(30).position = 3;
REC(31).label =     { '715'}; REC(31).template = {'1200001' '15' '1000001'}; REC(31).position = 3;
REC(32).label =     { '716'}; REC(32).template = {'1200001' '17' '1000001'}; REC(32).position = 3; %<-purposefully mismatched
REC(33).label =     { '717'}; REC(33).template = {'1200001' '18' '1000001'}; REC(33).position = 3; %<-purposefully mismatched
REC(34).label =     { '720'}; REC(34).template = {'1200001' '20' '1000001'}; REC(34).position = 3;
REC(35).label =     { '721'}; REC(35).template = {'1200001' '21' '1000001'}; REC(35).position = 3;
REC(36).label =     { '722'}; REC(36).template = {'1200001' '22' '1000001'}; REC(36).position = 3;
REC(37).label =     { '723'}; REC(37).template = {'1200001' '23' '1000001'}; REC(37).position = 3;
REC(38).label =     { '724'}; REC(38).template = {'1200001' '24' '1000001'}; REC(38).position = 3;
REC(39).label =     { '725'}; REC(39).template = {'1200001' '25' '1000001'}; REC(39).position = 3;
REC(40).label =     { '726'}; REC(40).template = {'1200001' '26' '1000001'}; REC(40).position = 3;
REC(41).label =     { '727'}; REC(41).template = {'1200001' '27' '1000001'}; REC(41).position = 3;
REC(42).label =     { '730'}; REC(42).template = {'1200001' '30' '1000001'}; REC(42).position = 3;
REC(43).label =     { '731'}; REC(43).template = {'1200001' '31' '1000001'}; REC(43).position = 3;
REC(44).label =     { '732'}; REC(44).template = {'1200001' '32' '1000001'}; REC(44).position = 3;
REC(45).label =     { '733'}; REC(45).template = {'1200001' '33' '1000001'}; REC(45).position = 3;
REC(46).label =     { '734'}; REC(46).template = {'1200001' '34' '1000001'}; REC(46).position = 3;
REC(47).label =     { '735'}; REC(47).template = {'1200001' '35' '1000001'}; REC(47).position = 3;
REC(48).label =     { '736'}; REC(48).template = {'1200001' '36' '1000001'}; REC(48).position = 3;
REC(49).label =     { '737'}; REC(49).template = {'1200001' '37' '1000001'}; REC(49).position = 3;


end

EEG = eeg_recode(EEG, REC, 1);
clear REC

if ~isempty(bndrysamples), [EEG.urevent, EEG.event] = eeg_mktriggers( EEG, repmat({'boundary'},length(bndrysamples)), bndrysamples, 0); end

