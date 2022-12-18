function Pressure=fnm_call(xdcr,cg,medium,ndiv,f0,dflag,nthreads)
% Description
%   This function is the gateway between the Matlab and C++ binary. It does minimal error checking to ensure enough arguments are being passed.
% Usage
%   pressure = fnm_call(transducer, cg, medium, ndiv, f0, dflag);  
% Arguments
%   transducer: A FOCUS transducer array.
%   cg: A FOCUS coordinate grid.
%   medium: A FOCUS medium.
%   ndiv: The number of integral points to use.
%   f0: Frequency of the array in Hz.
%   dflag: Display flag, 1 = display, 0 = suppress.
% Output Parameters
%   pressure: A 3-d array representing the complex pressure at each point
% Notes
%   This function prompts for action if the number of calculation points is over 20,796,875. This limit is based on the fact that most systems cannot process an array with more than 275x275x275 elements. Users may override this by editing fnm_call.m.
if nargin()< 5 || nargin() > 7
    Pressure=[];
	error('fnm_call requires between 5 and 7 arguments')
end
if nargin < 6
    dflag = 0;
end
if nargin < 7
    nthreads = 8;
elseif nthreads < 1
    nthreads = 8;
end

if isstruct(xdcr)==0
    Pressure=[];
	error('xdcr needs to be a struct, please create it')
end
if isstruct(cg)==0
    Pressure=[];
	error('cg needs to be a struct, please use set_coordinate_grid to create it')
end
if isstruct(medium)==0
    Pressure=[];
	error('medium needs to be a struct, please use define_media to create several commonly used media')
end
if isnumeric(ndiv)==0 || ndiv<1
    Pressure=[];
	error('ndiv must be greater then or equal to 1')
end
if isnumeric(f0)==0 || f0<0
    Pressure=[];
	error('f0 must be greater then or equal to 0')
end

if dflag >=1 
    dflag=1;
else
    dflag=0;
end

if cg.regular_grid == 1,
    nx=(cg.xmax-cg.xmin)/cg.delta(1)+1;
    ny=(cg.ymax-cg.ymin)/cg.delta(2)+1;
    nz=(cg.zmax-cg.zmin)/cg.delta(3)+1;
    nobs=nx*ny*nz;
    if nobs>20796875
		sprintf('WARNING: nx= %i, my=%i, nz=%i, total elements=%i',nx,ny,nz,nobs)
        warning('Final answer may exceed the capabilities of a 32-bit system')
		
        %cont=input('Continue? y/n');
        %if cont=='n' || cont=='N'||cont='no' ||cont==[]
       %     Pressure=[];
       %     error('Aborted by user')
       % end
    end
end
Pressure=fnm_cw(xdcr,cg,medium,ndiv,f0,dflag,nthreads);

	