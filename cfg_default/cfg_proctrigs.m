%%% CONFIGURATION FOR IMPORTING ERP DATA %%%

% -- process preparation 
config(1).preproc.eventtype    = 'proc'; % label for processing triggers
config(1).preproc.eventduration=  1    ; % duration of each contiguous epoch
config(1).preproc.trimends     =  3    ; % trim edges of data (filter/recording artifact) 


