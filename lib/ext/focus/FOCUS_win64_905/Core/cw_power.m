function power = cw_power( varargin )
%CW_POWER Summary of this function goes here
%   Detailed explanation goes here
if nargin == 2
    pressure = varargin{1};
    medium = varargin{2};
    
    power = medium.attenuationdBcmMHz/(medium.density*medium.soundspeed) * (pressure .* conj(pressure));
elseif nargin == 5
    xdcr_array = varargin{1};
    cg = varargin{2};
    medium = varargin{3};
    ndiv = varargin{4};
    f0 = varargin{5};
    
    pressure = fnm_call(xdcr_array, cg, medium, ndiv, f0, 0);
    power = cw_power(pressure, medium);
else
    power = [];
    error('cw_intensity accepts either 2 or 5 arguments. See the documentation for the correct usage.');
end

end
