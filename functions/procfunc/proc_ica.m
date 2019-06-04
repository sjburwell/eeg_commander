% proc_ica() - input continuous or epoched data with additional options to output 
%              ICA weights and sphere
%
% Usage:
%   >> OUTEEG = proc_ica(INEEG, varargin);
%
% Inputs:
%   INEEG       - input EEG data structure
%
% Optional inputs ('key','val'):
%   'type'      - 'runica'; only option now
%   'datafilt'  - 1 = non-artifact epochs (default); 0 = all epochs
%                 note: uses eeg_rejsuperpose(), rejections stored in fields
%                       EEG.reject.rejglobal & EEG.reject.rejglobalE
%   'opts'      - cell-string array; see help for ica function (e.g. runica.m)
%
% Outputs:
%   OUTEEG      - modified EEG structure
%
% Scott Burwell, May 2011
%
% See also: runica
function EEG = proc_ica(EEG, varargin);

if nargin<2,
   disp('Insufficient input, abort');
end
if length(varargin)==1,
   args = varargin{:};
else,
   args = struct(varargin);
end
if ~isfield(args, 'opts'),
    args.opts = [];
end
EEG = eeg_hist(EEG, ['EEG = ' mfilename '(EEG, ' arg2str(args) ');'] );



% specify input data matrix
if isfield(args,'datafilt') && EEG.trials>1 && args.datafilt>0,
   EEG.reject.rejglobal = []; EEG.reject.rejglobalE = [];
   EEG = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1);
   filtelx = find(sum(EEG.reject.rejglobalE')<EEG.trials);
   filtepx = find(sum(EEG.reject.rejglobalE )<EEG.nbchan); % EEG.reject.rejglobal   ==0);
   filtttl = zeros(size(EEG.reject.rejglobalE));
   filtttl(filtelx,filtepx) = 1; filtttl = find(filtttl);
elseif EEG.trials>1,
   filtelx = find(ones(1,EEG.nbchan));
   filtepx = find(ones(1,EEG.trials));
   filtttl = find(ones(EEG.nbchan,EEG.trials));
else,
   filtelx = find(ones(1,EEG.nbchan));
   filtepx = find(ones(1,EEG.trials));
   filtttl = find(ones(EEG.nbchan,EEG.trials));
end

%prep data
icadata = EEG.data(filtelx,:,filtepx);
for ee=1:size(icadata,3), icadata(:,:,ee)=icadata(:,:,ee)-repmat(mean(icadata(:,:,ee)')',1,size(icadata,2)); end
icadata = reshape(permute(double(icadata), [2 3 1]), [size(icadata,2)*size(icadata,3) size(icadata,1)])';
if isa(EEG.data,'single'), icadata = single(icadata); end

%make sure actual data exists
if size(icadata)==[0  0], disp(['   proc_ica; data matrix for ica empty, aborting operation (' EEG.filename ')...']); return; end

K_ica = round(size(icadata,2)/(EEG.nbchan^2));
disp(['   proc_ica; k-value ( points/(channels^2) ) for ' EEG.filename ': ' num2str(K_ica) ]);
switch args.type,

   case 'runica',
     if ~isempty(args.opts),
        [EEG.icaweights, EEG.icasphere] = runica(icadata, args.opts{:});
     else,
        [EEG.icaweights, EEG.icasphere] = runica(icadata);
     end

   case 'fastica',
     if ~isempty(args.opts),
        [tmpjnk, EEG.icawinv, EEG.icaweights] = fastica(icadata, 'displayMode', 'off', args.opts{:});
     else,
        [tmpjnk, EEG.icawinv, EEG.icaweights] = fastica(icadata, 'displayMode', 'off');
     end
     if isempty(EEG.icasphere)
        EEG.icasphere  = eye(size(EEG.icaweights,2));
     end;

   case 'amica',
     if ~exist('runamica15'), disp(['Must have amica15 in path, see: https://sccn.ucsd.edu/~jason/amica_web.html']); return; end
     if ~isempty(args.opts),
        [EEG.icaweights, EEG.icasphere, mods] = runamica15(icadata, args.opts{:});
     else,
        [EEG.icaweights, EEG.icasphere, mods] = runamica15(icadata);
     end

   otherwise,
     disp(['Invalid entry for ICA algorithm: ' args.type ', using default runica()']);
     [EEG.icaweights, EEG.icasphere] = runica(icadata);
end
EEG.icachansind = find(filtelx); %SJB: 2018-11-13

if ~isempty(EEG.icawinv), 
   if ~isreal(EEG.icawinv), disp(['   proc_ica; ICA decomposition for ' EEG.filename ' contains complex-valued weights.']); end
end


