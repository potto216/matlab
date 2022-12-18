function pressure=asa_run(varargin)
warning('This function is deprecated and may be removed from future versions of FOCUS. Please use cw_angular_pressure instead.');
% this function is an intelligent function to call the asa routines. 
% it is recommend you use this function for all asa needs.
% the proper calling structure is:
% pressure=asa_run('arg_name",arg_value)
% arg names are:
% source: 2-d source plane
% z: array of values to caculate planes on z(1) should be the location of the source plane
% nfft: number of nfft caculations to perform
% delta: use whatever delta was used to caculate the source plane
% type: type of ASA to be computed, possible values are [P p V v Va Pa]
% source is the only argument required to run the script
if nargin()==0
	disp('The proper use of this functions is:')
	help asa_run
	return;
end
if nargin()/2~=floor(nargin()/2)
	disp('Must have an even number of arguments')
	pressure=[];
	return;
end
source=-inf;
z=-inf;
nfft=-inf;
delta=-inf;
medium=-inf;
type='Pa';

% argument phrasing
argc=1;
while argc<nargin();
	switch lower(varargin{argc})
        case 'type'
            type=varargin{argc+1};
        case 'source'
			if max(size(varargin{argc+1}))==min(size(varargin{argc+1})) && ndims(varargin{argc+1})
				clear source;
				source=varargin{argc+1};
			else
				disp('Invalid source matrix, must be m by m matrix')
				pressure=[];
				return;
			end
		case 'medium'
			clear medium
			medium=varargin{argc+1};
		case 'z'
			clear z;
			z=varargin{argc+1};
		case 'nfft'
			if varargin{argc+1}>0
				clear nfft;
				nfft=varargin{argc+1};
			else
				disp('nfft must be positive integer');
				pressure=[];
                return;
			end
		case 'delta'
			clear delta;
			if varargin{argc+1}>0 && isreal(varargin{argc+1})
				delta=varargin{argc+1};
			else
				disp('Delta cannot be negative or imaginary')
				delta=input('Please enter a delta:');
			end
		otherwise
			test=sprintf('Cannot understand argument %s with value %f, discarding\n',varargin{argc},varargin{argc+1});
			disp(test);
		end
	argc=argc+2;
end
% checkc for flaws
if length(source)==1
	disp('you forgot a source matrix, aborting')
	pressure=[];
	return;
end	
if length(z)==1
	%disp('you cannot use asa method for a single plance');
	disp('z must be an array, use "zstart:zstep:zend" to enter a z array')
	z=input('Please enter a z array');
end
if nfft==-inf
	disp('you negelected to enter a nfft number, nfft has been chosen for you')
    nfft=2^nextpow2(2*length(source));
end
if ~isstruct(medium)
	disp('bad medium struct, assuming water should be used')
    define_media;
    medium=water;
end
if delta==-inf
	disp('delta was not provided incorrect delta will break the code')
	delta=input('correct delta?');
end
if nfft<2*length(source)
	disp('nfft needs to >= 2*nr, setting nfft to something useful')
	nfft=2^nextpow2(2*length(source));
end
pressure=asa_call(source,z,medium,nfft,delta,type);