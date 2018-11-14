% proc_artifact() - artifact routine for the processing stream.  Utilizes lower level 
%                   functions artifact_epochs, artifact_channels, and thresholder for 
%                   artifact tagging within a transparent interface.
%
% Usage:
%   >> OUTEEG = proc_artifact(INEEG, args);
%  
% Inputs:
%   INEEG      - input EEG data structure
%
% Additional inputs (as structured variable):
%   'type'     - ['channel' | 'epoch' | 'chan-epoch']
%   'datafilt' - input only non-tagged data (uses eeg_rejsuperpose; ie EEG.reject.rejglobal==0)
%                0 = no (default)
%                1 = yes
%   'interp'   - interpolate marked channels
%                0 = no (default)
%                1 = yes
%   'reject'   - delete marked channels/epochs
%                0 = no (default)
%                1 = yes
%   'opts'     - parameters for artifact tagging (structured variable) with
%                four input fields:
%                Ex: opts  [.meas] = measure (cellstr); 
%                                    options: see artifact_channel(), artifact_epochs()
%                          [.stat] = thresholding routine (cellstr); 
%                                    options: see thresholder()
%                          [.crit] = cutoff for threshold (numeric); 
%                                    options: see thresholder()
%                         [.joint] = joint thresholding
%                                    0 = no (default)
%                                    1 = yes
% 
% Outputs:
%   OUTEEG     - output EEG data structure
%
% Scott Burwell, May 2011
%
% See also: artifact_epochs, artifact_channels, thresholder
function EEG = proc_artifact(EEG, args);

if nargin<2,
   disp('Insufficient input, abort');
end
%if length(varargin)==1,
%   args = varargin{:};
%else,
%   args = struct(varargin);
%end
for aa = 1:length(args.opts),
    EEG = eeg_hist(EEG, ['EEG = ' mfilename '(EEG,   struct('  arg2str(args) ' ''opts'', struct(' arg2str(args.opts(aa)) ')));'] );
end

% artifact fields, rejmanual
EEG.reject.rejmanualcol = [.5 .5 .5];
if size(EEG.reject.rejmanual )~=[1          EEG.trials], EEG.reject.rejmanual =zeros([1          EEG.trials]); end
if size(EEG.reject.rejmanualE)~=[EEG.nbchan EEG.trials], EEG.reject.rejmanualE=zeros([EEG.nbchan EEG.trials]); end

% specify input data matrix
if isfield(args,'datafilt') && args.datafilt>0,
   EEG.reject.rejglobal = []; EEG.reject.rejglobalE = [];
   EEG = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1);
   filtelx = find(sum(EEG.reject.rejglobalE')<EEG.trials);
   filtepx = find(sum(EEG.reject.rejglobalE )<EEG.nbchan); % EEG.reject.rejglobal   ==0);
   filtttl = zeros(size(EEG.reject.rejmanualE));
   filtttl(filtelx,filtepx) = 1; filtttl = find(filtttl);
else,
   filtelx = find(ones(1,EEG.nbchan));
   filtepx = find(ones(1,EEG.trials));
   filtttl = find(ones(EEG.nbchan,EEG.trials));
end

switch args.type,

   case 'channel',
     disp('proc_artifact; "channel" has been depreciated, please use "matrix"');
     return
     v = 1;
      for ii = 1:length({args.opts.meas}),
          bad_elecs = [];
          if isfield(args.opts(ii),'joint')&&~isempty(args.opts(ii).joint);
             j = args.opts(ii).joint;
          else,
             j = 0;
          end
          inopts = struct('meas', args.opts(ii).meas, ...
                          'stat', args.opts(ii).stat, ...
                          'crit', args.opts(ii).crit);
          bad_elecs = artifact_channels( EEG.data(filtelx,:,filtepx), inopts, j, v);
          if ~isempty(bad_elecs); disp(['   DETECTED: ' num2str(filtelx(bad_elecs))]); end
          EEG.reject.rejmanualE(filtelx(bad_elecs),:,:) = 1; 
      end
      bad_elecs = find(sum(EEG.reject.rejmanualE')==EEG.trials); 
      if ~isempty(bad_elecs),
         if     isfield(args,'interp') && args.interp> 0, interp_on = 1;
         elseif isfield(args,'interp') && args.interp<=0, interp_on = 0;
         else,  interp_on = 0;
         end
         if     isfield(args,'reject') && args.reject> 0, reject_on = 1;
         elseif isfield(args,'reject') && args.reject<=0, reject_on = 0;
         else,  reject_on = 0;
         end
         if     interp_on==1,
            EEG = eeg_interp( EEG, bad_elecs, 'spherical');
         elseif reject_on==1&&interp_on==0,
            tmprej = EEG.reject;
            EEG = pop_select( EEG, 'nochannel', bad_elecs);
            %EEG = eeg_hist(EEG, ['EEG = pop_select(EEG,''nochannel'',[' num2str(bad_elecs) ']); % label(s): ' EEG.chanlocs(bad_elecs).label]);
            EEG.reject = tmprej; EEG.reject.rejmanualE(bad_elecs,:) = '';
         end
      end 

   case 'epoch',
      %disp('proc_artifact; "epoch" has been depreciated, please use "matrix"');
      v = 1;
      bad_epochs = [];
      for ii = 1:length({args.opts.meas}),
          if isfield(args.opts(ii),'joint')&&~isempty(args.opts(ii).joint);
             j = args.opts(ii).joint;
          else,
             j = 0;
          end
          inopts = struct('meas', args.opts(ii).meas, ...
                          'stat', args.opts(ii).stat, ...
                          'crit', args.opts(ii).crit);
          bad_epochs = unique([bad_epochs artifact_epochs( EEG.data(filtelx,:,filtepx), inopts, j, v)']);
          if ~isempty(bad_epochs); disp(['   Number of epochs detected for ' EEG.filename ': ' num2str(length(filtepx(bad_epochs))) '/' num2str(EEG.trials)]); end
          EEG.reject.rejmanual   (filtepx(bad_epochs)) = 1;
          EEG.reject.rejmanualE(:,filtepx(bad_epochs)) = 1;
      end
      if ~isempty(bad_epochs) && isfield(args,'reject') && args.reject>0,
         tmprej = EEG.reject;
         EEG = pop_select( EEG, 'notrial', bad_epochs);
         %EEG = eeg_hist(EEG, ['EEG = pop_select(EEG,''notrial'',[' num2str(bad_epochs) ']);']);
         EEG.reject = tmprej;
         EEG.reject.rejmanual(bad_epochs) = ''; EEG.reject.rejmanualE(:,bad_epochs) = '';
      end
      if isfield(args,'interp') && args.interp>0,
         disp('Warning: cannot interpolate whole epochs.');
      end

   case 'matrix',
      v = 1;
      for ii = 1:length({args.opts.meas}),
          bad_idc = [];
          if isfield(args.opts(ii),'joint')&&~isempty(args.opts(ii).joint),
             j = args.opts(ii).joint;
          else,
             j = 0;
          end
          inopts = struct('meas', args.opts(ii).meas, ...
                          'stat', args.opts(ii).stat, ...
                          'crit', args.opts(ii).crit);
          bad_idc = artifact_channels( EEG.data(filtelx,:,filtepx), inopts, j, v);
          if ~isempty(bad_idc), disp(['   TOTAL INDICES DETECTED: ' num2str(length(bad_idc))]); 
              EEG.reject.rejmanualE(filtttl(bad_idc)) = 1;
          else,                 disp( '   NONE DETECTED, MOVING ON...');
          end
       end
       if ~isempty(find(EEG.reject.rejmanualE)),
          if isfield(args,'pthreshchan' ) && (args.pthreshchan >0 && args.pthreshchan<1 ),
             rchans = find((sum(EEG.reject.rejmanualE')/EEG.trials)>args.pthreshchan);
             if ~isempty(rchans), EEG.reject.rejmanualE(rchans,:) = 1; end
          end
          if isfield(args,'minchans') && (args.minchans > 0),
             templocs = readlocs('montage10-10_sphrad1_n61.ced');                                           %this section kludge
             rdc_matrix = EEG.reject.rejmanualE(find(ismember({EEG.chanlocs.labels},{templocs.labels})),:); 
             rtrials = find(EEG.nbchan-(sum(rdc_matrix))<args.minchans);
             if ~isempty(rtrials), EEG.reject.rejmanualE(:,rtrials) = 1; end
          end
          if     isfield(args,'rejchan') && args.rejchan> 0, chanrej_on = 1;
          elseif isfield(args,'rejchan') && args.rejchan<=0, chanrej_on = 0;
          else,  chanrej_on = 0;
          end
          if     isfield(args,'rejtrial') && args.rejtrial> 0, trialrej_on = 1;
          elseif isfield(args,'rejtrial') && args.rejtrial<=0, trialrej_on = 0;
          else,  trialrej_on = 0;
          end
          if chanrej_on>0&&~isempty(find(sum(EEG.reject.rejmanualE')==EEG.trials)),
             delete_chan = find(sum(EEG.reject.rejmanualE')==EEG.trials);
             tmprej = EEG.reject;
             delstring = []; for d = 1:size(delete_chan,2), delstring = [delstring ' ' char({EEG.chanlocs(delete_chan(d)).labels})]; end
             disp(['   proc_artifact; The following channel(s) will be deleted for ' EEG.filename ': ' delstring]);
             EEG = pop_select( EEG, 'nochannel', delete_chan);
             EEG.reject = tmprej; EEG.reject.rejmanualE(delete_chan,:) = '';
          end
          if trialrej_on>0&&~isempty(find(sum(EEG.reject.rejmanualE)==EEG.nbchan)),
             delete_trial = find(sum(EEG.reject.rejmanualE)==EEG.nbchan);
             if length(delete_trial)==EEG.trials,
                disp(['   proc_artifact; all trials artifact for ' EEG.filename ', deleting all data...']);
                EEG = pop_select(EEG, 'nochannel', 1:EEG.nbchan);
             else,
                tmprej = EEG.reject;
                EEG = pop_select( EEG, 'notrial', delete_trial);
                EEG.reject = tmprej; 
                EEG.reject.rejmanual(   delete_trial) = '';
                EEG.reject.rejmanualE(:,delete_trial) = '';                   
             end
          end
          %EEG.reject.rejmanual(find(sign(sum(EEG.reject.rejmanualE)))) = 1;  
          EEG.reject.rejmanual = double(sum(EEG.reject.rejmanualE)>0);
   end

   case 'chan-epoch',
      v = 0;
      tic
      for ii = 1:length({args.opts.meas}),
          if isfield(args.opts(ii),'joint')&&~isempty(args.opts(ii).joint);
             j = args.opts(ii).joint;
          else,
             j = 0;
          end
          inopts = struct('meas', args.opts(ii).meas, ...
                          'stat', args.opts(ii).stat, ...
                          'crit', args.opts(ii).crit);
          for tt = 1:EEG.trials,
              EEG.reject.rejmanualE(artifact_channels(EEG.data(:,:,tt),inopts,j,v),tt) = 1;
          end
      end
      toc
      EEG.reject.rejmanual(find(sum(EEG.reject.rejmanualE))) = 1;
      if ~isempty(find(EEG.reject.rejmanualE)),
         if     isfield(args,'interp') && args.interp> 0, interp_on = 1;
         elseif isfield(args,'interp') && args.interp<=0, interp_on = 0;
         else,  interp_on = 0;
         end
         if     isfield(args,'reject') && args.reject> 0, reject_on = 1;
         elseif isfield(args,'reject') && args.reject<=0, reject_on = 0;
         else,  reject_on = 0;
         end
      end
      if reject_on==1,
         disp('Rejection of individual elements of 3D array not allowed, skipping chan-epoch rejection');
      end
      if interp_on==1,
         EEG = eeg_interp3d_spl(EEG, EEG.reject.rejmanualE);
         %EEG = eeg_hist(EEG, 'EEG = eeg_interp3d_spl(EEG, EEG.reject.rejmanualE);');
      end

end


