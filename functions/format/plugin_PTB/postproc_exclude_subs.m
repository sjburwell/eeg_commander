function erp = postproc_exclude_subs(erp, exclude_file);
% erp = postproc_exclude_subs(erp, exclude_file);
% 
% INPUTS:
%	erp 		- PTB formatted 'erp' variable
%	exclude_file	- text-file containing ONLY (need to fix this
%			  so extra info can be included) IDs to
%			  to be excluded from analyses.
%

exclude_subs.id	 =  textread(exclude_file,'%s%*[^\n]');
erp.accept = ones(size(erp.elec));
disp('Excluding ID(s): ')
for xx = 1:length(exclude_subs.id)
    if ~isempty(strmatch(exclude_subs.id(xx),erp.subs.name))
       erp.accept(erp.subnum==(strmatch(exclude_subs.id(xx),erp.subs.name))) = 0;
       disp(['        ' char(exclude_subs.id(xx))])
    else
       disp(['        ' char(exclude_subs.id(xx)) ' (already not present in erp variable)'])
    end
end
erp = reduce_erp(erp,'erp.accept==1');


