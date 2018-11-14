% artifact_epochs() - Detect outlier epochs based on various measures with optional
%                     joint-thresholding. 
%
% Usage:
%   >> [epochs] = artifact_epochs( data, methods, joint, verbose);
%
% Inputs: 
%   data     - [CHANxPTSxEPOCHS] data matrix
%   methods  - 1xN structured variable with artifact criteria
%    EX: methods [.meas] =   'var': mean variance w/in epoch
%                          'range': mean range w/in epoch
%                          'chdev': mean channel-deviation w/in epoch
%                           'rFFT': median spectral correlation
%                [.stat] = see thresholder()
%                [.crit] = see thresholder()
%   joint    - joint statistical thresholding 0 = no  (default)
%                                             1 = yes
%   verbose  - report to screen inputs        0 = no  (default)
%                                             1 = yes
%
% Outputs:
%   epochs   - epoch-indices exceeding defined threshold
%
% Note: Relevant literature:
%       Nolan, H., Whelan, R., & Reilly, R.B. (2010). J. Neurosci Meth, 192, 152-162
%
% Scott Burwell, March, 2011
function epochs = artifact_epochs( data, methods, joint, verbose)

% initialize variables
if nargin<2, help mfilename; return; end
if isstruct(methods), M = methods; else, help mfilename; return; end
if nargin>2,
   if isempty(joint), joint = 0; else, joint = joint; end
   if ~exist('verbose'), verbose = 0; end
end
m = []; crit = [];
viol = zeros(size(data,3),size(M,2));

if strmatch('var',{M.meas}), m = strmatch('var',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = median(squeeze(var(data,0,2)));
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
if strmatch('range',{M.meas}), m = strmatch('range',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = squeeze(median(range(permute(data,[2 1 3]))));
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
if strmatch('totpow',{M.meas}), m = strmatch('totpow',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = squeeze(median(sum(data.^2))); 
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
if strmatch('maxgrad',{M.meas}), m = strmatch('maxgrad',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = squeeze(median(max(abs(diff(data,1,2)),[],2)));
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
if strmatch('kurt-spat',{M.meas}), m = strmatch('kurt-spat',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = median(squeeze(kurtosis(permute(data,[1 2 3]),0)));
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
if strmatch('kurt-temp',{M.meas}), m = strmatch('kurt-temp',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = median(squeeze(kurtosis(permute(data,[2 1 3]),0))); %uses non-normalized (per EEGLAB)
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
if strmatch('Vmax-med',{M.meas}), m = strmatch('Vmax-med',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = median(squeeze(max(permute(abs(data),[2 1 3]))));
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
if strmatch('fqvar',{M.meas}), m = strmatch('fqvar',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   zcmtx = data-repmat(mean(data,2),[1 size(data,2) 1]); %remove row means
   zcmtx = diff(sign(zcmtx),1,2);                        %first difference of sign (-1, 0, 1)
   fqvar = squeeze(sum(abs(zcmtx)==2,2)) .* squeeze(var(permute(data,[2 1 3])));
   meas  = median(fqvar);
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end

% construct output
viol   = logical(viol);
if    nargin>2&(size(viol,2)>1)&joint>0,
   epochs = find(sum(viol')==size(viol,2))';
elseif nargin>2&(size(viol,2)>1)&joint==0,
   epochs = find(sum(viol')>0)';
else
   epochs = find(viol==1);
end

