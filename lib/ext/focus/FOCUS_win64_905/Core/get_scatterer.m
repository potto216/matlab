function scatterer = get_scatterer(varargin)
%GET_SCATTERER Create a scatterer object at the given point
    if nargin < 3 || nargin > 4
        error('get_scatterer requires either 3 or 4 arguments. See the documentation for details.');
    end
    scatterer.x = varargin{1};
    scatterer.y = varargin{2};
    scatterer.z = varargin{3};
    
    if nargin == 4
        scatterer.amplitude = varargin{4};
    else
        scatterer.amplitude = 1;
    end
end

