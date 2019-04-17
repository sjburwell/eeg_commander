locations_file = 'curry_sphrad1_n35.ced';
if exist(elec_locations_file, 'file'), %through this and pre-steps, we lose connection to "urchanlocs"
   chanlocs        = readlocs(elec_locations_file);
   if ~isempty(strmatch('HEO',{EEG.chanlocs.labels},'exact')),
       chanlocs(strmatch('HEOG',{chanlocs.labels},'exact')).labels = 'HEO';
   end
   if ~isempty(strmatch('VEO',{EEG.chanlocs.labels},'exact')),
       chanlocs(strmatch('VEOG',{chanlocs.labels},'exact')).labels = 'VEO';
   end
   [junk, oridx]   = ismember({EEG.chanlocs.labels}, {chanlocs.labels});
   chanlocs        = chanlocs(oridx(oridx>0));
   [junk, sorti]   = sort(oridx(oridx>0));
   EEG.chanlocs    = chanlocs(sorti);
   EEG.data        = EEG.data(sorti,:,:);
end

if ~isempty(strmatch('HEO',{EEG.chanlocs.labels},'exact')),
    EEG.chanlocs(strmatch('HEO',{EEG.chanlocs.labels},'exact')).labels = 'HEOG';
end
if ~isempty(strmatch('VEO',{EEG.chanlocs.labels},'exact')),
    EEG.chanlocs(strmatch('VEO',{EEG.chanlocs.labels},'exact')).labels = 'VEOG';
end

%% the HEO/VEO --> HEOG/VEOG code was added by SJB to account for instances where people define their ocular channels differently than in the curry_sphrad1_n35.ced file. 

 
