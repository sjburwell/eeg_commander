% CSD - Current Source Density (CSD) transformation based on spherical spline
%       surface Laplacian as suggested by Perrin et al. (1989, 1990)
%
% (published in appendix of Kayser J, Tenke CE, Clin Neurophysiol 2006;117(2):348-368)
%
% Usage: [X, Y] = CSD(Data, G, H, lambda, head);
%
% Implementation of algorithms described by Perrin, Pernier, Bertrand, and
% Echallier in Electroenceph Clin Neurophysiol 1989;72(2):184-187, and 
% Corrigenda EEG 02274 in Electroenceph Clin Neurophysiol 1990;76:565.
% 
% Input parameters:
%   Data = surface potential electrodes-by-samples matrix
%      G = g-function electrodes-by-electrodes matrix
%      H = h-function electrodes-by-electrodes matrix
% lambda = smoothing constant lambda (default = 1.0e-5)
%   head = head radius (default = no value for unit sphere [µV/m²])
%          specify a value [cm] to rescale CSD data to smaller units [µV/cm²]
%          (e.g., use 10.0 to scale to more realistic head size)
%
% Output parameter:
%      X = current source density (CSD) transform electrodes-by-samples matrix
%      Y = spherical spline surface potential (SP) interpolation electrodes-
%          by-samples matrix (only if requested)
%
% Copyright (C) 2003 by Jürgen Kayser (Email: kayserj@pi.cpmc.columbia.edu)
% GNU General Public License (http://www.gnu.org/licenses/gpl.txt)
% Updated: $Date: 2005/02/11 14:00:00 $ $Author: jk $
%        - code compression and comments 
% Updated: $Date: 2007/02/07 11:30:00 $ $Author: jk $
%        - recommented rescaling (unit sphere [µV/m²] to realistic head size [µV/cm²])
%   Fixed: $Date: 2009/05/16 11:55:00 $ $Author: jk $
%        - memory claim for output matrices used inappropriate G and H dimensions
%   Added: $Date: 2009/05/21 10:52:00 $ $Author: jk $
%        - error checking of input matrix dimensions
%
function INTData = sph_surface_interp(REAL,INTERP) %args.[lambda, head];

%
%    REAL   = struct('data', EEG.data(chanvec,:,I_out(swp)), ...
%                       'G', input_G,                        ...
%                       'H', input_H,                        ...
%                'chanlocs', EEG.chanlocs(chanvec));
%    INTERP = struct(   'G', G,                              ...
%                       'H', H,                              ...
%                'chanlocs', EEG.chanlocs);

keyboard

%check for G, H, etc.

Data          = REAL.data;
[nElec,nPnts] = size(Data);            % get data matrix dimensions
G = REAL.G;
H = REAL.H;
INTData       = zeros( 

%G             = INTERP.G;

% Perrin co-efficients
mu = mean(Data);                       % get grand mean
Z = (Data - repmat(mu,nElec,1));       % compute average reference
Y = zeros(size(INTERP.G,2),nPnts);  
head = 1.0;                            % initialize scaling variable [µV/m²]
head = head * head;                    % or rescale data to head sphere [µV/cm²]
lambda = 1.0e-5;                       % initialize smoothing constant

%for e = 1:size(G,1);                   % add smoothing constant to diagonale
%  G(e,e) = G(e,e) + lambda; 
%end; 
for e = 1:size(G,1);
   for p = size(G,2)
       G(e,p) = G(e,p) + lambda;
   end
end


%Gi = inv(G);                           % compute G inverse
Gi = 1\G;
for i = 1:size(Gi,1);                  % compute sums for each row
  TC(i) = sum(Gi(i,:));
end;

sgi = sum(TC);                         % compute sum total
for p = 1:nPnts
  Cp = Gi * Z(:,p);                    % compute preliminary C vector
  for e=1:size(G,1)
   %   Y(e,p) = Cp(e,p) + g * Cp(

%  c0 = sum(Cp) / sgi;                  % common constant across electrodes
%  C = Cp - (c0 * TC');                 % compute final C vector
%  for e = 1:size(G,1);     % if requested ...
%    Y(e,p) = c0 + sum(C .* G(e,:)');   % ... compute all SPs
%  end;
%  for e = 1:size(INTERP.G,2)
%      Y(e,p) = c0 
end
end;

