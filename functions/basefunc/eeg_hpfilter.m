function EEG = eeg_hpfilter(EEG, lowfreq, trans_width, verbose);
% EEG_HPFILTER Uses FIRFILT toolbox functions to highpass-filter EEG-structured data
%
% EEG = eeg_hpfilter(EEG, lowfreq, trans_width, verbose) ;
%
% EEG 		= absolutely necessary, continuous input. 
% lowfreq	= low frequency boundary (Hz; default = .1)
% trans_width	= transition band (Hz; default = 1)
% note: Kaiser window beta = 7.8573 is default-- pretty sharp.
%

if ~exist('EEG','var')
   disp('Please load an EEG file.')
   return
end

ntrials = EEG.trials; nchans  = EEG.nbchan; npts = EEG.pnts;
%if ntrials > 1
%   disp('WARNING: DATA IS BEING CONCATENATED TO CONTINUOUS FORMAT TO AVOID FILTER ARTIFACT ON EPOCHS.')
%   input_data = reshape(permute(double(EEG.data), [2 3 1]), [ntrials*npts nchans])';
%elseif ntrials==1
%   input_data = EEG.data;
%end

if ~exist('lowfreq','var'); lowfreq = .1; disp('Using default lowfreq value of .1 Hz.') ;end
if ~exist('trans_width','var'); trans_width = 1; disp('Using default transition band width of 1 Hz.'); end

% Filter specs
clear ARG
ARG.wtype       = 'kaiser';
ARG.ftype       = 'highpass';
ARG.trans_width = trans_width ;
ARG.lowfreq     = lowfreq ;
ARG.beta        = 7.8573;  % Kaiser's beta for passband ripple of .0001
DEVIATION       = .0001;
m = pop_firwsord(ARG.wtype, EEG.srate, ARG.trans_width, DEVIATION);

if ~isfield(EEG,'hpfilter')
   F = 1;
else 
   F = size(EEG.hpfilter,2)+1;
end

% Build hpfilter struct within EEG
hpfilter.type            = ARG.ftype;    hpfilter.transition_band = [num2str(ARG.trans_width) ' Hz'];
hpfilter.window          = ARG.wtype;    hpfilter.passband_ripple = DEVIATION;
hpfilter.cutoff          = ARG.lowfreq;  hpfilter.kaiser_beta     = ARG.beta;
hpfilter.order           = m;

if nargin>3&&verbose>0,
   disp('Highpass filter parameters: ')
   hpfilter
end

% Actually FILTER the data
[EEG, com, b] = pop_firws(EEG, 'fcutoff', ARG.lowfreq, ...
                               'forder',  m,           ...
                               'ftype',   ARG.ftype,   ...
                               'wtype',   ARG.wtype,   ...
                               'warg',    ARG.beta,    ...
                               'showBar', 0               );
hpfilter.coefficients    = b;
EEG = eeg_hist(EEG, com);

