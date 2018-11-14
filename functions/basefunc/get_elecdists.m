% get_elecdists() - generate electrical-distance matrix and corresponding intrinsic-Hjorth 
%                   waveforms for channel-by-datapoint matrix.
%                   cf. Tenke & Kayser (2001). Clin. Neurophys., 112, 545-550.
%
% Usage:
%   >> [distmtx, distlist, iHjorth]  = get_elecdists(data, proportion)
%
% Inputs:
%   data       - channel-datapoint matrix
%   proportion - fraction of datapoints to sample
%
% Outputs:
%   distmtx    - channel-channel matrix of electrical-distance
%   distlist   - sorted inter-channel distance values
%   iHjorth    - channel intrinsic-Hjorth waveforms
%
% See also:
%   elec_dist
%
% Scott Burwell, October, 2010
function [distmtx, distlist, iHjorth] = get_elecdists(data, proportion);

elex = size(data, 1); 
if exist('proportion')&&~isempty(proportion),
   pts = floor(proportion*size(data,2));
   pts = 1:floor(size(data,2)/pts):size(data,2);   
else
   pts = 1:size(data,2);
end


%electrical distance
npts     = size(pts,2);
distmtx  = zeros(elex, elex);
data     = data - repmat(mean(data,2),[1  size(data,2)]);
for ii = 1:elex
    diffs         = repmat(data(ii,:),[size(data,1) 1])-data;
    edists        = var(diffs');
    distmtx(ii,:) = edists;
end

if nargout>2,
   for ii=1:elex,
       clear val idx
       [val, idx]    = min(distmtx(ii,[1:ii-1, ii+1:end]));
       iHjorth(ii,:) = squeeze(data(ii,pts))-squeeze(data(idx,pts));
   end
end

%take interelectrode values only
dists = sort(reshape(tril(distmtx,-1),elex*elex,1));
dists = dists([(elex*elex)-(((elex*elex)-elex)/2)]+1:(elex*elex),:);
distlist = dists;

