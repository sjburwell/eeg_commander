function [EEG, HDR] = bdf2eeg(varargin);
% BDF2EEG  Reads file in .BDF format and places data in EEGLAB format (EEG struct)
%
% Required inputs: data directory ('pathname')
%                  filename ('filename')
%
% Optional inputs: re-reference                     ('reference')    DEFAULT= 'none'
%                  resample                         ('resample')     DEFAULT=256; 0 or [] for none
%                  high-pass filter freq            ('lowfreq')      DEFAULT=0.1
%                  filter transition band width     ('trans_width')  DEFAULT=1
%                  swap electrodes                  ('swap_elecs')   DEFAULT='none'; use cell array even with only 2 elements
%                  verbose                          ('verbose')      DEFAULT=1; or 0 for less
%
% Outputs:         EEGLAB-formatted data structure
%                  Optional HDR structure containing information from .BDF header
%
% NB: Function expects input arguments in form of key-value pairs
% Example: [BDF, HDR] = bdf2eeg( ...
%                                   'pathname',     '/mtfs/data/foobar/',    ...
%                                   'filename',     'datafile.bdf',          ...
%                                   'reference',     'CZ',                   ...
%                                   'resample',      1,                      ...
%                                   'lowfreq',       0,                      ...
%                                   'verbose',       0,                      ...
%                                   'trans_width',   2,                      ...
%                                   'swap_elecs',   {'TP8'}                  ...  %swaps w/ 'Unused'
%                              )
%
% Choices for reference are 'ears', 'averef', or a single reference as string (e.g., 'CZ' or 'Ref1'), or 'none'
%
% Filtering uses a Kaiser window and the FIRFILT plugin of Andreas Widmann

if nargin < 1
    [args.filename args.pathname] = uigetfile2('*.bdf;*.BDF', 'Select BioSemi BDF file for read');
    if args.filename == 0, return, end
else
    args = struct(varargin{:});
end
if prod(size(args)) ~= 1
    help bdf2eeg
    error(['Input arguments are not in correct form. ' ...
        'Triggers must be a VALUE cell array. (See help above)'])
end
if ~isfield(args, 'filename') || isempty(args.filename)
    error('Filename not specified.')
end
if ~isfield(args, 'pathname')
    args.pathname = pwd;
end
id = regexprep(args.filename, '.bdf', '');

% optional arguments
if ~isfield(args, 'reference') || isempty(args.reference)
    args.reference = 'none';
end
if ~isfield(args, 'lowfreq') || isempty(args.lowfreq)
    args.lowfreq = 0.1;
end
if ~isfield(args, 'trans_width') || isempty(args.trans_width)
    args.trans_width = 1;
end
if ~isfield(args, 'resample')
    args.resample = 256;
end
if isempty(args.resample), args.resample = 0; end
if ~isfield(args, 'swap_elecs') || isempty(args.swap_elecs)
    args.swap_elecs = '';
else  
    if isempty([strmatch('Ref',args.swap_elecs) strmatch('Veog',args.swap_elecs) strmatch('Heog',args.swap_elecs) ...
                strmatch('Status', args.swap_elecs) strmatch('Unused', args.swap_elecs)])
       args.swap_elecs = upper(args.swap_elecs);
    end
    args.swap_elecs = cellstr(args.swap_elecs);
    if length(args.swap_elecs) == 1; args.swap_elecs{2} = 'Unused'; end
    if length(args.swap_elecs)  > 2
        disp('More than 2 arguments in ''swap_elecs'' field.')
        help mfilename
        return
    end
end
if ~isfield(args,'verbose')||isempty(args.verbose),
   args.verbose = 1;
end

%Import
if args.verbose>0,
   disp('The following arguments to be used:');
   args
end

if isfield(args, 'status_chan'), %why this arguement? SJB
    [EEG, com, HDR] = pop_bdfread( ...
        'filename',   args.filename,  ...
        'pathname',   [args.pathname, '/'],  ...
        'statusChan', args.status_chan );
else
    [EEG, com, HDR] = pop_bdfread( ...
        'filename',   args.filename,  ...
        'pathname',   [args.pathname, '/'] );
end

%File specs
   EEG.subject   = EEG.filename(1,1:8);
   EEG.condition = regexprep(EEG.filename, '^\d{5}.\d{2}_(\S+)(_\S+)?\.\S+$', '$1');
   EEG.session   = datestr(datenum([HDR.startDate ' ' HDR.startTime], 'dd.mm.yy HH.MM.SS'));
   
%Begin!
if EEG.pnts > 0
   EEG = eeg_checkset(EEG);
   EEG = eeg_hist(EEG, ['EEG = bdf2eeg(' arg2str(args) ');']);

%Chanlocs
   EEG.urchanlocs = EEG.chanlocs;

%Rename channels if necessary
   idx = find(cellfun('isempty', strfind({EEG.chanlocs.labels}, 'eog'))==0); % find all EOG labels in one pass
   if ~isempty(idx)
       for ch = 1:length(idx)
           EEG.chanlocs(idx(ch)).labels = regexprep(EEG.chanlocs(idx(ch)).labels, '(\S)(\S*)', '${upper($1)}${lower($2)}');
       end
   end
   idx = strmatch('heog_', lower({EEG.chanlocs.labels}));
   if ~isempty(idx)
       for ch = 1:length(idx)
           EEG.chanlocs(idx(ch)).labels = regexprep(EEG.chanlocs(idx(ch)).labels, '(\S+)_(\S+)', '$1$2');
       end
   end

%Remove extra EOG channels if they exist
%  *This block modified from the original by SJB b/c pop_select() now takes (v9?) a 
%   strmatch of EEG.chanlocs.labels over channel indices
   if length(strmatch('Heog', {EEG.chanlocs.labels})) > 2
       kpeegidx     = 1:EEG.nbchan;
       rmeogidx     = strmatch('Heog', {EEG.chanlocs.labels});
       rmeogidx     = rmeogidx(3:end)';
       disp(['Deleting extra EOG channel(s): ' EEG.chanlocs(rmeogidx).labels]);
       kpeegidx     = ~ismember(kpeegidx,rmeogidx);
       EEG.data     = EEG.data(kpeegidx,:,:);
       EEG.chanlocs = EEG.chanlocs(kpeegidx);
       EEG.nbchan   = size(EEG.data,1);
   end
   if length(strmatch('Veog', {EEG.chanlocs.labels})) > 2
       kpeegidx     = 1:EEG.nbchan;
       rmeogidx     = strmatch('Veog', {EEG.chanlocs.labels});
       rmeogidx     = rmeogidx(3:end)';
       disp(['Deleting extra EOG channel(s): ' EEG.chanlocs(rmeogidx).labels]);
       kpeegidx     = ~ismember(kpeegidx,rmeogidx);
       EEG.data     = EEG.data(kpeegidx,:,:);
       EEG.chanlocs = EEG.chanlocs(kpeegidx);
       EEG.nbchan   = size(EEG.data,1);
   end

%Upper-case all scalp-leads
    for chan = 1:strmatch('O2', {EEG.chanlocs.labels})  % kludge
        EEG.chanlocs(chan).labels = upper(EEG.chanlocs(chan).labels);
    end

%Swap unused for bad elec if necessary
   if length(args.swap_elecs) == 2,
      EEG = swap_elecs(EEG, args.swap_elecs);
   end

%Remove unnecessary/extra channels, could probably shift to pop_select() w/ cellstr as input
full_elecs = { 'FP1' 'FPZ' 'FP2' 'AF8' 'AF4' 'AFZ' 'AF3' 'AF7'       ...
               'F7'  'F5'  'F3'  'F1'  'FZ'  'F2'  'F4'  'F6'  'F8'  ...
               'FT8' 'FC6' 'FC4' 'FC2' 'FCZ' 'FC1' 'FC3' 'FC5' 'FT7' ...
               'T7'  'C5'  'C3'  'C1'  'CZ'  'C2'  'C4'  'C6'  'T8'  ...
               'TP8' 'CP6' 'CP4' 'CP2' 'CPZ' 'CP1' 'CP3' 'CP5' 'TP7' ...
               'P7'  'P5'  'P3'  'P1'  'PZ'  'P2'  'P4'  'P6'  'P8'  ...
               'PO8' 'PO4' 'POZ' 'PO3' 'PO7' 'O1'  'OZ'  'O2' };
   chans2keep = find(ismember({EEG.chanlocs.labels},full_elecs));
   select_string = 'pop_select(EEG, ''channel'', [chans2keep ';
    if ~isempty(strmatch('Heog', {EEG.chanlocs.labels})) | ...
       ~isempty(strmatch('Veog', {EEG.chanlocs.labels})) | ...
       ~isempty(strmatch( 'Ref', {EEG.chanlocs.labels})),
        select_string = [select_string 'strmatch(''Heogr'',    {EEG.chanlocs.labels}) ' ...
                                       'strmatch(''Heogl'',    {EEG.chanlocs.labels}) ' ...
                                       'strmatch(''Veog+'',    {EEG.chanlocs.labels}) ' ...
                                       'strmatch(''Veog-'',    {EEG.chanlocs.labels}) ' ...
                                       'strmatch(''Ref1'',     {EEG.chanlocs.labels}) ' ...
                                       'strmatch(''Ref2'',     {EEG.chanlocs.labels}) '];
    end
    if ~isempty(strmatch('Status', {EEG.chanlocs.labels}))
        select_string = [select_string 'strmatch(''Status'',   {EEG.chanlocs.labels})])'];
    else
        select_string = [select_string '])'];
    end
    if ~isempty(select_string), 
        disp('Extra/unnecessary channels detected, deleting...');  
        EEG = eval(select_string); 
    end
   % doubles, remove latter, added SJB 6/5/12
   for ee = 1:length(full_elecs),
       if length(strmatch(full_elecs(ee),{EEG.chanlocs.labels}))>1,
          chan_idc = find(ismember({EEG.chanlocs.labels},full_elecs(ee)));
          chan_idc = chan_idc(2:end);
          disp(['Extra channel(s) [' full_elecs{ee} '] detected, keeping the first...']);
          EEG.data(chan_idc,:,:) = '';
          EEG.chanlocs(chan_idc) = '';
          EEG = eeg_checkset(EEG);
       end
   end

% Electrode Locations 
   elec_locations_file = 'montage10-10_sphrad1_n67.ced';
   if exist(elec_locations_file, 'file'), %through this and pre-steps, we lose connection to "urchanlocs"
      chanlocs        = readlocs(elec_locations_file);
      [junk, oridx]   = ismember({EEG.chanlocs.labels}, {chanlocs.labels});
      chanlocs        = chanlocs(oridx);
      [junk, sorti]   = sort(oridx);
      EEG.chanlocs    = chanlocs(sorti);
      EEG.data        = EEG.data(sorti,:,:);
   end 

%Resample
   if args.resample
       EEG = pop_resample (EEG, args.resample);
   end

%Filter
   if args.lowfreq > 0
        EEG = eeg_hpfilter(EEG, args.lowfreq, args.trans_width, 0);
   end

%Re-reference
    switch args.reference
      case 'ears',
          refchans = strmatch('Ref', {EEG.chanlocs.labels});
          if length(refchans) < 2, disp(['Missing one or both ear electrodes in ' EEG.filename]); end
          if length(refchans) >= 1
              if ~isempty(strmatch('Status', {EEG.chanlocs.labels}))
                  EEG = pop_reref(EEG, refchans, 'method', 'standard', 'exclude', strmatch('Status', {EEG.chanlocs.labels}));
              else
                  EEG = pop_reref(EEG, refchans, 'method', 'standard');
              end
          else
              disp(['Reference channels not found. Rereferencing not done for ' EEG.filename])
          end
          EEG.ref = char(args.reference);
          EEG     = eeg_hist(EEG,['EEG = pop_reref(EEG, ' num2str(refchans') ');']);
      case 'averef',
          EEG     = pop_reref(EEG, [], 'refstate', 'averef'); 
          EEG     = eeg_hist(EEG, 'EEG = pop_reref(EEG,[],''refstate'',''averef'');');
      case 'none',
          %continuing, no display
      otherwise,
          refchans = strmatch(args.reference, {EEG.chanlocs.labels});
          if ~isempty(refchans)
              if ~isempty(strmatch('Status', {EEG.chanlocs.labels}))
                  EEG = pop_reref(EEG, refchans, 'exclude', strmatch('Status', {EEG.chanlocs.labels}));
              else
                  EEG = pop_reref(EEG, refchans);
              end
          EEG.ref = args.reference;
          EEG     = eeg_hist(EEG,['EEG = pop_reref(EEG, ' num2str(refchans') ');']);
          else
              disp(['Reference channels not found. Rereferencing not done for ' EEG.filename])
          end
    end
    if isfield(EEG,  'cmserr'), EEG = rmfield(EEG,  'cmserr'); end
    if isfield(EEG, 'nEvents'), EEG = rmfield(EEG, 'nEvents'); end
    if isfield(EEG,  'status'), EEG = rmfield(EEG,  'status'); end

    if (isfield(EEG,'session') && ~isempty(EEG.session))    && ...
       datenum(EEG.session)>datenum('01-Dec-2008 00:00:00') && ...
       datenum(EEG.session)<datenum('31-May-2009 23:59:59'),
       switch_eogs;
    end
       

end


%-----------------------------------------------------%

function BDF = swap_elecs(BDF, elec_pair);
target_chan = elec_pair{1};
swap_chan   = elec_pair{2};
if isstruct(BDF)
    if isfield(BDF, 'chanlocs')
       if     length([strmatch(swap_chan,{BDF.chanlocs.labels}) strmatch(target_chan,{BDF.chanlocs.labels})])==2,
          temp                                                    = BDF.data(strmatch(target_chan, {BDF.chanlocs.labels}),:);
          BDF.data(strmatch(target_chan,{BDF.chanlocs.labels}),:) = BDF.data(strmatch(swap_chan,   {BDF.chanlocs.labels}),:);
          BDF.data(strmatch(swap_chan,  {BDF.chanlocs.labels}),:) = temp;
          disp([swap_chan ' substituted for ' target_chan]);
       elseif length([strmatch(swap_chan,{BDF.chanlocs.labels}) strmatch(target_chan,{BDF.chanlocs.labels})])==1,
          ori_chan = strmatch(swap_chan,{BDF.chanlocs.labels});
          if isempty(ori_chan),
             ori_chan  = strmatch(target_chan,{BDF.chanlocs.labels});
             new_label =    swap_chan;
          else,
             new_label =  target_chan;
          end
          disp(['Full swap-pair not present, renaming: ' BDF.chanlocs(ori_chan).labels ' as ' new_label]);
          BDF.chanlocs(ori_chan).labels = new_label; 
       elseif ~isempty(strmatch('Status',elec_pair)),
          stat_chan = elec_pair{ strcmp('Status',elec_pair)};
          swap_chan = elec_pair{~strcmp('Status',elec_pair)};
          BDF.status = BDF.data(strmatch(stat_chan,{BDF.chanlocs.labels}),:);
          BDF.data(strmatch(stat_chan,{BDF.chanlocs.labels}),:) = BDF.data(strmatch(swap_chan,{BDF.chanlocs.labels}),:);
          disp([stat_chan ' substituted for ' swap_chan]);
        elseif isempty(strmatch(target_chan, {BDF.chanlocs.labels}))&~isempty(strmatch(swap_chan, {BDF.chanlocs.labels}))
            BDF.chanlocs(strmatch(swap_chan,{BDF.chanlocs.labels})).labels = {target_chan};
        elseif isempty(strmatch(target_chan, {BDF.chanlocs.labels}))
            disp([target_chan ' not found. No substitution made.'])
        elseif isempty(strmatch(swap_chan, {BDF.chanlocs.labels}))
            disp([swap_chan ' not found. No substitution made.'])
        end
    else
        disp(['Unknown error substituting ' swap_chan ' for ' target_chan])
    end
end

%-----------------------------------------------------%

function BDF = swap_unused(BDF, target_chan);

if isstruct(BDF)
    if isfield(BDF, 'chanlocs')
        if isempty(strmatch(target_chan, {BDF.chanlocs.labels}))
            disp([target_chan ' not found'])
        elseif isempty(strmatch('Unused_p', {BDF.chanlocs.labels}))
            disp('Unused_p not found')
        else
            BDF.data(strmatch(target_chan, {BDF.chanlocs.labels}),:) = ...
            BDF.data(strmatch('Unused_p',  {BDF.chanlocs.labels}),:);
            disp(['Unused substituted for ' target_chan])
        end
    else
        disp(['Unknown error substituting for ' target_chan])
    end
end

%-----------------------------------------------------%

function BDF = delete_ref(BDF);

if isstruct(BDF)
    if isfield(BDF, 'chanlocs') && isfield(BDF, 'ref')
        clear channels
        for row = 1:length(BDF.chanlocs)
            if row < BDF.chanlocs(abs(BDF.ref)).datachan
                channels(row).labels     = BDF.chanlocs(row).labels;
                channels(row).type       = BDF.chanlocs(row).type;
                channels(row).datachan   = BDF.chanlocs(row).datachan;
            end
            if row > BDF.chanlocs(abs(BDF.ref)).datachan
                channels(row-1).labels   = BDF.chanlocs(row).labels;
                channels(row-1).type     = BDF.chanlocs(row).type;
                channels(row-1).datachan = BDF.chanlocs(row).datachan;
            end
        end
        BDF = rmfield(BDF, 'chanlocs');
        BDF.chanlocs = channels;
    else
        disp(['chanlocs and/or ref field missing from ' BDF.filename]);
    end
else
    disp(['EEG structure not defined']);
end

