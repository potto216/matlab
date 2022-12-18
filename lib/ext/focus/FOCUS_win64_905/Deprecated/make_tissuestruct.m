function tissue_struct = make_tissuestruct(z,nlayer,z_int,types)
% The parameters of tissue layers in a MATLAB structure.
% Usage:
% tissue_struct = get_tissuestruct(z,f0,nlayer,z_int,types);
% Input parameter:
% z - vector, grid in the z direction.
% nlayer - scalar, No. of tissue layers.
% z_int - vector, locations of interfaces in the z direction
% types - vector, tissue types
% Output parameter:
% tissue_struct - MATLAB structure containing memebers:
%        zint: the interface separating the currect and the next layers
%        zend: the last z grid in the currect layer
%      zstart: the first z grid in the currect layer
%          cb: specific heat of blood, units are J/kg/C
%          wb: blood perfusion (optional), units are kg/m^3/second
%         rho: density of the tissue, units are kg/m^3
%           c: speed of sound, units are m/s
%           b: power law coefficient for attenuation
%     wavelen: wavelength, units are m
%       atten: attenuation coefficient, units are dB/m
%          ct: specific heat of tissue, units are J/kg/C
%       kappa: thermal conductivity, units are W/m/C
%        beta: nonlinear parameter

warning('''make_tissuestruct'' is no longer supported. Use ''set_layered_medium'' instead.');

if nargin<=2
    fprintf('Select tissue types: w -> water, s->skin, f->fat, m->muscle,l->liver.\n');
    nlayer = str2num(input('Input the number of layers ','s'));
    types = [];
    z_int = [];
    for in = 1:nlayer
        fprintf('\n');
        types = [types input('Tissue type ','s')];
        z_int = [z_int str2num(input('Interface location ','s'))];
    end
end

if length(z_int) ~= (nlayer-1)
    error('No. of interfaces = No. of layers-1\n');
end
if length(types) ~= nlayer
    error('No. of tissue types = No. of layers\n');
end
tissue_struct= types;
for in = 1:nlayer    
    if in==nlayer % the last layer does not have reflection
        tissue_struct(in).zint = [];
        tissue_struct(in).zend = z(end);
    else
        tissue_struct(in).zint = z_int(in);
        tissue_struct(in).zend = z(max(find(z<=tissue_struct(in).zint)));
    end
    % The first layer starts at z(1).
    if in==1 
        tissue_struct(in).zstart = z(1);
    else
        tissue_struct(in).zstart = z(min(find(z>tissue_struct(in-1).zint)));
    end
	%REMOVE THIS LINE WHEN NON-LIN STUFF IS ADDED
    tissue_struct(in).nonlinearityparameter=0;
    tissue_struct(in).cb = 3840;
end

