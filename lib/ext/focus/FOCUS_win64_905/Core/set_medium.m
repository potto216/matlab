function medium=set_medium(varargin)
% Description
%   Create a medium struct for use with other FOCUS functions.
% Usage
%   medium = set_medium();
%   medium = set_medium(cb, wb, rho, c_sound, b, atten_coeff, ct, kappa, beta);  
% Arguments
%   cb: Specific heat of blood in J/kg/K
%   wb: Blood perfusion in kg/meter3/s
%   rho: The density of the medium in kg/meter3
%   c_sound: The speed of sound in m/s
%   b: Power law exponent; unitless.
%   atten_coeff: Attenuation coefficient in dB/cm/MHz
%   ct: Specific heat of the medium in J/kg/K
%   kappa: Thermal conductivity in W/m/K
%   beta: Nonlinear parameter; unitless.
% Output Parameters
%   medium: A MATLAB struct with the following properties:
% Notes
%   If no arguments are specified, the function will prompt the user to enter the correct values.
if nargin()==0
	disp('Please enter the medium variables:')
    disp('If you don''t know what these parameters mean, please use one of the media defined by define_media.')
	wb=input('Blood perfusion (kg/m^3/s): ');
	rho=input('Density (kg/m^3): ');
	c_sound=input('Speed of sound (m/s): ');
	b=input('Power Law exponent (unitless): ');
    atten_coeff=input('Attenuation (dB/cm/MHz): ');
    ct=input('Specific heat (J/kg/K): ');
    kappa=input('Thermal conductivity (W/m/K): ');
    beta=input('Nonlinearity parameter (unitless): ');
	medium=set_medium(3480,wb,rho,c_sound,b,atten_coeff,ct,kappa,beta);
	return
% 1 argument: string representing medium type, e.g. 'lossless'
elseif nargin()==1
    if strcmp(varargin{1}, 'lossless')
        medium = set_medium(3.48e3, 0, 1.000e3, 1.500e3, 1, 0, 4.180e3, 6.150e-1, 0);
    elseif strcmp(varargin{1}, 'attenuated')
        medium = set_medium(3.48e3, 0, 1.000e3, 1.500e3, 1, 1, 4.180e3, 6.150e-1, 0);
    elseif strcmp(varargin{1}, 'water')
        medium = set_medium(3.48e3, 0, 1.000e3, 1.500e3, 1, 2.5e-4, 4.180e3, 6.150e-1, 0);
    elseif strcmp(varargin{1}, 'skin')
        medium = set_medium(3.48e3, 5, 1.200e3, 1.498e3, 1, 1.4e-1, 3.430e3, 2.660e-1, 0);
    elseif strcmp(varargin{1}, 'fat')
        medium = set_medium(3.48e3, 5, 9.210e2, 1.445e3, 1, 7.0e-2, 2.325e3, 2.230e-1, 0);
    elseif strcmp(varargin{1}, 'muscle')
        medium = set_medium(3.48e3, 5, 1.138e3, 1.569e3, 1, 8.0e-2, 3.720e3, 4.975e-1, 0);
    elseif strcmp(varargin{1}, 'liver')
        medium = set_medium(3.48e3, 5, 1.060e3, 1.540e3, 1, 3.2e-2, 3.600e3, 5.120e-1, 0);
    elseif strcmp(varargin{1},'nonlinearlossless')
        medium = set_medium(3.48e3, 0, 1.000e3, 1.500e3, 1, 0, 4.180e3, 6.150e-1, 1);
    elseif strcmp(varargin{1},'nonlinearlossy')
        medium = set_medium(3.48e3, 0, 1.000e3, 1.500e3, 1, 1e-2, 4.180e3, 6.150e-1, 1);
    else
        error('FOCUS:InvalidMediumType','Invalid medium type. See the documentation for a list of accepted types.');
    end
    return
% 9 arguments: all properties defined
elseif nargin()==9
    medium.specificheatofblood=varargin{1};
    medium.bloodperfusion=varargin{2};
    medium.density=varargin{3};
    medium.soundspeed=varargin{4};
    medium.powerlawexponent=varargin{5};
    % Decide which attenuation to set based on the power law exponent
    if medium.powerlawexponent == 1
        medium.attenuationdBcmMHz=varargin{6};
    else
        medium.attenuationdBcmMHzy=varargin{6};
    end
    medium.specificheat=varargin{7};
    medium.thermalconductivity=varargin{8};
    medium.nonlinearityparameter=varargin{9};
    return
% Number of arguments not a multiple of 2; arguments are not preceded by their names
elseif ~mod(nargin(),2)
    arg_count = nargin();
    % Assign default values for all properties
    medium.specificheatofblood = 3.48e3;
    medium.bloodperfusion = 0;
    medium.density = 1000;
    medium.soundspeed = 1500;
    medium.powerlawexponent = 1;
    medium.specificheat = 4.18e3;
    medium.thermalconductivity = 6.15e-1;
    medium.nonlinearityparameter = 0;
    % Assign any arguments that are present
    for i=1:2:arg_count
        arg_label = varargin{i};
        arg_value = varargin{i+1};
        if ~(isa(arg_label, 'char') && isa(arg_value, 'numeric'))
            error('FOCUS:InvalidArguments','Invalid arguments provided. Please see the documentation for information on how to use this function.');
            return
        end
        if strcmp(arg_label, 'specificheatofblood')
            medium.specificheatofblood = arg_value;
        elseif strcmp(arg_label, 'bloodperfusion')
            medium.bloodperfusion = arg_value;
        elseif strcmp(arg_label, 'density')
            medium.density = arg_value;
        elseif strcmp(arg_label, 'soundspeed')
            medium.soundspeed = arg_value;
        elseif strcmp(arg_label, 'powerlawexponent')
            medium.powerlawexponent = arg_value;
        elseif strcmp(arg_label, 'attenuationdBcmMHz')
            medium.attenuationdBcmMHz = arg_value;
        elseif strcmp(arg_label, 'attenuationdBcmMHzy')
            medium.attenuationdBcmMHzy = arg_value;
        elseif strcmp(arg_label, 'specificheat')
            medium.specificheat = arg_value;
        elseif strcmp(arg_label, 'thermalconductivity')
            medium.thermalconductivity = arg_value;
        elseif strcmp(arg_label, 'nonlinearityparameter')
            medium.nonlinearityparameter = arg_value;
        end
    end
    % Check that the medium is sane
    % Power law attenuation but y = 1 -- won't cause wrong results so just a warning
    if isfield(medium, 'attenuationdBcmMHzy') && medium.powerlawexponent == 1
        warning('Power law attenuation has been specified but the power law exponent is 1. ''attenuationdBcmMHz'' can be used for non-power law media.');
    % Non-power law attenuation but y != 1 -- error
    elseif isfield(medium, 'attenuationdBcmMHz') && medium.powerlawexponent ~= 1
        error('Power law exponent is not 1 but a non-power law attenuation has been specified. You must use ''attenuationdBcmMHzy'' to set attenuation for power law media.');
    end
    % Both attenuations set -- error
    if isfield(medium, 'attenuationdBcmMHz') && isfield(medium, 'attenuationdBcmMHzy')
        error('Both power law and non-power law attenuation values are set. Only one of these variables may be set for the simulation to work correctly.');
    end
    % Set default attenuation based on power law exponent
    if ~isfield(medium, 'attenuationdBcmMHz') && ~isfield(medium, 'attenuationdBcmMHzy')
        if medium.powerlawexponent == 1
            medium.attenuationdBcmMHz = 0;
        else
            medium.attenuationdBcmMHzy = 0;
        end
    end
    return
else
    error('FOCUS:InvalidArguments','Invalid number of arguments provided. See the documentation for information about the arguments.');
end
