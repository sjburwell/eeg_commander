function [retval] = struct2ascii(struct_var,output_file);

% [retval] = struct2ascii(struct_var,output_file);
% Exports a structured variable as tab-delimited text-file
%
% INPUTS: 
%	struct_var	- 1xN structured variable where N represents
%			  cases (rows).  Subfields of structured variable
%			  will be output as columns.   
%
%	output_file	- [char] array defining output ASCII file 
%
% OUTPUTS:
%	[retval]	- tab-delimited text file
%
% SJBURWELL, May, 2010

if ~isstruct(struct_var) | ~ischar(output_file)
   help mfilename
   return
end

VarN = fieldnames(struct_var)';
nVar = length(VarN);
nCas = length(struct_var);

fid = fopen(output_file,'wt');
  fprintf(fid,'%s\t',VarN{1,1:end-1});
  fprintf(fid,'%s\n',VarN{1,end});
    for c=1:nCas

        for v = 1:(nVar-1)
            cur_val   = eval(['struct_var(' num2str(c) ').' char(VarN(v))]);
            if ischar(cur_val) | iscell(cur_val) | isempty(cur_val)
               fprintf(fid, '%s\t', char(cur_val));
            elseif isnumeric(cur_val) | islogical(cur_val)
               fprintf(fid, '%s\t', num2str(cur_val));
            end
        end

        cur_val   = eval(['struct_var(' num2str(c) ').' char(VarN(nVar))]);
        if ischar(cur_val) | iscell(cur_val) | isempty(cur_val)
           fprintf(fid, '%s\n', char(cur_val));
        elseif isnumeric(cur_val)
           fprintf(fid, '%s\n', num2str(cur_val));
        end

   end

fclose(fid);



