elec_locations_file = 'curry_sphrad1_n35.ced';
if exist(elec_locations_file, 'file'), %through this and pre-steps, we lose connection to "urchanlocs"
   chanlocs        = readlocs(elec_locations_file);
   [junk, oridx]   = ismember({EEG.chanlocs.labels}, {chanlocs.labels});
   chanlocs        = chanlocs(oridx);
   [junk, sorti]   = sort(oridx);
   EEG.chanlocs    = chanlocs(sorti);
   EEG.data        = EEG.data(sorti,:,:);
end




