clear REC

photodiode    = '16';
diodecritpt   =  round(.100 * EEG.srate); % "photodiode" must precede "visualcues" by ~100 milliseconds
visualcues    = {'40','41','42','43','50','51','52','53','60','61','62','63', ...
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

%basic recode
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

EEG = eeg_recode(EEG, REC, 1);
clear REC

if ~isempty(bndrysamples), [EEG.urevent, EEG.event] = eeg_mktriggers( EEG, repmat({'boundary'},length(bndrysamples)), bndrysamples, 0); end

