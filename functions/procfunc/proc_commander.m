% proc_commander() - process EEG data via the use of other proc_* functions called in 
%                    a structured variable specifying parameters
%
% Usage:
%   >> EEG = proc_commander(process, config);
%
% Inputs: 
%   process   - structured variable with the fields:
%               Required fields:
%               process  [.loaddir]: options:
%                                    - character string path to data location
%                                    - 'EEG', must have process.opts.EEG (below)
%
%               Optional fields:
%               process  [.name]   : processing run-identifier
%                        [.loadflt]: options:
%                                    - filter string, see >> help dir
%                                    - text file, list of complete file names
%                                    - [] (empty; default), prompts list dialog box
%                        [.loadpop]: prompt list dialog box with directory contents
%                                    0 = no (default), 1 = yes 
%                        [.savedir]: save-directory
%                        [.savesfx]: append suffix to file
%                        [.savemat]: convert from EEG to erp (PTB format) before saving (uses eeglab2ptb.m)
%                                    0 = no (default), 1 = yes
%                        [.savecfg]: save the "process" and "config" variables as matfile
%                        [.logfile]: string, specifying log-file to be written
%                        [.abortif]: string or script, returning logical scalar on whether or not to 
%                                    abort process given EEG attributes (e.g., EEG.nbchan<=2)
%                        [.opts]
%                             [.bdf2eeg]: inputs to fn bdf2eeg() cell-string
%                             [.EEG]    : input EEG data structure
% 
%   config    - structured variable or configuration-script
%               
%               If 1xN structured variable indicating N-wise routine for processing:
%               Optional fields:
%               config   [.preproc]  : pre-processing        ; see proc_preproc for input 
%                        [.artifact] : artifact tagging      ; see proc_artifact for input
%                        [.epoch]    : process epoching      ; see proc_epoch for input  
%                        [.ica]      : ica decomposition     ; see proc_ica for input 
%                        [.subcomp]  : ica component removal ; see proc_subcomp for input
%                        [.interp]   : interpolation         ; see proc_interp for input
%                        [.csd]      : current source density; see proc_csd for input 
%                        [.save.dir] : EEG structure save point (uses pop_saveset)
%                        [.save.sfx] : append suffix to saved dataset
%                        [.userinput]: executable command/script from Matlab prompt
%
% Outputs:
%   EEG       - processed EEG data structure
%
% Scott Burwell, June 2011
%
% See also: proc_*function*
function EEG = proc_commander(process, config)

if nargin<2, 
   %disp('Insufficient number of arguments to proc_commander.'); 
   %return
   P = process;
   C(1).userinput = '   disp(''proc_commander(); no configuration script defined, proceeding without one...'');';
else,
   P = process; clear process
   C = config ;
end

% directory
if ~isfield(P,'loaddir') || isempty(P.loaddir) 
    disp('Required field "P.loaddir" not assigned');
    return
elseif isempty(dir(P.loaddir)) && strcmp('EEG',P.loaddir)==0,
    disp('Required field "P.loaddir" directory empty/invalid');
    return
end

% prep pop-up
if ~isfield(P,'loadpop') || isempty(P.loadflt),
   DOPOP = 0;
else,
   DOPOP = P.loadpop;
end

% save vars
if ~isfield(P,'savecfg') || isempty(P.savecfg),
   SAVECFG = 0;
else,
   SAVECFG = P.savecfg;
end

% files
if strcmp('EEG',P.loaddir) && isstruct(P.opts),
   PDIR = [];
   SEL  =  1;
elseif ~isfield(P,'loadflt') || isempty(P.loadflt),
   PDIR = dir([P.loaddir  '/*.*']);
   [SEL, OK] = listdlg('ListString', {PDIR.name}, 'Name', 'Directory Contents', ...
               'PromptString', 'Select file(s); Shft/Ctrl for mutliple selections');
   if OK<1, disp('Operation cancelled.'); EEG = []; return; end
elseif length(dir([P.loaddir '/' P.loadflt]))<=1,
   try,
     PDIR = dir([P.loaddir  '/*.*']);
     SEL  = find(ismember({PDIR.name}, textread(P.loadflt, '%s')));
     if DOPOP>0, [NSEL, OK] = listdlg('ListString', {PDIR(SEL).name}, 'Name', 'Directory Contents', ...
                 'PromptString', 'Select file(s); Shft/Ctrl for mutliple selections'); 
        SEL = SEL(NSEL);
     end
   catch,
     PDIR = dir([P.loaddir  '/*.*']);
     SEL  = find(ismember({PDIR.name}, P.loadflt));
     if DOPOP>0, [NSEL, OK] = listdlg('ListString', {PDIR(SEL).name}, 'Name', 'Directory Contents', ...
                 'PromptString', 'Select file(s); Shft/Ctrl for mutliple selections');
        SEL = SEL(NSEL);
     end
   end
else,
   PDIR = dir([P.loaddir '/' P.loadflt]);
   SEL  = 1:length(PDIR);
   if DOPOP>0, [NSEL, OK] = listdlg('ListString', {PDIR(SEL).name}, 'Name', 'Directory Contents', ...
               'PromptString', 'Select file(s); Shft/Ctrl for mutliple selections'); 
      SEL = SEL(NSEL);
   end
end

% proc-name
if ~isfield(P,'name') || isempty(P.name),
   P.name = ['proc_commander_' datestr(now, 'yyyy-mmm-dd-HH:MM:SS')];
else, 
   P.name = [ P.name       '_' datestr(now, 'yyyy-mmm-dd-HH:MM:SS')];   
end

% logfile
if ~isfield(P,'logfile') || isempty(P.logfile) || P.logfile==0,
   P.logfile = 0 ;
else,
   P.logfile = [P.name '.log'];
   if ~isfield(P,'savedir') || isempty(P.savedir), P.savedir = './'; end
   diary(fullfile(P.savedir,P.logfile));
end

% configuration file
if ischar(C) && exist(C,'file')==2,
   disp(['Loading configuration file: ' C]);
   clear config
   eval(C); clear C
   C = config; clear config
elseif ~isstruct(C),
   disp('Invalid configuration file/variable type.')
   return
end

% abort if
if isfield(P,'abortif')&&(~isempty(P.abortif)&&ischar(P.abortif)),
   ABORTIF = P.abortif;
else,
   ABORTIF = [];
end

% if save from top, add to config protocol
if isfield(P,'savedir')&&~isempty(P.savedir)&&exist(P.savedir,'dir'),
   saveidx = length(C)+1;
   C(saveidx).save.dir = P.savedir;
   if isfield(P,'savemat'),
      C(saveidx).save.mat = P.savemat;
   else,
      C(saveidx).save.mat = 0 ;
   end
   if isfield(P,'savesfx'),
      C(saveidx).save.sfx = P.savesfx;
   else,
      C(saveidx).save.sfx = '';
   end 
   clear saveidx
   if SAVECFG>0,
      pvars_fname = fullfile(P.savedir, ['procvars_' P.name '.mat']);
      process = P; config = C;
      disp('proc_commander; saving process variables to destination directory ... ');
      disp(['  process variables: ' pvars_fname]);
      save(pvars_fname, 'process','config');
      clear pvars_fname process config
   end
end

% GO! 
disp(['proc_commander; ' P.name]);
for F = SEL,
    if ~(strcmp('EEG',P.loaddir) && isstruct(P.opts)),
       [pth, nm, ext] = fileparts([P.loaddir  PDIR(F).name]);
       disp(['Current file: ' fullfile(pth, [nm ext])]);
    else,
       disp(['Current file: ' P.opts.EEG.filename ' (EEG)']);
       ext = 'EEG';
    end

    switch ext, 

       case '.bdf',
           if isfield(P,'opts') && isfield(P.opts, 'bdf2eeg') && iscell(P.opts.bdf2eeg), 
               bdf2eeg_input = P.opts.bdf2eeg;
               
               % handle if swap_elecs is a file w/ "ID electrode" format
               swpargidx = strmatch('swap_elecs',cellstr(char(bdf2eeg_input{:})));
               if ~isempty(swpargidx)&&exist(bdf2eeg_input{swpargidx+1},'file'),
                  swapfile = bdf2eeg_input{swpargidx+1};
                  [swp_id, swp_elec] = textread(swapfile, '%s%s', 'delimiter', ' '); %space-delimited file
                  swp_idx = strmatch(nm(1:8), swp_id);
                  if ~isempty(swp_idx),
                      bdf2eeg_input( swpargidx+1 ) = swp_elec(swp_idx);
                  else,
                      bdf2eeg_input( swpargidx+1 ) = {''};
                  end
               end
               if ~isempty(bdf2eeg_input),
                   [EEG, HDR] = bdf2eeg('pathname', pth, 'filename', [nm, ext], bdf2eeg_input{:});
               else,
                   [EEG, HDR] = bdf2eeg('pathname', pth, 'filename', [nm, ext]);
               end
           else,
               disp('No arguments for bdf2eeg provided, using defaults...');
               [EEG, HDR] = bdf2eeg('pathname', pth, 'filename', [nm, ext]);
           end
        
       case '.set',
           EEG = pop_loadset('filepath', pth, 'filename', [nm, ext]);
       
       case '.cdt',
           EEG = loadcurry(fullfile(pth,[nm,ext]), 'CurryLocations', 'False'); %added 2/1/18 by SJB
           for I = 1:length({EEG.event.type}),
             if isnumeric(EEG.event(I).type), 
                EEG.event(I).type   = num2str(EEG.event(I).type); EEG.urevent(I).type = num2str(EEG.urevent(I).type);
             end
             if isa(EEG.event(I).latency,'double')==0,
                EEG.event(I).latency= double(EEG.event(I).latency); EEG.urevent(I).latency= double(EEG.urevent(I).latency);
             end
           end

       case 'EEG',
           EEG = P.opts.EEG;
    end

    if isfield(P,'opts') && isstruct(P.opts) && isfield(P.opts,'resample'); %SJB: 2018-11-13
       EEG = pop_resample(EEG,P.opts.resample);
    end

    if isfield(P,'opts') && isstruct(P.opts) && isfield(P.opts,'highpass'); %SJB: 2018-11-13
       EEG = eeg_hpfilter(EEG,P.opts.hpfilter);
    end

    fields  = fieldnames(C); 
    program = cell(1,length(C));
    for fld = 1:length(fields), 
        program(find(~cellfun('isempty',eval(['{C.' fields{fld} '}'])))) = fields(fld);
    end

    %if ~isempty(EEG.event), %swapped for the below to handle resting EEG files, 7/26/13 (SJB)
    if EEG.pnts>=(10*EEG.srate)||EEG.trials>1, %should put EEG.event condition in ABORTIF script...
       for I = 1:length(program),

        if isempty(ABORTIF) || abortif_eval(EEG,ABORTIF)==0,
      
           switch program{I},
             
             case 'userinput',
               disp(['[' num2str(I) '] userinput    ; ' C(I).userinput     ]);
               EEG = eeg_hist(EEG,  eval([ 'C(I).' program{I}]));
               eval( eval([ 'C(I).' program{I}]) );
             
             case 'preproc',
               disp(['[' num2str(I) '] proc_preproc ; ' ]);
               EEG = proc_preproc(EEG, C(I).preproc);

             case 'artifact',
               disp(['[' num2str(I) '] proc_artifact; ' C(I).artifact.type ]);
               EEG = proc_artifact(EEG, C(I).artifact);
 
             case 'ica',
               disp(['[' num2str(I) '] proc_ica     ; ' C(I).ica.type ]);
               EEG = proc_ica(EEG, C(I).ica);

             case 'subcomp',
               disp(['[' num2str(I) '] proc_subcomp ; ' ]); 
               EEG = proc_subcomp(EEG, C(I).subcomp);

             case 'epoch',
               disp(['[' num2str(I) '] proc_epoch   ; function-determinant' ]); %edit!
               EEG = proc_epoch(EEG, C(I).epoch);

             case 'interp',
               disp(['[' num2str(I) '] proc_interp  ; ' C(I).interp.type ]);
               EEG = proc_interp(EEG, C(I).interp);

             case 'csd',
               disp(['[' num2str(I) '] proc_csd     ; CSD Toolbox' ]);
               EEG = proc_csd(EEG, C(I).csd);

             case 'save',
               if C(I).save.mat==1,
                  erp = eeglab2ptb(EEG);
                  try, erp = create_sub_struct(EEG.subject,erp); end %added 8/6/13, to try and put MTFS codes into stim-field (SJB)
                  disp(['Save name: ' C(I).save.dir nm C(I).save.sfx '.mat']);
                  save([C(I).save.dir nm C(I).save.sfx '.mat'],'erp'); clear erp
               else,
                  disp(['Save name: ' C(I).save.dir nm C(I).save.sfx '.set']);
                  EEG = pop_saveset(EEG, 'filename', [nm C(I).save.sfx], ...
                                         'filepath',     C(I).save.dir , ...
                                         'savemode',     'onefile'      );
               end


           end
        else,
          disp(['[' num2str(I) '] proc_commander; ' EEG.filename ' satisfies exclusion criteria (process.abortif==1), aborting current process...' ]); 
          break 
        end
    end
  else,

    %disp(['[*] proc_commander; ' EEG.filename ' EEG.event is empty, aborting current process...']);
    disp(['[*] proc_commander; ' EEG.filename ' has insufficient time-points (<10s), aborting current process [nBlocks = ' num2str(HDR.nBlocks) ']' ]); %
   
  end
end

if ischar(P.logfile), diary off; end

%-- exit processing if the product of this function is logical(1)
function [abort_proc_commander] = abortif_eval(EEG,instring);
  eval(instring);
  abort_proc_commander = ans;

