function xdcr_out = set_phases(varargin)
% Description
%   This function is used to focus transducer arrays by manually setting the phases of the individual transducers.
% Usage
%   transducer = set_phases(transducer, phases); 
% Arguments
%   transducer: A FOCUS transducer array.
%   phases: A vector the same size as the transducer array containing the phase to be used for each element in the array, e.g. [0 pi/2 pi pi/2 0] for a five-element array.
% Output Parameters
%   transducer: The transducer struct with the new phase values.

xdcr = varargin{1};
xdcr_out = xdcr;

if nargin == 2
    phases = varargin{2};

    array_width = size(xdcr, 1);
    array_height = size(xdcr, 2);
    % Detect string type
    if size(xdcr) ~= size(phases)
        error('Phase vector must be the same size as the transducer array.');
    end
    for i=1:array_width
        for j=1:array_height
            xdcr_out(i,j).phase = phases(i,j);
        end
    end
elseif nargin >= 6 && nargin <= 8
    x = varargin{2};
    y = varargin{3};
    z = varargin{4};
    if length(x) ~= length(y) || length(y) ~= length(z) || length(x) ~= length(z)
        error('Must have the same number of x, y, and z coordinates.');
    end
    % Do we have a single focus or more than one?
    if length(x) == 1
        xdcr_out = find_single_focus_phase(varargin{:});
    else
        xdcr_out = find_multiple_focus_phase(varargin{:});
    end
else
    error('Incorrect number of input arguments.');
end
