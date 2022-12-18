function pressure=fnm_run(varargin)
% Description: This function is a guided function that does error checking and sanity checks on the input before feeding the information to the C++ binary to get the answer.
% Usage
%   pressure = fnm_run('transducer', transducer, 'cg', cg, 'medium', medium, 'f0', f0, 'tol', tol, 'ndiv', ndiv, 'dflag', dflag);  
% Arguments
%   transducer: A FOCUS transducer array.
%   cg: A FOCUS coordinate grid. NOTE: If the provided delta is more than half the wavelength, this function will reset it to that value.
%   medium: A FOCUS medium.
%   tol: Maximum difference between one ndiv value and the next. Default is 10 - 10.
%   ndiv: The number of integral points to use. Default value is calculated based on the provided tolerance.
%   f0: The frequency of the array in Hz. Default value is 1 MHz.
%   dflag: Display flag, 1 = display, 0 = suppress.
% Output Parameters
%   pressure: A 3-d array representing the complex pressure at each point
% Notes
%   All arguments to this function must be preceeded by their name (e.g. 'f0', f0, 'medium', medium). The arguments can be in any order and they are all optional, however any critical arguments not passed to the function will cause the program to prompt the user to input them.

%allocate/set flags on all our variables
xdcr=-inf;
cg=-inf;
tol=-inf;
ndiv=-inf;
f0=-inf;
medium=-inf;
dflag=1;

if nargin()==0;
    disp('Proper use of this function is:')
	help fnm_run
    Pressure=[];
	return;
end
% number of argument checking
if nargin()/2~=floor(nargin()/2)
	disp('Must have an even number of arguments')
	pressure=[];
	return;
end

% argument phrasing
argc=1;
while argc<nargin()
	switch lower(varargin{argc})
        case 'dflag'
            dflag=varargin{argc+1};
		case 'transducer'
			clear xdcr;
			if isstruct(varargin{argc+1});
				xdcr=varargin{argc+1};
            else
				disp('xdcr needs to be a struct, please create one')
				disp('Use the get_<xdcr type> function to make one')
				disp('Script aborted');
				pressure=[];
				return
			end
		case 'cg'
			clear cg;
            if isstruct(varargin{argc+1});
                cg=varargin{argc+1};
            else
                disp('cg omitted or bad, forcing user to set a coordinate grid')
                cg=set_coordinate_grid();
            end
		case 'medium'
            clear medium
            if isstruct(varargin{argc+1});            
                medium=varargin{argc+1};
            else
                disp('medium omitted or bad, forcing user to create a new one')
                medium=set_medium();
            end
		case 'tol'
			clear tol
			if isreal(varargin{argc+1}) && varargin{argc+1}>0
				tol=varargin{argc+1};
			else 
				disp('tol needs to be real')
				tol=input('Please enter a tol:');
			end
		case 'ndiv'
			clear ndiv
			if floor(varargin{argc+1})==varargin{argc+1} && isreal(varargin{argc+1})
				ndiv=varargin{argc+1};
			else
				disp('ndiv MUST be an integer');
				ndiv=input('Please enter an integer ndiv > 2:');
			end
		case 'f0'
			clear f0
			f0=varargin{argc+1};
		otherwise
			test=sprintf('Cannot understand argument %s with value %f, discarding\n',varargin{argc},varargin{argc+1});
			disp(test);
		end
	argc=argc+2;
end

% time to check for reasonable arguments and pass to another function
% xdcr is ASSUMED to be correct. We have to start somewhere.
if isstruct(xdcr)~=1 && xdcr==-inf
	disp('You forgot to give an xdcr, this function cannot continue')
	pressure=[];
	return
end

if ~isstruct(cg)
    cg=set_coordinate_grid();
end

% if length(fieldnames(cg))~=9
%     disp('incorrect structure for coordinate grid, forcing new one')
%     param=set_parameters();
% end

if ~isstruct(medium)
    evalin('base','define_media');
    medium=evalin('base','water');
end
if ~isnumeric(medium.density) || ~isnumeric(medium.attenuationdBcmMHz) || ~isnumeric(medium.soundspeed)
    disp('critcal medium information incorrect')
    medium=set_medium();
end

if f0==-inf 
    if dflag==1
        disp('f0 not give, assuming 1e6hZ')
    end
    f0=1e6;
end

if min(cg.delta) > .5*(medium.soundspeed/f0) && dflag==1
	disp('Your delta value will result in aliasing')
	disp('Your data might be inaccurate, suggest you re-run with lower delta')
elseif cg.delta==-inf
    if dflag==1
    	disp('You forgot to get delta')
    	disp('Delta set to lambda/2')
    end
	cg.delta= .5*(medium.soundspeed/f0);
end

if tol==-inf && ndiv==-inf
    if dflag==1
    	disp('Using default tolerance of 1e-10')
    end
	ndiv=find_ndiv(xdcr,cg,medium,f0,1e-10);
elseif ndiv==-inf;
	ndiv=find_ndiv(xdcr,cg,medium,f0,tol);
end

if dflag==1
    pressure=fnm_call(xdcr,cg,medium,ndiv,f0,1);
else
    pressure=fnm_call(xdcr,cg,medium,ndiv,f0,0);
end
