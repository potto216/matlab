function param=set_parameters(varargin)
% obslete, parameter struct no longer in use
% creates a parameter array sutiable for use with fnm code
% to use this function, 
% parameters=set_parameters('name_of_parameter',parameter_value,....)
% valid parameters are c_sound, atten_coeff, rho_density, f0, and fs. 
% Unless BOTH f0 and fs are given, this function will set them equal.
% units should be given in SI units (M K S)
% default units are 1.5MHz, and 1500 m./s with no attenuation.
warning('''set_parameters'' is no longer supported. Use ''set_medium'' instead.');

if nargin()==0
	disp('Please enter the following variables:')
	disp('fs c atten_coeff rho_density f0')
	disp('if unsure, let fs=f0 and atten_coeff=rho_denisty=0')
	fs=input('fs(1e6)');
	c=input('c_sound(1500)');
	atc=input('atten_coeff(0)');
	rhd=input('rho_density(0)');
	f0=input('f0(1e6)');
	param=set_parameters('c_sound',c,'atten_coeff',atc,'rho_density',rhd,'f0',f0,'fs',fs);
	return
end
	
if nargin()/2~=floor(nargin()/2)
    param=[];
	error('Must have an even number of arguments')
end
if nargin()>10
	param=[];
    error('Too many arguments')
end
param=[-1 1.5e3 0 0 1.5e6];
argc=1;
while argc<nargin()
	if isempty(varargin{argc+1})==false
		switch lower(varargin{argc})
			case 'c_sound'
				param(2)=varargin{argc+1};
			case 'atten_coeff'
				param(3)=varargin{argc+1};
			case 'rho_density'
				param(4)=varargin{argc+1};
			case 'f0'
				param(5)=varargin{argc+1};
			case 'fs'
				param(1)=varargin{argc+1};
			otherwise
				test=sprintf('Cannot understand argument %s with value %f, discarding\n',varargin{argc},varargin{argc+1});
				disp(test);
			end
	end
	argc=argc+2;
	

end
if param(1)==-1 || param(5)~=1.5e6
	param(1)=param(5);
else
	param(5)=param(1);
end