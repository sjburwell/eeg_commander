% artifact_channels() - Detect outlier channels (rows) based on various measures with optional
% 			joint-thresholding. 
%
% Usage:
%   >> [indices] = artifact_channels(data, methods, joint, verbose);
%
% Inputs: 
%   data     - [CHANxPTS] or [CHANxPTSxEPOCHS] data matrix
%   methods  - 1xN structured variable with artifact criteria
%    EX: methods [.meas] =   'var': variance
%                          'range': range
%                       'kurtosis': kurtosis (bias-uncorrected, per EEGLAB)
%                          'fqvar': number zero-crossings multiplied by variance, good
%                                   at detecting muscle bursts
%                       'grad-med': median-gradient - uses diff()
%                          'spPCA': median absolute-valued coefficient
%                           'Vmax': maximum absolute value
%                        'Vmedian': median value
%                       'corr-min': minimum cross-channel correlation
%                       'corr-med': median  "  "
%                       'corr-max': maximum "  "
%                      'Vdist-min': minimum electrical distance
%                      'Vdist-med': median          "  "     
%                  'Vdist-nearest': nearest-neighbor "  " 
%                [.stat] = see thresholder()
%                [.crit] = see thresholder()
%   joint    - joint statistical thresholding 0 = no  (default)
%                                             1 = yes
%   verbose  - report to screen inputs        0 = no  (default)
%                                             1 = yes
%
% Outputs:
%   indices  - row-indices exceeding defined threshold
%
% Note: If data are 3-dimensional, transformed to [CHAN*EPOCH  POINTS] matrix.
% 
%       Relevant literature:
%       Nolan, H., Whelan, R., & Reilly, R.B. (2010). J. Neurosci Meth, 192, 152-162
%          Measures: 'var', 'range', 'grad-med'
%       Tenke, C.E. & Kayser, J. (2001). Clin. Neurophysiology, 112, 545-550.
%          Measures: 'Vdist-***'
%
% Scott Burwell, March, 2011
function [indices] = artifact_channels(data, methods, joint, verbose);

% initialize variables
if nargin<2, help mfilename; return; end
if isstruct(methods), M = methods; else, help mfilename; return; end
if nargin>2, 
   if isempty(joint), joint = 0; else, joint = joint; end
   if ~exist('verbose'), verbose = 0; end
end
M = methods;
m = []; crit = [];
viol = zeros(size(data,1),size(M,2));

% initiate constants, restructure 3-D data
nrow = size(data,1);
ncol = size(data,2);
dim_in = length(size(data));
if dim_in>2, 
   nswp = size(data,3);
   if verbose>0, disp('   artifact_channels; Sensed 3-D, restructuring data into [CHAN*EPOCH  POINTS] matrix...'); end
   datatmp = zeros([nrow*nswp  ncol]);
   ti  = 1:nrow:(nrow*(nswp-1))+1;
   for tj = 1:length(ti),
       datatmp(ti(tj):ti(tj)+nrow-1,:) = data(:,:,tj);
   end
   data = datatmp;
else,
   nswp = 1;
end

%% -- measures -- % 

%variance
if strmatch('var',{M.meas}), m = strmatch('var',{M.meas}); 
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = var(data');
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
%inverse-variance
if strmatch('invar',{M.meas}), m = strmatch('invar',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = 1./var(data');
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
%minimum variance
if strmatch('minvar',{M.meas}), m = strmatch('minvar',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = var(data');
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas<crit,m) = 1;
end
%range
if strmatch('range',{M.meas}), m = strmatch('range',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = range(data');
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
%maximum absolute value
if strmatch('Vmax',{M.meas}), m = strmatch('Vmax',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = max(abs(data'));
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
%median value
if strmatch('Vmedian',{M.meas}), m = strmatch('Vmedian',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = median(data');
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
%Area under the curve
if strmatch('AUC',{M.meas}), m = strmatch('AUC',{M.meas});
keyboard
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = sum(abs(data'));
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
%kurtosis
if strmatch('kurtosis',{M.meas}), m = strmatch('kurtosis',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   meas = kurtosis(data',1); %bias-uncorrected, per EEGLAB default
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
%temporal gradient
if strmatch('grad-',{M.meas}), m = strmatch('grad-',{M.meas});
   grads = diff(data,1,2);
   if strmatch('grad-med',{M.meas},'exact'), m = strmatch('grad-med',{M.meas},'exact');
          if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                              ' *** Statistic: '   char({M(m).stat}) ...
                              ' *** Criterion: ' num2str(M(m).crit)]); end
          meas = median(abs(grads'));
          [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
          viol(meas>crit,m) = 1;
   end
   if strmatch('grad-max',{M.meas},'exact'), m = strmatch('grad-max',{M.meas},'exact');
          if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                              ' *** Statistic: '   char({M(m).stat}) ...
                              ' *** Criterion: ' num2str(M(m).crit)]); end
          meas = max(abs(grads'));
          [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
          viol(meas>crit,m) = 1;
   end
end
%zero-crossings
if strmatch('fqvar',{M.meas}), m = strmatch('fqvar',{M.meas});
   if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                       ' *** Statistic: '   char({M(m).stat}) ...
                       ' *** Criterion: ' num2str(M(m).crit)]); end
   zcmtx = data-repmat(mean(data'), [ncol 1])'; %remove row means
   zcmtx = diff(sign(zcmtx),1,2);               %first difference of sign (-1, 0, 1)
   meas  = sum(abs(zcmtx')==2).*var(data');     %number of sample-to-sample zero-crossings
   [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
   viol(meas>crit,m) = 1;
end
%spatial PCA 
if strmatch('spPCA',{M.meas}), m = strmatch('spPCA',{M.meas});
   if verbose>0, disp('   artifact_channels; Computing spatial PCA coefficients...'); end
   pcmtx = zeros(size(data,1),nrow);
   ti  = 1:nrow:(nrow*(nswp-1))+1;
   for tj = 1:length(ti),
       pcmtx(ti(tj):ti(tj)+nrow-1,:) = princomp(data(ti(tj):ti(tj)+nrow-1,:)','econ');
   end
       if strmatch('spPCA-max',{M.meas},'exact'), m = strmatch('spPCA-max',{M.meas},'exact');
          if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                              ' *** Statistic: '   char({M(m).stat}) ...
                              ' *** Criterion: ' num2str(M(m).crit)]); end
             meas = max(abs(pcmtx'));
             [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
             viol(meas>crit,m) = 1;
       end
       if strmatch('spPCA-med',{M.meas},'exact'), m = strmatch('spPCA-med',{M.meas},'exact');
          if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                              ' *** Statistic: '   char({M(m).stat}) ...
                              ' *** Criterion: ' num2str(M(m).crit)]); end
             meas = median(abs(pcmtx'));
             [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
             viol(meas>crit,m) = 1;
       end
       if strmatch('spPCA-diff',{M.meas},'exact'), m = strmatch('spPCA-diff',{M.meas},'exact');
          if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                              ' *** Statistic: '   char({M(m).stat}) ...
                              ' *** Criterion: ' num2str(M(m).crit)]); end
             pcmtx = pcmtx.^2;
             meas  = zeros(size(data,1),1);
             for tj = 1:length(ti),
                 [xi yi] = sort(pcmtx(ti(tj):ti(tj)+nrow-1,:)','descend');
                 meas(ti(tj):ti(tj)+nrow-1) = (xi(1,:)-xi(2,:));
             end  
             [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
             viol(meas>crit,m) = 1;
       end
end
%correlation measures
if strmatch('corr',{M.meas}), m = strmatch('corr',{M.meas});
   corrmtx = zeros(size(data,1),nrow);
   ti  = 1:nrow:(nrow*(nswp-1))+1;
   for tj = 1:length(ti),
       corrmtx(ti(tj):ti(tj)+nrow-1,:) = corrcoef(data(ti(tj):ti(tj)+nrow-1,:)');
   end
       if strmatch('corr-max',{M.meas},'exact'), m = strmatch('corr-max',{M.meas},'exact');
          if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                              ' *** Statistic: '   char({M(m).stat}) ...
                              ' *** Criterion: ' num2str(M(m).crit)]); end
             k = abs(corrmtx);
             k = sort(k,2,'descend');
             meas = k(:,2);
             [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
             viol(meas>crit,m) = 1;
       end
       if strmatch('corr-zmax',{M.meas},'exact'), m = strmatch('corr-zmax',{M.meas},'exact');
          if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                              ' *** Statistic: '   char({M(m).stat}) ...
                              ' *** Criterion: ' num2str(M(m).crit)]); end
             k = atanh(corrmtx); %fisher's z
             k = sort(k,2,'descend');
             meas = k(:,2);
             [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
             viol(meas>crit,m) = 1;
       end
       if strmatch('corr-min',{M.meas},'exact'), m = strmatch('corr-min',{M.meas},'exact');
          if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                              ' *** Statistic: '   char({M(m).stat}) ...
                              ' *** Criterion: ' num2str(M(m).crit)]); end
             k = abs(corrmtx);
             k = sort(k,2,'descend');
             meas = k(:,end);
             [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
             viol(meas>crit,m) = 1;
       end
       if strmatch('corr-zmin',{M.meas},'exact'), m = strmatch('corr-zmin',{M.meas},'exact');
          if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                              ' *** Statistic: '   char({M(m).stat}) ...
                              ' *** Criterion: ' num2str(M(m).crit)]); end
             k = atanh(corrmtx); %fisher's z
             k = sort(k,2,'descend');
             meas = k(:,end);
             [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
             viol(meas>crit,m) = 1;
       end
       if strmatch('corr-med',{M.meas},'exact'), m = strmatch('corr-med',{M.meas},'exact');
          if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                              ' *** Statistic: '   char({M(m).stat}) ...
                              ' *** Criterion: ' num2str(M(m).crit)]); end
             k = abs(corrmtx);
             meas = median(k');
             [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
             viol(meas>crit,m) = 1;
       end
end
if strmatch('Vdist',{M.meas}),
   if verbose>0, disp('   artifact_channels; Computing electrical-distances...'); end
   distmtx = zeros(size(data,1),nrow);
   ti  = 1:nrow:(nrow*(nswp-1))+1;
   for tj = 1:length(ti),
       distmtx(ti(tj):ti(tj)+nrow-1,:) = get_elecdists(data(ti(tj):ti(tj)+nrow-1,:));
   end
       if strmatch('Vdist-med',{M.meas},'exact'), m = strmatch('Vdist-med',{M.meas},'exact');
          if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                              ' *** Statistic: '   char({M(m).stat}) ...
                              ' *** Criterion: ' num2str(M(m).crit)]); end
             meas = median(distmtx');
             [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
             viol(meas>crit,m) = 1;
       end
       if strmatch('Vdist-min',{M.meas},'exact'), m = strmatch('Vdist-min',{M.meas},'exact');
          if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                              ' *** Statistic: '   char({M(m).stat}) ...
                              ' *** Criterion: ' num2str(M(m).crit)]); end
           distmtx = sort(distmtx,2);
           meas    = distmtx(:,2);
           [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
           viol(meas<crit,m) = 1;
       end
       if strmatch('Vdist-nearest',{M.meas},'exact'), m = strmatch('Vdist-nearest',{M.meas},'exact');
          if verbose>0, disp(['   *** Measure: '   char({M(m).meas}) ...
                              ' *** Statistic: '   char({M(m).stat}) ...
                              ' *** Criterion: ' num2str(M(m).crit)]); end
           distmtx = sort(distmtx,2);
           meas    = distmtx(:,2);
           [meas, crit] = thresholder(M(m).stat, meas, M(m).crit);
           viol(meas>crit,m) = 1;
       end
end


%% -- construct output -- %%
viol   = logical(viol);
if     nargin>2&(size(viol,2)>1)&joint>0,
   indices = find(sum(viol')==size(viol,2));
elseif nargin>2&(size(viol,2)>1)&joint==0,
   indices = find(sum(viol')>0)';
else 
   indices = find(viol==1)';
end

