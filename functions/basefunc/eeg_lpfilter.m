function EEG = eeg_lpfilter(EEG, highfreq, trans_width, verbose);
% EEG_LPFILTER Uses FIRFILT toolbox functions to lowpass-filter EEG-structured data
%
% EEG = eeg_lpfilter(EEG, lowfreq, trans_width, verbose) ;
%
% EEG           = absolutely necessary, continuous input. 
% lowfreq       = low frequency boundary (Hz; default = .1)
% trans_width   = transition band (Hz; default = 1)
% note: Kaiser window beta = 7.8573 is default-- pretty sharp.
%

if ~exist('EEG','var')
   disp('Please load an EEG file.')
   return
end

ntrials = EEG.trials; npts    = EEG.pnts; nchans  = EEG.nbchan;
%if ntrials > 1
%   disp('WARNING: DATA IS BEING CONCATENATED TO CONTINUOUS FORMAT TO AVOID FILTER ARTIFACT ON EPOCHS.')
%   input_data = reshape(permute(double(EEG.data), [2 3 1]), [ntrials*npts nchans])';
%   EEG.data = input_data;
%elseif ntrials==1
%   input_data = EEG.data;
%   EEG.data = input_data;
%end

if ~exist('highfreq','var'); highfreq = 55; disp('Using default lowfreq value of 55 Hz.') ;end
if ~exist('trans_width','var'); trans_width = 5; disp('Using default transition band width of 5 Hz.'); end

% Filter specs
clear ARG
ARG.wtype       = 'kaiser';
ARG.ftype       = 'lowpass';
ARG.trans_width = trans_width ;
ARG.highfreq     = highfreq ;
ARG.beta        = 7.8573;  % Kaiser's beta for passband ripple of .0001
DEVIATION       = .0001;
m = pop_firwsord(ARG.wtype, EEG.srate, ARG.trans_width, DEVIATION);

if ~isfield(EEG,'lpfilter')
   F = 1;
else
   F = size(EEG.lpfilter,2)+1;
end

% Build hpfilter variable within EEG variabl
lpfilter.type            = ARG.ftype;    lpfilter.transition_band = [num2str(ARG.trans_width) ' Hz'];
lpfilter.window          = ARG.wtype;    lpfilter.passband_ripple = DEVIATION;
lpfilter.cutoff          = ARG.highfreq; lpfilter.kaiser_beta     = ARG.beta;
lpfilter.order           = m;

if nargin>3&&verbose>0,
   disp('Lowpass filter parameters: ')
   lpfilter
end

% Actually FILTER the data
[EEG, com, b] = pop_firws(EEG, 'fcutoff', ARG.highfreq, ...
                               'forder',  m,           ...
                               'ftype',   ARG.ftype,   ...
                               'wtype',   ARG.wtype,   ...
                               'warg',    ARG.beta,    ...
                               'showBar', 0               );
lpfilter.coefficients    = b;
EEG = eeg_hist(EEG, com);

