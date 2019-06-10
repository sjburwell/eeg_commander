% bssica_correct_emg() - remove putative muscle ICA components from EEG based on temporal 
%                        autocorrelation and (optional) dipole location. Autocorrelations
%                        are computed in a sliding window, and the median (or another cutoff
%                        is used to quantify each component's autocorrelation
%
% Usage:
%   >> [OUTEEG, dropped, rho, dipdepth] = bssica_correct_emg(INEEG, lag, threshold, varargin);
%
% Inputs:
%   INEEG     - input EEG dataset
%   lag       - 1xN time-lag(s) to compute autocorrelations on component activations in
%               milliseconds, minimum of: round(EEG.srate/1000) 
%   threshold - 1xN threshold(s) at which to remove sub-threshold components in rho
%
% Optional inputs ('key','val'):
%   'slide'   - sliding window to use (default: 1000)
%   'pctbad'  - how much of a component time-series needs to be bad to be dropped? (def: 50)
%   'detrend' - polynomial order(s) to remove from data in sliding window before computing
%               the autocorrelation (default: 2)
%   'relaxed' - 0 - conservative (rho must be > threshold for all lags)
%               1 - moderate (default, rho > threshold for >1 lag)
%               2 - relaxed (rho > threshold for >0 lag)
%   'depthr'  - require that dipoles are located <depthr inside MNI brain (requires FieldTrip)
%               Definition: in brain=-1  <-- brain surface=0 --> outside brain=+1
%
% Scott Burwell, May, 2019
%
% See also: bsscca_correct_emg
function [EEG, dropped, rho, dipdepth] = bssica_correct_emg(EEG, lag, threshold, varargin);

if length(varargin)==1,
   args = varargin{:};
else,
   args = struct(varargin{:});
end

if ~isfield(args,'slide'),   slide  = 1000; else, slide  = args.slide;   end
if ~isfield(args,'pctbad'),  pctbad =   50; else, pctbad = args.pctbad;  end 
if ~isfield(args,'relaxed'), relaxed=    1; else, relaxed= args.relaxed; end
if ~isfield(args,'depthr'),  depthr =  NaN; else, depthr = args.depthr;  end 
if ~isfield(args,'detrend'), dtndor =[1 2]; else, dtndor = args.detrend; end

%
% ---- Get independent component time-series autocorrelations
%

EEG.icaact = [];
EEG        = eeg_checkset(EEG,'ica');
wins       = slide/1000; 
reject     = EEG.reject;
if round(min(lag)/(1000/EEG.srate))<1, 
   error('   bssica_correct_emg; lag, too small for EEG.srate, must increase so that round(min(lag)/(1000/EEG.srate)) is greater than 0!'); return; 
end

rho= ones(size(EEG.icaact,1),length(lag));
for c=1:size(EEG.icaact,1), 
  for l=1:length(lag),
    cc = [];
    datlong = reshape(EEG.icaact(c,:,:),[1 prod(size(EEG.icaact(c,:,:)))]);
    steps = 1:EEG.srate * wins:length(datlong);
    for tt = 1:length(steps)-1, 
      steppts = steps(tt):steps(tt)+(EEG.srate * wins);
      tmpcc   = corrcoef( detrendnonlin(datlong(steppts),dtndor), circshift(detrendnonlin(datlong(steppts),dtndor),round(lag(l)/(1000./EEG.srate)))); 
      cc      = [cc; tmpcc(2)];
    end 
    rho(c,l) = prctile(cc, pctbad); 
  end
end 

%
% ---- Get dipole locations and depth for independent components for standard MNI brain
%      (Dipole fitting - adapted from: https://sccn.ucsd.edu/wiki/Makoto's_useful_EEGLAB_code)
tmpEEG = EEG;
if ~isnan(depthr), %isnumeric(depthr), 
 dipfitroot = fileparts(which('eegplugin_dipfit'));
 dipfitlocs = [dipfitroot '/standard_BEM/elec/standard_1005.elc'];
 if isempty(tmpEEG.dipfit),
  [chanlocs_out,coord_transform] = coregister(tmpEEG.chanlocs(tmpEEG.icachansind),dipfitlocs,'warp', 'auto','manual','off');
  tmpEEG = pop_dipfit_settings( tmpEEG, ...
      'hdmfile', [dipfitroot '/standard_BEM/standard_vol.mat'], ...
      'coordformat', 'MNI',...
      'mrifile', [dipfitroot '/standard_BEM/standard_mri.mat'],...
      'chanfile', dipfitlocs, ...
      'coord_transform', coord_transform,...
      'chansel', tmpEEG.icachansind);
  tmpEEG = pop_multifit(tmpEEG, 1:length(tmpEEG.dipfit.chansel),'threshold', 100, 'dipplot','off','plotopt',{'normlen' 'on'});
 end

  hdm = [dipfitroot, '/standard_BEM/standard_vol.mat']; load(hdm); %loads the "vol" variable used below in ft_sourcedepth
  diplocs = reshape([tmpEEG.dipfit.model.posxyz],[3, length(tmpEEG.dipfit.model)])';
  dipdepth= ft_sourcedepth(diplocs, vol);
end


if     relaxed==0, dropped = find(sum(abs(rho)<repmat(threshold,size(rho,1),1),2)==size(rho,2))'; 
elseif relaxed==1, dropped = find(sum(abs(rho)<repmat(threshold,size(rho,1),1),2)>1)';
elseif relaxed==2, dropped = find(sum(abs(rho)<repmat(threshold,size(rho,1),1),2)>0)';
end

if ~isnan(depthr), %isnumeric(depthr), 
  dropped = intersect(find(dipdepth> depthr), dropped);
end

display(['   bssica_correct_emg; (' EEG.filename ') Removing ' num2str(length(dropped), '%02d') ' muscle artifacts']);
EEG = pop_subcomp(EEG, dropped); EEG.reject = reject;


function y = detrendnonlin(x, order)
for pp = 1:length(order), 
  if pp==1,
     p = polyfit((1:numel(x))', x(:), order(pp));
     y = x(:) - polyval(p, (1:numel(x))');
  else,
     p = polyfit((1:numel(y))', y(:), order(pp));
     y = y(:) - polyval(p, (1:numel(y))');
  end
end
y = reshape(y,size(x));
