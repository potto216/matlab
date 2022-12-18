function intensity = cw_intensity(varargin)
%CW_INTENSITY Summary of this function goes here
%   Detailed explanation goes here
if nargin == 2
    pressure = varargin{1};
    medium = varargin{2};
    
    %intensity = medium.attenuationdBcmMHz/(medium.density*medium.soundspeed) * (pressure .* conj(pressure));
    intensity = (pressure .* conj(pressure)) / (2*medium.density*medium.soundspeed);
elseif nargin == 5
    xdcr_array = varargin{1};
    cg = varargin{2};
    medium = varargin{3};
    ndiv = varargin{4};
    f0 = varargin{5};
    
    pressure = fnm_call(xdcr_array, cg, medium, ndiv, f0, 0);
    intensity = cw_intensity(pressure, medium);
else
    intensity = [];
    error('cw_intensity accepts either 2 or 5 arguments. See the documentation for the correct usage.');
end

end
