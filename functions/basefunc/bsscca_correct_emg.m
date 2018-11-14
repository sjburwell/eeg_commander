function [data, sourcedata, dropped, rho] = bsscca_correct_emg(data, lag, threshold);
%  bsscca_correct_emg() - Reduce data matrix to a mixture of sources that are mutually 
%                         uncorrelated and maximally autocorrelated, such that the influence of
%                         white noise (e.g., electromyogram or EMG) is diminished.  This method 
%                         is based on blind source separation (BSS) using canonical correlation 
%                         analysis (CCA). The paper to introduce BSS-CCA is below and some of 
%                         the code was adapted from the below link.
%
%  Usage:
%    >> [outdata, sourcedata, dropped, rho] = bsscca_correct_emg(indata, lag, threshold);
%
%  Inputs
%    indata    - [CHANxPTS] or [CHANxPTSxEPOCHS] data matrix
%    lag       - time-lag (in samples) to be applied for autocorrelation (default = 1)
%    threshold - either numerical lower-bound correlation coefficient by which to prune 
%                components with low autocorrelation, -OR- a structured variable with the fields
%                "stat" and "crit". If isstruct(threshold), autocorrelations will be converted to
%                1/r and the function thresholder() (see ">> help thresholder" for details) will
%                be invoked.
%
%  Outputs:
%    outdata   - BSS-CCA cleaned data matrix                
%    sourcedata- data matrix containing all BSS-CCA source waveforms
%    dropped   - rows in output variable "sourcedata" that were removed from back-projected data
%    rho       - vector of time-lagged autocorrelations for sources in "sourcedata"
%
%        Relevant Literature:
%        De Clercq, W., Vergult, A., Vanrumste, B., Van Paesschen, W., & Van Huffel, S. (2006). 
%           IEEE Trans Biomed Eng, 53, 2583-2587.
%        Code adapted from bsscca.m in http://www.germangh.com/eeglab_plugin_aar/
%
%  Scott Burwell & Steve Malone, May 2015
%
%  See also: thresholder()

if ~exist('lag')      ||isempty(lag), lag = 1; end
if ~exist('threshold')||isempty(threshold), 
   disp('   bsscca_correct_emg(); Must specify cutoff-threshold.');
   help mfilename; return;
end


%Get data
if length(size(data))==3,
   disp('   bsscca_correct_emg(); Warning, converting data from 3D to 2D, autocorrelations may be lower than expected');
   X = reshape(permute(double(data), [2 3 1]),[size(data,2)*size(data,3) size(data,1)])';
else,
   X = data;
end
Y = X(:,[lag+1:end 1:lag]); %time-lagged version of original data, with wrap-around
[r,c] = size(X);

%Get covariances
Cxx = (1/c)*X*X';   %Cov(X)
Cyy = (1/c)*Y*Y';   %Cov(Y)
Cxy = (1/c)*X*Y';   %Cross-covariance of X and Y

%Solve for CCA
[W,rho]   = eig(pinv(Cxx)*Cxy*pinv(Cyy)*Cxy'); 
rho       = sqrt(abs(real(rho)));

%Find a cut-off for thresholding
if     isnumeric(threshold),
   dropW  = find(diag(rho)<threshold);
elseif isstruct(threshold)&&sum(ismember(fieldnames(threshold),{'stat','crit'}))==2,
   [meas, crit] = thresholder(threshold.stat,1./diag(rho),threshold.crit);
   dropW = find(meas>crit&diag(rho)<median(diag(rho)));
else,  
   disp('   bsscca_correct_emg(); incorrectly defined "threshold," if using function thresholder(), must have "stat" and "crit" fields.'); help thresholder;
   return
end

if ~isempty(dropW),
  disp(['   bsscca_correct_emg(); Components believed to be EMG-contaminated, removing: ' num2str(length(dropW))]);
  %Source time-courses
  Z         = W'*X;
  %Back-project to data-space w/o thresholded white-noise (EMG) components
  Aclean           =     pinv(W');
  Aclean(:,dropW)  =       0     ; 
  Xclean           =    Aclean*Z ;
  data             = real(Xclean); % Xclean; %kludge adapted 6/19/2015, was getting complex numbers
  sourcedata       = real(     Z); % Z;      %changed
  dropped          =       dropW ;
  rho              =    diag(rho);
else, 
  disp(['   bsscca_correct_emg(); No EMG-contaminated components, moving on...']);
end


