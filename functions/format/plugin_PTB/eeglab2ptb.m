% eeglab2ptb() - Converts epoched EEGLAB variable to Psychophysiology Toolbox 
%                (E. Bernat; FSU) erp variable.  
%
% Usage:
%   >> erp = eeglab2ptb( INEEG, varargin)
%
% Inputs: 
%   INEEG      - input EEG data structure
%  
% Optional inputs ('key','val'):
%   'rttype'   - Nx1 element character array denoting event type(s) of variable 
%                trigger response times following any event
%   'rtlimit'  - numeric value (in msec) to search for "rttype" following any
%                given stimulus 
%   'icaact'   - output independent component activations, rather than scalp data
%   'icaproj'  - 'maxabs' (for maximum absolute-valued ICA inverse-weight) or string of
%                desired channel (e.g., 'CZ'), latter must match value in {EEG.chanlocs.label}. 
%                Otherwise, 'maprms' which is equivalent (I believe) to "RMS uV", see:
%                https://sccn.ucsd.edu/pipermail/eeglablist/2015/010041.html
%   'savefile' - character array denoting output file to save (if desired) 
%
% Outputs:
%   erp        - output erp data structure
%   savefile   - only if asked for, matfile saved to disk 
%
% Scott Burwell, Ed Bernat, Spring 2011
%
function erp = eeglab2ptb(EEG, varargin)

if nargin>1,
   args = struct(varargin{:});  
else,
   args = struct('rttype',[],'rtlimit',[],'icaact',[],'savefile',[]);
end

if ~isfield(args,'rttype'),
   args.rttype = [];
end
if ~isfield(args,'rtlimit'),
   args.rtlimit = [];
end
if ~isfield(args,'rtlook'),
   args.rtlook = 'none';
end
if ~isfield(args,'icaact')  || isempty(EEG.icawinv),
   args.icaact  = [];
end
if ~isfield(args,'icaproj') || isempty(EEG.icawinv),
   args.icaproj = [];
end
if ~isfield(args,'savefile'),
   args.savefile = [];
end

% init vars
if ~isempty(args.icaact) && args.icaact>0,
   nelec = size(EEG.icawinv,2);
   nbins = EEG.pnts  ;
   nswps = EEG.trials;
else,
   nelec = EEG.nbchan;
   nbins = EEG.pnts  ;
   nswps = EEG.trials;
end

% erp variable
[jnk1 jnk2 ext] = fileparts(EEG.filename);
erp.original_format =       ext;
if ~isempty(args.icaact) && args.icaact>0,
    %erp.scaled2uV       =        0 ;
    %erp.unit            =      'SD';
    erp.scaled2uV       =        1 ; %the above don't work with combine_files
    erp.unit            =      'uV';
else,
    erp.scaled2uV       =        1 ;
    erp.unit            =      'uV';
end
erp.samplerate      = EEG.srate;
if ~isempty(EEG.times), erp.tbin = find(EEG.times==0); end
if ~isempty(args.icaact) && args.icaact>0,
   elecnames = [];
   for ee=1:nelec,
       elecnames = [elecnames cellstr(['IC',num2str(ee)])];
   end
   erp.elecnames = char(elecnames);
else,
   if ~isempty(EEG.chanlocs),
      erp.elecnames   = char(EEG.chanlocs.labels);
      erp.eleclocs    = EEG.chanlocs';
   end
end
erp.elec            = repmat([1:nelec]', nswps, 1);
erp.data            = zeros(length(erp.elec),nbins);
if length(size(EEG.data))==3,
   erp.sweep       = ones(      size(erp.elec));
   erp.ttype       = zeros(     size(erp.elec));
   erp.correct     = ones(      size(erp.elec));
   erp.accept      = ones(      size(erp.elec));
   erp.rt          = repmat(-99,size(erp.elec)); 
   erp.response    = zeros(     size(erp.elec)); 
else
   erp.events      = ones(size(erp.elec(1,:))) * -1;
end

if nswps>1, 

   % sweeps
   for ss = 0:nswps-1,
       erp.sweep( (ss*nelec)+1 : (ss+1)*nelec ) = ss+1;
   end

   % data
   if ~isempty(args.icaact) && args.icaact>0, 
      EEG.data = EEG.data-repmat(mean(EEG.data,2),[1 nbins 1]);
      for ss = 1:nswps,
          erp.data(erp.sweep==ss,:) = (EEG.icaweights * EEG.icasphere) * squeeze(EEG.data(EEG.icachansind,:,ss)); 
          if ~isempty(args.icaproj),
             if     strcmp('maxabs',args.icaproj),
               [junk, proji] = max(abs(EEG.icawinv));                  %find max(abs)
               erp.data(erp.sweep==ss,:) = erp.data(erp.sweep==ss,:)./repmat(diag(EEG.icawinv(proji,:)),[1,size(erp.data,2)]);
             elseif ~isempty(strmatch(args.icaproj,{EEG.chanlocs.labels})),
               proji   = strmatch(args.icaproj,{EEG.chanlocs.labels}); %find a specific channel
               erp.data(erp.sweep==ss,:) = erp.data(erp.sweep==ss,:)./repmat(EEG.icawinv(proji,:),[1,size(erp.data,2)]);
             else,
               disp('   eeglab2ptb; invalid arguement for "icaproj", defaulting to "maprms"');               
               erp.data(erp.sweep==ss,:) = erp.data(erp.sweep==ss,:)./repmat(rms(EEG.icawinv,1)',[1 size(erp.data,2)]);
             end
          else,
             erp.data(erp.sweep==ss,:) = erp.data(erp.sweep==ss,:)./repmat(rms(EEG.icawinv,1)',[1 size(erp.data,2)]); %RMS microvolt: I think equivalent to "mapnorm" in spectopo.m
          end
      end
   else,
      for ss = 1:nswps,
          erp.data(erp.sweep==ss,:) = squeeze(EEG.data(:,:,ss));
      end
   end

   % ttype
   if ~isempty(EEG.epoch) && (length(EEG.epoch)==nswps),
  
           ttype = zeros(nswps,1);
        ttypekey = [];
      zerolatevt = find(cell2mat([EEG.epoch.eventlatency])==0);
      ttype2code = [  EEG.epoch.eventtype ]; ttype2code = ttype2code(zerolatevt);
      epoch2code = [    EEG.event.epoch   ]; epoch2code = epoch2code(zerolatevt);
      urevt2code = [EEG.epoch.eventurevent]; urevt2code = urevt2code(zerolatevt);
    
      for ee  = unique(cell2mat(urevt2code)),

          if isempty(urevt2code),
              disp('   eeglab2ptb; Warning, number of epochs & events mismatch. Check output.');
              break
          end              
              
          idx = find(cell2mat(urevt2code)==ee&epoch2code~=0,1,'first');
          swp = epoch2code(idx); 
          key = strmatch(ttype2code(idx), ttypekey,'exact');  
          if isempty(key), 
             ttypekey = [ttypekey, ttype2code(idx)]; 
             key = strmatch(ttype2code(idx), ttypekey,'exact');
          end
          ttype(swp) = key;

          ablate_idx = find(epoch2code==swp);
          ttype2code(ablate_idx) = '';
          epoch2code(ablate_idx) = '';
          urevt2code(ablate_idx) = '';
      end 
      
      % sort
      erp.stimkeys.ttype = sort(ttypekey);
           
        % test for all-numeric
        NUMS = []; 
        for nn = 1:length(erp.stimkeys.ttype), 
            NUMS = [NUMS, str2num(erp.stimkeys.ttype{nn})];
        end
        if ~isempty(NUMS) && length(NUMS)==length(erp.stimkeys.ttype),
            numbers = 1;
        else
            numbers = 0;
        end
     
      % assign ttypes
      for swp = 1:nswps,
          idx = strmatch(ttypekey{ttype(swp)},erp.stimkeys.ttype,'exact');
          if numbers==1,
             key = str2num(erp.stimkeys.ttype{idx});
          else
             key = idx;
          end
          erp.ttype(erp.sweep==swp) = key;
      end
   end

   if isempty(args.rtlimit);       args.rtlimit = floor(1000/erp.samplerate*(size(erp.data,2)-erp.tbin)); end
   if ~isempty(args.rttype),
      try args.rttype = num2str(args.rttype); end % added 7/30/2013 to take numerical rttype
      switch args.rtlook
      case 'back',
      erp.rt = erp.rt * -1;
       for swp = 1:nswps,
         %if ~isempty(find(cell2mat(EEG.epoch(swp).eventlatency)<0&ismember(EEG.epoch(swp).eventtype,cellstr(args.rttype)))),
            %rt_idx = find(cell2mat(EEG.epoch(swp).eventlatency)<0&ismember(EEG.epoch(swp).eventtype,cellstr(args.rttype)),1,'last');
          if ~isempty(find(cell2mat(EEG.epoch(swp).eventlatency)<0&ismember(EEG.epoch(swp).eventtype,strtrim(cellstr(args.rttype))))),         % edited by JH on 03.22.17
             rt_idx = find(cell2mat(EEG.epoch(swp).eventlatency)<0&ismember(EEG.epoch(swp).eventtype,strtrim(cellstr(args.rttype))),1,'last'); % edited by JH on 03.22.17
             if cell2mat(EEG.epoch(swp).eventlatency(rt_idx))>args.rtlimit,
                erp.rt(erp.sweep==swp) = cell2mat(EEG.epoch(swp).eventlatency(rt_idx));
             else,
                erp.rt(erp.sweep==swp) = 99;
             end
          end
       end
      case 'fwd'
        for swp = 1:nswps,
         %if ~isempty(find(cell2mat(EEG.epoch(swp).eventlatency)>0&ismember(EEG.epoch(swp).eventtype,cellstr(args.rttype)))),
            %rt_idx = find(cell2mat(EEG.epoch(swp).eventlatency)>0&ismember(EEG.epoch(swp).eventtype,cellstr(args.rttype)),1,'first');
          if ~isempty(find(cell2mat(EEG.epoch(swp).eventlatency)>0&ismember(EEG.epoch(swp).eventtype,strtrim(cellstr(args.rttype))))),          % edited by JH on 03.22.17
             rt_idx = find(cell2mat(EEG.epoch(swp).eventlatency)>0&ismember(EEG.epoch(swp).eventtype,strtrim(cellstr(args.rttype))),1,'first'); % edited by JH on 03.22.17
             if cell2mat(EEG.epoch(swp).eventlatency(rt_idx))<args.rtlimit,
                erp.rt(erp.sweep==swp) = cell2mat(EEG.epoch(swp).eventlatency(rt_idx));
             else,
                erp.rt(erp.sweep==swp) = -99;
             end
          end
      end
      otherwise,
        for swp = 1:nswps,
         %if ~isempty(find(cell2mat(EEG.epoch(swp).eventlatency)>0&ismember(EEG.epoch(swp).eventtype,cellstr(args.rttype)))),
            %rt_idx = find(cell2mat(EEG.epoch(swp).eventlatency)>0&ismember(EEG.epoch(swp).eventtype,cellstr(args.rttype)),1,'first');
          if ~isempty(find(cell2mat(EEG.epoch(swp).eventlatency)>0&ismember(EEG.epoch(swp).eventtype,strtrim(cellstr(args.rttype))))),           % edited by JH on 03.22.17
             rt_idx = find(cell2mat(EEG.epoch(swp).eventlatency)>0&ismember(EEG.epoch(swp).eventtype,strtrim(cellstr(args.rttype))),1,'first'); % edited by JH on 03.22.17
             if cell2mat(EEG.epoch(swp).eventlatency(rt_idx))<args.rtlimit,
                erp.rt(erp.sweep==swp) = cell2mat(EEG.epoch(swp).eventlatency(rt_idx));
             else,
                erp.rt(erp.sweep==swp) = -99;
             end
          end
      end
      end

   end

else,
    
    % this part from eeglab2erp, not sure what the correct event-conversion is
    eventtypes_EEG=unique(char(EEG.event.type),'rows');
    eventtypes_cnt=[];
    eventtype_count = 0;
    events = EEG.event.latency;
    for jj = 1:length(events),
      cur_eventtype = EEG.event(jj).type;

      if isempty(strmatch(cur_eventtype,eventtypes_cnt,'exact')),
        eventtypes_cnt = [eventtypes_cnt cur_eventtype];
        eventtype_count = eventtype_count+1;
      end

      erp.events(round(EEG.event(jj).latency)) = strmatch(cur_eventtype,eventtypes_cnt,'exact');

    end
 
end

if exist('outfilename')&&~isempty(outfilename);
   save(outfilename, 'erp');
end

