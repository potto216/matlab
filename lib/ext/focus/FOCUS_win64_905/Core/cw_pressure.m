function pressure = cw_pressure(varargin)
%CW_PRESSURE Summary of this function goes here
%   Detailed explanation goes here
if nargin < 5 || nargin > 6
    error('Incorrect number of arguments for cw_pressure. Please see the documentation for details on how to use this function.');
end

xdcr_array = varargin{1};
coord_grid = varargin{2};
medium = varargin{3};
ndiv = varargin{4};
f0 = varargin{5};

if nargin < 6
    method = 'fnm';
else
    method = varargin{6};
end

if strfind(method,'fnm')
    if strfind(method, 'sse')
        % Round ndiv up to the nearest multiple of 4
        ndiv = ceil(ndiv/4)*4;
        pressure = fnm_cw_sse(xdcr_array, coord_grid, medium, ndiv, f0, 0);
    else
        pressure = fnm_call(xdcr_array, coord_grid, medium, ndiv, f0, 0);
    end
elseif strfind(method, 'farfield')
    pressure = farfield_cw(xdcr_array, coord_grid, medium, ndiv, f0, 0);
elseif strfind(method, 'rayleigh')
    if strfind(method, 'sse')
        % Round ndiv up to the nearest multiple of 4
        ndiv = ceil(ndiv/4)*4;
        pressure = rayleigh_cw_sse(xdcr_array, coord_grid, medium, ndiv, f0, 0);
    else
        pressure = rayleigh_cw(xdcr_array, coord_grid, medium, ndiv, f0, 0);
    end
else
    error('Unsupported calculation method. See the documentation for cw_pressure for valid values.');
end
end
