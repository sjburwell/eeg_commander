function EEG = proc_select( EEG , varargin );
% EEG = proc_select( EEG, 'key1', val, 'key2', val, ...);
%
% This is a wrapper function to EEGLAB's pop_select(); it preserves fields created by 
% proc_commander and related proc_* functions, (esp. those in EEG.reject.*).  
% For help, see >> help pop_select.m
%
% *** CURRENTLY ONLY WORKS W/ EPOCHED DATA, AND IGNORES ICA-DIMENSION CHANGES ***
% Scott Burwell, November, 2014

myrejfield = EEG.reject;
if ~isempty(myrejfield),
   rejfields = fieldnames(myrejfield);

   %%%  ---  FOR CHANNELS  ---   %%%
   if ~isempty(keyval('channel',varargin))&~isempty(keyval('nochannel',varargin)),
     help pop_select;
     disp('Both "channel" and "nochannel" used, make up your mind and try again!'); return;                 
   end

   %square-up "channel"
   if ~isempty(keyval('channel',varargin)),
       keepchans = keyval('channel',varargin);
       if iscell(keepchans), keepchans = find(ismember({EEG.chanlocs.labels}, keepchans)); end
   end
   if exist('keepchans'),
      for i = 1:length(strmatch('rej',rejfields)),
         mycmd = ['myrejfield.' rejfields{i}];
         if size(eval(mycmd),1)>1,
            eval(['temprej = ' mycmd ';']); temprej = temprej(keepchans,:); eval([mycmd ' = temprej;']);
         end
      end
   end

   %square-up "nochannel"
   if ~isempty(keyval('nochannel',varargin)),
       dropchans = keyval('nochannel',varargin);
       if iscell(dropchans), dropchans = find(ismember({EEG.chanlocs.labels}, dropchans)); end
   end
   if exist('dropchans'),
      for i = 1:length(strmatch('rej',rejfields)),
         mycmd = ['myrejfield.' rejfields{i}];
         if size(eval(mycmd),1)>1,
            eval(['temprej = ' mycmd ';']); temprej(dropchans,:) = ''; eval([mycmd ' = temprej;']);
         end
      end
   end

   %%%   ---   FOR TRIALS ---   %%%
   if ~isempty(keyval('trial',varargin))&~isempty(keyval('notrial',varargin)),
     help pop_select;
     disp('Both "trial" and "notrial" used, make up your mind and try again!'); return;                 
   end

   if ~isempty(keyval(  'trial',varargin)), keeptrials = keyval(  'trial',varargin); end
   if ~isempty(keyval('notrial',varargin)), droptrials = keyval('notrial',varargin); end

   if exist('keeptrials'),
      for i = 1:length(strmatch('rej',rejfields)),
         mycmd = ['myrejfield.' rejfields{i}];
         if size(eval(mycmd),1)>1,
            eval(['temprej = ' mycmd ';']); temprej = temprej(:,keeptrials); eval([mycmd ' = temprej;']);
         end
      end
   end

   if exist('droptrials'),
      for i = 1:length(strmatch('rej',rejfields)),
         mycmd = ['myrejfield.' rejfields{i}];
         if size(eval(mycmd),1)>1,
            eval(['temprej = ' mycmd ';']); temprej(:,droptrials) = ''; eval([mycmd ' = temprej;']);
         end
      end
   end

   native_rej = {'rejmanual','rejjp','rejkurt','rejthresh','rejconst','rejfreq'};
   for j = 1:length(native_rej), 
       if ~isempty(eval(['myrejfield.' native_rej{j} 'E'])),
          eval(['temprej = double(sum(myrejfield.' native_rej{j} 'E,1)>0);']);
          eval(['myrejfield.' native_rej{j} ' = temprej;']);
       end
   end
       
end
EEG = pop_select(EEG, varargin{:}); 
EEG.reject = myrejfield;

