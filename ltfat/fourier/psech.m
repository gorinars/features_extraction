function [g,tfr]=psech(L,p2,p3,p4)
%PSECH  Sampled, periodized hyperbolic secant
%   Usage: g=psech(L);
%          g=psech(L,tfr);
%          g=psech(L,s,'samples);
%          [g,tfr]=psech( ... );
%
%   Input parameters:
%      L   : Length of vector.
%      tfr : ratio between time and frequency support.
%   Output parameters:
%      g   : The periodized hyperbolic cosine.
%
%   PSECH(L,tfr) computes samples of a periodized hyperbolic secant.
%   The function returns a regular sampling of the periodization
%   of the function sech(pi*x)
%
%   The returned function has norm equal to 1.
%
%   The parameter tfr determines the ratio between the effective support
%   of g and the effective support of the DFT of g. If tfr>1 then g*
%   has a wider support than the DFT of g.
%
%   PSECH(L) does the same setting tfr=1.
%
%   PSECH(L,s,'samples') returns a hyperbolic secant with an effective
%   support of s samples. This means that approx. 96% of the energy or 74%
%   or the area under the graph is contained within s samples. This is
%   equivalent to PSECH(L,s^2/L).
%
%   [g,tfr] = PSECH( ... ) additionally returns the time-to-frequency
%   support ratio. This is useful if you did not specify it (i.e. used
%   the 'samples' input format).
%
%   The function is whole-point even.  This implies that fft(PSECH(L,tfr))
%   is real for any L and tfr.
%
%   If this function is used to generate a window for a Gabor frame, then
%   the window giving the smallest frame bound ratio is generated by
%   PSECH(L,a*M/L).
%
%   Examples:
%   ---------
%
%   This example creates a PSECH function, and demonstrates that it is
%   its own Discrete Fourier Transform:
%
%     g=psech(128);
%
%     % Test of DFT invariance: Should be close to zero.
%     norm(g-dft(g))
% 
%   The next plot shows the PSECH in the time domain compared to the Gaussian:
%
%     plot((1:128)',fftshift(pgauss(128)),...
%          (1:128)',fftshift(psech(128)));
%     legend('pgauss','psech');
% 
%   The next plot shows the PSECH in the frequency domain on a log
%   scale compared to the Gaussian:
%
%     hold all;
%     magresp(pgauss(128),'dynrange',100);
%     magresp(psech(128),'dynrange',100);
%     legend('pgauss','psech');
%     
%   The next plot shows PSECH in the time-frequency plane:
% 
%     sgram(psech(128),'tc','nf','lin');
%
%   See also:  pgauss, pbspline, pherm
%
%   References:
%     A. J. E. M. Janssen and T. Strohmer. Hyperbolic secants yield Gabor
%     frames. Appl. Comput. Harmon. Anal., 12(2):259-267, 2002.
%     
%     
%
%   Url: http://ltfat.sourceforge.net/doc/fourier/psech.php

% Copyright (C) 2005-2013 Peter L. Søndergaard <soender@users.sourceforge.net>.
% This file is part of LTFAT version 1.4.3
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

error(nargchk(1,4,nargin));

if nargin==1
  tfr=1;
end;

if size(L,1)>1 || size(L,2)>1
  error('L must be a scalar');
end;

if rem(L,1)~=0
  error('L must be an integer.')
end;

switch(nargin)
 case 1
  tfr=1;
  cent=0;
 case 2
  tfr=p2;
  cent=0;
 case 3
  if ischar(p3)
    switch(lower(p3))
     case {'s','samples'}
      tfr=p2^2/L;
     otherwise
      error('Unknown argument %s',p3);
    end;
    cent=0;
  else
    tfr=p2;
    cent=p3;
  end;
 case 4
  tfr=p2^2/L;
  cent=p4;
end;

safe=12;

g=zeros(L,1);
sqrtl=sqrt(L);

w=tfr;

% Outside the interval [-safe,safe] then sech(pi*x) is numerically zero.
nk=ceil(safe/sqrt(L/sqrt(w)));

lr=(0:L-1).';
for k=-nk:nk  
  g=g+sech(pi*(lr/sqrtl-k*sqrtl)/sqrt(w));
end;

% Normalize it.
g=g*sqrt(pi/(2*sqrt(L*w)));

