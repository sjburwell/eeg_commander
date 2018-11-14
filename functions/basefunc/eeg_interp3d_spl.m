% EEG = eeg_interp3d_spl(EEG, interpE);
%
% Usage: Spherical-spline interpolation (EEGLAB).  
% Info: Orig. code a modified EEGLAB's eeg_interp() from 
%       FASTER-toolbox h_epoch_interp_spl(). Implemented here to 
%       restore some functionality(?), code-corrections, improvements.
%
% Inputs: 
%     EEG     - EEGLAB dataset
%     interpE - CHANSxTRIALS array where 0 = good data, 1 = bad data
%


% Edit to the EEGLAB interpolation function to interpolate different
% channels within each epoch
%
% Copyright (C) 2010 Hugh Nolan, Robert Whelan and Richard Reilly, Trinity College Dublin,
% Ireland
%
% Based on:
%
% eeg_interp() - interpolate data channels
%
% Usage: EEGOUT = eeg_interp(EEG, badchans, method);
%
% Inputs:
%     EEG      - EEGLAB dataset
%     badchans - [integer array] indices of channels to interpolate.
%                For instance, these channels might be bad.
%                [chanlocs structure] channel location structure containing
%                either locations of channels to interpolate or a full
%                channel structure (missing channels in the current
%                dataset are interpolated).
%     method   - [string] method used for interpolation (default is 'spherical').
%                'invdist' uses inverse distance on the scalp
%                'spherical' uses superfast spherical interpolation.
%                'spacetime' uses griddata3 to interpolate both in space
%                and time (very slow and cannot be interupted).
% Output:
%     EEGOUT   - data set with bad electrode data replaced by
%                interpolated data
%
% Author: Arnaud Delorme, CERCO, CNRS, Mai 2006-

% Copyright (C) Arnaud Delorme, CERCO, 2006, arno@salk.edu
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

% $Log: eeg_interp.m,v $
%
% Revision 1.7  2009/08/05 03:20:42  arno
% new interpolation function
%
% Revision 1.6  2009/07/30 03:32:47  arno
% fixed interpolating bad channels
%
% Revision 1.5  2009/07/02 19:30:33  arno
% fix problem with empty channel
%
% Revision 1.4  2009/07/02 18:23:33  arno
% fixing interpolation
%
% Revision 1.3  2009/04/21 21:48:53  arno
% make default spherical in eeg_interp
%
% Revision 1.2  2008/04/16 17:34:45  arno
% added spherical and 3-D interpolation
%
% Revision 1.1  2006/09/12 18:46:30  arno
% Initial revision
%

%function EEG = h_eeg_interp3d_spl(ORIEEG, bad_elec_epochs, ignore_chans)
function EEG = eeg_interp3d_spl(EEG, interpE, chanlocs);

%keyboard
warning off
if  nargin < 2,
    help sphspl_interp
    return
end

%if exist('chanlocs')&&~isempty(chanlocs),
%   newlocs = [EEG.chanlocs chanlocs];
%else
%   newlocs = EEG.chanlocs;
%end
%
%% prep data matrices 
%ORIDATA = EEG.data;
%if (nargin > 2)&&isstruct(chanlocs)&&(sum(ismember({EEG.chanlocs.labels},{chanlocs.labels}))==0)
%   OUTDATA = zeros(EEG.nbchan+length(chanlocs), EEG.pnts, EEG.trials);
%else
%   OUTDATA = zeros(size(ORIDATA));
%end

for v=1:size(interpE,2),
    if ~isempty(find(interpE(:,v)))
	badchans  = find(interpE(:,v));
	goodchans = setdiff(1:EEG.nbchan, badchans);

        % prep measured input
        % -------------------
        %gooddata = EEG.data( goodchans ,:,v);
	xelec =  [ EEG.chanlocs(goodchans).X ];
	yelec =  [ EEG.chanlocs(goodchans).Y ];
	zelec =  [ EEG.chanlocs(goodchans).Z ];
	rad = sqrt(xelec.^2+yelec.^2+zelec.^2);
	xelec = xelec./rad;
	yelec = yelec./rad;
	zelec = zelec./rad;

        % prep interpolated
        % -----------------
        if exist('chanlocs')&&~isempty(chanlocs),
           xbad = [ EEG.chanlocs(badchans).X chanlocs.X];
           ybad = [ EEG.chanlocs(badchans).Y chanlocs.Y];
           zbad = [ EEG.chanlocs(badchans).Z chanlocs.Z];
        else
	   xbad = [ EEG.chanlocs(badchans).X ];
	   ybad = [ EEG.chanlocs(badchans).Y ];
	   zbad = [ EEG.chanlocs(badchans).Z ];
        end
	rad = sqrt(xbad.^2+ybad.^2+zbad.^2);
	xbad = xbad./rad;
	ybad = ybad./rad;
	zbad = zbad./rad;

        % project interpolated
        % --------------------
	%[tmp1 tmp2 tmp3 badepochdata] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, EEG.data(datachans,:,v));
        %above line replaced for below, aboves assumes bad electrodes removed from dataset, S.J.Burwell, 4/5/2011
        [tmp1 tmp2 tmp3 returndata] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, EEG.data(goodchans,:,v));
        EEG.data(badchans,:,v) = returndata;

        %OUTDATA(:,:,v) = [gooddata; returndata];   
        %if exist('chanlocs')&&~isempty(chanlocs),
        %   [tmp1 idx] = sort([EEG.chanlocs(goodchans).urchan EEG.chanlocs(badchans).urchan chanlocs.urchan]);
        %else
        %   [tmp1 idx] = sort([EEG.chanlocs(goodchans).urchan EEG.chanlocs(badchans).urchan]);
        %end
        %OUTDATA(:,:,v) = OUTDATA(idx,:,v);


   end
end
%EEG.data   = OUTDATA; clear outdata
%EEG.nbchan = size(EEG.data,1);
%[tmp1 idx] = sort([newlocs.urchan]);
%EEG.chanlocs = newlocs(idx);
EEG = eeg_checkset(EEG);

warning on

% get data channels
% -----------------
function datachans = getdatachans(goodchans, badchans);
datachans = goodchans;
badchans  = sort(badchans);
for index = length(badchans):-1:1
	datachans(find(datachans > badchans(index))) = datachans(find(datachans > badchans(index)))-1;
end;

% -----------------
% spherical splines
% -----------------
function [x, y, z, Res] = spheric_spline_old( xelec, yelec, zelec, values);

SPHERERES = 20;
[x,y,z] = sphere(SPHERERES);
x(1:(length(x)-1)/2,:) = []; x = [ x(:)' ];
y(1:(length(y)-1)/2,:) = []; y = [ y(:)' ];
z(1:(length(z)-1)/2,:) = []; z = [ z(:)' ];

Gelec = computeg(xelec,yelec,zelec,xelec,yelec,zelec);
Gsph  = computeg(x,y,z,xelec,yelec,zelec);

% equations are
% Gelec*C + C0  = Potential (C unknow)
% Sum(c_i) = 0
% so
%             [c_1]
%      *      [c_2]
%             [c_ ]
%    xelec    [c_n]
% [x x x x x]         [potential_1]
% [x x x x x]         [potential_ ]
% [x x x x x]       = [potential_ ]
% [x x x x x]         [potential_4]
% [1 1 1 1 1]         [0]

% compute solution for parameters C
% ---------------------------------
meanvalues = mean(values);
values = values - meanvalues; % make mean zero
C = pinv([Gelec;ones(1,length(Gelec))]) * [values(:);0];

% apply results
% -------------
Res = zeros(1,size(Gsph,1));
for j = 1:size(Gsph,1)
	Res(j) = sum(C .* Gsph(j,:)');
end
Res = Res + meanvalues;
Res = reshape(Res, length(x(:)),1);

function [xbad, ybad, zbad, allres] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, values);

newchans = length(xbad);
numpoints = size(values,2);

%SPHERERES = 20;
%[x,y,z] = sphere(SPHERERES);
%x(1:(length(x)-1)/2,:) = []; xbad = [ x(:)'];
%y(1:(length(x)-1)/2,:) = []; ybad = [ y(:)'];
%z(1:(length(x)-1)/2,:) = []; zbad = [ z(:)'];

Gelec = computeg(xelec,yelec,zelec,xelec,yelec,zelec);
Gsph  = computeg(xbad,ybad,zbad,xelec,yelec,zelec);

% compute solution for parameters C
% ---------------------------------
meanvalues = mean(values);
values = values - repmat(meanvalues, [size(values,1) 1]); % make mean zero

values = [values;zeros(1,numpoints)];
C = pinv([Gelec;ones(1,length(Gelec))]) * values;
clear values;
allres = zeros(newchans, numpoints);

% apply results
% -------------
for j = 1:size(Gsph,1)
	allres(j,:) = sum(C .* repmat(Gsph(j,:)', [1 size(C,2)]));
end
allres = allres + repmat(meanvalues, [size(allres,1) 1]);

% compute G function
% ------------------
function g = computeg(x,y,z,xelec,yelec,zelec)

unitmat = ones(length(x(:)),length(xelec));
EI = unitmat - sqrt((repmat(x(:),1,length(xelec)) - repmat(xelec,length(x(:)),1)).^2 +...
	(repmat(y(:),1,length(xelec)) - repmat(yelec,length(x(:)),1)).^2 +...
	(repmat(z(:),1,length(xelec)) - repmat(zelec,length(x(:)),1)).^2);

g = zeros(length(x(:)),length(xelec));
%dsafds
m = 4; % 3 is linear, 4 is best according to Perrin's curve
for n = 1:7
	L = legendre(n,EI);
	g = g + ((2*n+1)/(n^m*(n+1)^m))*squeeze(L(1,:,:));
end
g = g/(4*pi);

