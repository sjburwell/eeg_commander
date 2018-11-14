%keyboard

if ~isempty(strmatch('Veog-',{EEG.chanlocs.labels}))&&~isempty(strmatch('Heogr',{EEG.chanlocs.labels})),

% make virtual blink/horizontal eye movement leads, lowpass filter        
pts    = floor(EEG.pnts/4):floor(EEG.pnts-(EEG.pnts/4));
blink  = mean(EEG.data(find(ismember({EEG.chanlocs.labels},{'FP1' 'FPZ' 'FP2' 'AF3' 'AFZ' 'AF4'})),pts));
hem    = EEG.data(strmatch('F8',{EEG.chanlocs.labels}),pts) - ...
         EEG.data(strmatch('F7',{EEG.chanlocs.labels}),pts);
blinkfilt = eegfilt(blink,EEG.srate,0,6);
hem_filt  = eegfilt(hem ,EEG.srate,0,6);
blinkpts  =  abs(zscore(blinkfilt))>3;
hempts    =  abs(zscore(hem_filt))>3;
mad_blink = ( blinkfilt-median(blinkfilt) ) ./ (1.4826*mad(blinkfilt,1));
mad_hem   = (  hem_filt-median( hem_filt) ) ./ (1.4826*mad( hem_filt,1));
blinkpts  = (3<   ( mad_blink )); %&(   ( mad_blink )<5);
hempts    = (3<abs( mad_hem   )); %&(abs( mad_hem   )<5);
eyepts    =  unique([find(blinkpts) find(hempts)]);
blink     =  blinkfilt(eyepts);
hem       =  hem_filt(eyepts);

% grab EOG data, do the same as above
Vminus   = EEG.data(strmatch('Veog-',{EEG.chanlocs.labels}),:);
Hright   = EEG.data(strmatch('Heogr',{EEG.chanlocs.labels}),:);
Vfilt    = eegfilt(Vminus(pts),EEG.srate,0,6);
Hfilt    = eegfilt(Hright(pts),EEG.srate,0,6);
Vfilt    = Vfilt(eyepts);
Hfilt    = Hfilt(eyepts);

if corr(blink',Hfilt') < 0                             && ...
 (abs(corr(blink',Vfilt')) < abs(corr(blink',Hfilt'))) && ...
 (abs(corr(  hem',Hfilt')) < abs(corr(  hem',Vfilt'))),
  disp(['   switch_eogs (' EEG.filename '); Evidence that Veog- and Heogr are wrongly assigned in BDF, swapping data...']);
  EEG.data(strmatch('Veog-',{EEG.chanlocs.labels}),:) = Hright;
  EEG.data(strmatch('Heogr',{EEG.chanlocs.labels}),:) = Vminus;
end
 
end
