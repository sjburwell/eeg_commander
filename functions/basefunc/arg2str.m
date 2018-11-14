% arg2str() - Convert function argument cell array or structure to
%             EEGLAB compatible history string
%
% Usage:
%   >> str = arg2str(arg);
%
% Inputs:
%   arg       - cell array arguments with parameter value pairs or
%               structure arguments
%
% Outputs:
%   str       - history string
%
% Author: Andreas Widmann, University of Leipzig, 2006

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2006 Andreas Widmann, University of Leipzig, widmann@uni-leipzig.de
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Id: arg2str.m 8 2006-04-03 09:05:23Z widmann $

function str = arg2str(arg)

if isstruct(arg)
    str = '';
    fieldArray = fieldnames(arg);
    arg = struct2cell(arg);
    for iArg = 1:length(arg)
        if ischar(arg{iArg})
            str = [str '''' fieldArray{iArg} ''', ''' arg{iArg} ''''];
        elseif isnumeric(arg{iArg}) || islogical(arg{iArg})
            str = [str '''' fieldArray{iArg} ''', ' mat2str(arg{iArg})];
        elseif iscell(arg{iArg})
            str = [str '''' fieldArray{iArg} ''', ' arg2str(arg{iArg})];
        end
        if iArg < length(arg)
            str = [str ', '];
        end
    end
elseif iscell(arg)
    str = '{';
    for iArg = 1:length(arg)
        if ischar(arg{iArg})
            str = [str '''' arg{iArg} ''''];
        elseif isnumeric(arg{iArg}) || islogical(arg{iArg})
            str = [str mat2str(arg{iArg})];
        elseif iscell(arg{iArg})
            str = [str arg2str(arg{iArg})];
        end
        if iArg < length(arg)
            str = [str ' '];
        else
            str = [str '}'];
        end
    end
end
