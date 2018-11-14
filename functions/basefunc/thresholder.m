% thresholder() - adjust input values/criterion for desired statistical thresholding
%
% Usage:
%   >> [meas, crit] = thresholder(stat, meas, crit)
%
% Inputs: 
%   stat      - method for statistical thresholding:
%               Options:
%                    'abs' - absolute value
%                 'zscore' - z-score
%                   'nMAD' - normalized median absolute deviation (robust)
%                    'nAD' - normalized mean absolute deviation
%                    'IQR' - normalized interquartile range (robust)
%                     'EM' - expectation-maximization (ADJUST toolbox)
%                            note: mean subtracted from input "meas",
%                            3rd-moment of distribution assessed and if
%                            negative, "meas" multiplied by -1 to make positively
%                            skewed.
%   meas      - input values [1xN vector]
%   crit      - positive non-zero integer
%
% Outputs:
%   meas      - adjusted values    (if applicable)
%   crit      - adjusted criterion (if applicable)
%
% Scott Burwell, March 2011
function [meas, crit] = thresholder(stat, meas, crit);

switch stat, 

  case 'abs',    %absolute threshold cutoff
    crit = crit;
    meas = abs(meas);

  case 'nMAD',   %normalized median absolute deviation
    sigma= 1.4826;
    crit = crit*(sigma*mad(meas,1)); 
    meas = abs(meas-median(meas)); 

  case 'nAD',    %normalized mean absolute deviation
    sigma= 1.2530;
    crit = crit*(sigma*mad(meas,0));
    meas = abs(meas-mean(meas));

  case 'IQR',    %normalized inter-quartile range
    sigma= 0.7413;
    crit = crit*(sigma*iqr(meas));
    meas = abs(meas-median(meas));

  case 'zscore', %standardized scores
    crit = crit;
    meas = abs(zscore(meas));

  case 'med-sd', %median-based standard deviation (Junghofer, et al., 2000; Psychophysiology)
    mstd = sqrt(sum((meas-median(meas)).^2)/length(meas));
    meas =  abs((meas-median(meas))./mstd);
    crit = crit;

  case 'EM',     %expectation maximization (ADJUST toolbox)
    if exist('EM')~=2, disp('WARNING: EM() not defined, add path to ADJUST package (EEGLAB plugin).'); end
    % I don't know if subtracting the mean is appropriate for all types of measures...
    % meas = meas-mean(meas);
    % meas = abs(meas-median(meas));
    meas = meas-median(meas);
    if moment(meas,3)<0, %determine direction of skew.  If negative, flip distribution
       meas = meas*-1;
    end
    crit = EM(meas);

end

