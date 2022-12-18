function [xg, yg, tg, region] = gradients_xyt(image1, image2, varargin)
%GRADIENTS_XYT Estimate spatial and temporal grey-level gradients
%   [XG, YG, TG, REGION] = GRADIENTS_XYT(IMAGE1, IMAGE2, SIGMAS) carries
%   out Gaussian smoothing and differencing to estimate the spatial and
%   temporal grey-level gradients for a pair of images.
%
%   IMAGE1 and IMAGE2 are 2D arrays which must be the same size as each
%   other, representing successive images in a sequence.
%
%   SIGMAS specifies the spatial smoothing. This may be a matrix of the
%   form [SIGMAX SIGMAY] or a scalar specifying the values of both SIGMAX
%   and SIGMAY. SIGMAX and SIGMAY are the "sigma" parameters of the 1D
%   Gaussian masks used for smoothing along the rows and columns
%   respectively. (Smoothing along a row means smoothing across columns -
%   i.e. the mask is a row vector.) A value of 0 indicates no smoothing is
%   required.
%
%   XG and YG are estimates of the spatial gradients, computed by smoothing
%   the average of the two input images and finding symmetric local
%   differences. TG is the smoothed difference between the two images.
%
%       The output arrays will be smaller than the input arrays in order to
%       avoid having to make unreliable assumptions near the boundaries of
%       the array. The result REGION reports the region of the input arrays
%       for which the gradients have been estimated, in the form [MINROW,
%       MAXROW, MINCOL, MAXCOL]. The size of the output arrays is
%       [MAXROW-MINROW+1, MAXCOL-MINCOL+1]. The reduction in size depends
%       on the smoothing parameters.
%
%   [XG, YG, TG, REGION] = GRADIENTS_XYT(IM, IM, SIGMAS, WRAP) can be used
%   to specify that the image wraps round on one or more axes. WRAP may be
%   a logical 1x2 matrix of the form [WRAPX WRAPY] or a logical scalar
%   which specifies both WRAPX and WRAPY. If WRAPX is true the rows of the
%   images wrap round; if WRAPY is true the columns wrap round. If the
%   rows/columns wrap, the number of columns/rows will not be reduced in
%   the output arrays.
%
%   [XG, YG, TG, REGION] = GRADIENTS_XYT(IM1, IM2, SIGMAS, WRAP, REGION)
%   allows a region of interest to be specified. REGION may be a 4-element
%   row vector with elements [MINROW, MAXROW, MINCOL, MAXCOL] describing a
%   rectangular region. The results arrays will have size [MAXROW-MINROW+1,
%   MAXCOL-MINCOL+1] and will contain the estimated gradients for the
%   specified region of the input images. The REGION argument is returned
%   unchanged. An empty REGION is the same as omitting it.
%
%       It is possible to specify a region which goes right up to
%       the boundaries of the image, or even goes outside it. In these
%       cases reflection at the boundaries will be used to extrapolate the
%       image in any directions in which it does not wrap round.
%
%   REGION = GRADIENTS_XYT(IM1, IM2, SIGMAS, WRAP, 'region') returns only
%   the default region, without computing the gradients.

% Copyright David Young 2010

% check arguments and get defaults
[sigmas, wraps, region, regonly] = checkinputs(image1, image2, varargin{:});

% can stop now if only the region to be returned
if regonly
    xg = region;
    return;
end
    
% expand the region to allow for subsequent differencing operation
regdiff = region + [-1 1 -1 1];

% region selection and spatial smoothing (do this before sum and difference
% to reduce processing if region is small)
imsmth1 = gsmooth2(image1, sigmas, wraps, regdiff);
imsmth2 = gsmooth2(image2, sigmas, wraps, regdiff);

% Hor and vert differencing masks - use [1 0 -1]/2 to get the average
% gradient over 2 pixels, and divide by 2 again to replace sum by average.
imsum = imsmth1 + imsmth2;
dmask = [1 0 -1]/4;
xg = conv2(imsum, dmask, 'valid');
xg = xg(2:end-1, :);
yg = conv2(imsum, dmask.', 'valid');
yg = yg(:, 2:end-1);

% temporal differencing
tg = imsmth2 - imsmth1;
tg = tg(2:end-1, 2:end-1);

end

% -------------------------------------------------------------------------

function [sigmas, wraps, region, regonly] = checkinputs( ...
    image1, image2, sigmas, wraps, region)
% Check arguments and get defaults

error(nargchk(3, 5, nargin, 'struct'));

% most attributes checked in gsmooth, so do not check here
if ~isequal(size(image1), size(image2))
    error('gradients_xyt:badsize', 'Size of image2 does not match image1');
end

if nargin < 4 || isempty(wraps)
    wraps = false(1,2);
elseif isscalar(wraps)
    wraps = [wraps wraps];
end

if nargin < 5
    region = [];
end
regonly = strcmp(region, 'region');
if isempty(region) || regonly
    % default region - small enough not to need extrapolation
    region = gsmooth2(image1, sigmas, wraps, 'region');
    region = region + ~wraps([2 2 1 1]) .* [1 -1 1 -1];
end
if any(region([2 4]) < region([1 3]))
    error('affine_flow:gradients_xyt:badreg', 'REGION or array size too small');
end

end

