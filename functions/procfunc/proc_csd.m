% proc_csd() - Convert EEG structured data to Current Source Density (CSD) or
%              spherical spline surface laplacian (SP) via the CSD-toolbox
%              See: Kayser J, Tenke CE, Clin Neurophysiol 2006;117(2):348-368
%
% Usage:
%   >> OUTEEG = proc_csd(INEEG, varargin);
%  
% Inputs:
%   INEEG      - input EEG data structure
%
% Optional inputs ('key','val'):
%   'montage'  - filename with spherical coordinates for CSD transform
%                *See ExtractMontage (CSD Toolbox; default CSD-toolbox)
%   'lambda'   - smoothing constant             (default = 1.0e-5)
%   'headrad'  - head radius (cm)               (default = 10.0)
%   'spline_m' - specify spline-flexibility     (default = 4)
%   'outdata'  - Returned data transform:
%                -Current Source Density (default)   = 'CSD'  
%                -Spherical spline surface potential = 'SP'
%   'CSDparms' - filename of structured mat-file for G- and H-matrices
%                invariant for a given montage. This computation is rather
%                timely, so if the channel locations for each iteration is
%                certianly identical, it is wise to use this option.  Will 
%                generate if first time and load for subsequent transform 
%                iterations.                    (default = [])
%
% Outputs:
%   OUTEEG     - Output EEG data structure (transformed data)
%
% Scott Burwell, July 2011
%
% See also: proc_interp, CSD-toolbox
function EEG = proc_csd(EEG, varargin);

%CSDpath = '/labs/mctfr-psyphys/shared_apps/CSDtoolbox'; addpath(genpath(CSDpath)); %drop this line?

if nargin<2,
   disp('Insufficient input, abort');
   return;
end
if length(varargin)==1,
   args = varargin{:};
else,
   args = struct(varargin); % changed from >>args = struct(varargin{:}); %changed from >>args = struct(varargin);
end
EEG = eeg_hist(EEG, ['EEG = ' mfilename '(EEG, ' arg2str(args) ');'] );

if ~isfield(args,'montage')||isempty(args.montage),
   args.montage = '10-5-System_Mastoids_EGI129.csd';
end
if ~isfield(args,'lambda')||isempty(args.lambda),
   args.lambda = 1.0e-5;
end
if ~isfield(args,'headrad')||isempty(args.headrad),
   args.headrad = 10.0;
end
if ~isfield(args,'spline_m')||isempty(args.spline_m),
   args.spline_m = 4;
end
if ~isfield(args,'outdata')||isempty(args.outdata),
   args.outdata = 'CSD'; %or 'SP' spherical spline surface potential
end
if ~isfield(args,'CSDparms')||isempty(args.CSDparms),
   args.CSDparms = [];
end

% read-in montage
if ~exist(args.montage,'file'),
   disp('   proc_csd; Invalid montage file specified, operation cancelled.');
   return
else,
   montage = ExtractMontage(args.montage, ({EEG.chanlocs.labels}'));
end

% G (surface potential), H (CSD) computation
if ~isempty(args.CSDparms)&&exist(args.CSDparms,'file'),
    disp(['   proc_csd; loading existing CSD parameters: ' args.CSDparms])
    load(args.CSDparms);
else,
    [CSDparms.G, CSDparms.H] = GetGH(montage, args.spline_m);
end

% make data 2D if necessary
npts=size(EEG.data,2); nchans=size(EEG.data,1); ntrials=size(EEG.data,3);
if ntrials > 1
   data = reshape(permute(double(EEG.data), [2 3 1]), [ntrials*npts nchans])';
else,
   data = EEG.data;
end

% compute CSD/SP
if strcmp(args.outdata,'CSD'),
   EEG.data = CSD(data, CSDparms.G, CSDparms.H, args.lambda, args.headrad);
   EEG.ref  = {'CSD'};
elseif strcmp(args.outdata,'SP'),
   [junk, EEG.data] = CSD(data, CSDparms.G, CSDparms.H, args.lambda, args.headrad);
   EEG.ref  = {'SP'};
end

% save CSD parameters, if necessary
if ~isempty(args.CSDparms)&&~exist(args.CSDparms,'file'),
   disp(['   proc_csd; saving CSD-spline parameters: ' args.CSDparms]);
   save(args.CSDparms,'CSDparms');
end

% clean up dimensionality (e.g., if concatenated epochs)
EEG = eeg_checkset(EEG); 
