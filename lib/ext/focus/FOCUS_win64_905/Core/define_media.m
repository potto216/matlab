%% Define Media
% Defines several media structs to be used with FOCUS. Also defines a
% default center frequency (f0) of 1MHz.

%% Unit definitions
% cb: specific heat of blood,  units are J/kg/C
% wb: blood perfusion (optional), units are kg/m^3/second
% rho: density of the tissue, units are kg/m^3
% c: speed of sound, units are m/s
% b: power law coefficient for attenuation
% atten: calculated attenuation
% ct: specific heat of tissue, units are J/kg/C
% kappa: thermal conductivity, units are W/m/C
% beta: nonlinear parameter 
% atten_coeff: attenuation coefficient, db/Cm/MHz

%% Media
% This script defines the following media:
% lossless
% attenuated
% water
% skin
% fat
% muscle
% liver

% Define f0 if it doesn't exist
if exist('f0','var')~=1
        f0=1e6;
else
    if ~isnumeric(f0)
        f0=1e6;
    end
end

% Define the media.
lossless = set_medium('lossless');
attenuated = set_medium('attenuated');
water = set_medium('water');
skin = set_medium('skin');
fat = set_medium('fat');
muscle = set_medium('muscle');
liver = set_medium('liver');