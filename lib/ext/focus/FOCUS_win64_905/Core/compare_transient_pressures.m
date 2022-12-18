% Description
% This function calculates the peak error between two transient pressure
% fields.
%
% Usage
% pressure_error = compare_transient_pressures(reference_field, comparison_field);
% Arguments
% * reference_field: The transient pressure field to use as the reference.
% * comparison_field: The transient pressure field to compare to the reference field.
%
% Output Parameters
% * pressure_error: The maximum normalized error in the comparison pressure field relative to the reference.
% 
% Notes
% The error between the two pressure fields is calculated by taking the
% difference between the two fields at each point in space and then
% dividing these values by the peak pressure in the reference field. The
% largest of these values is returned.

function pressure_error = compare_transient_pressures(reference_field, comparison_field)

if size(reference_field) ~= size(comparison_field)
    error('Both pressure fields must have the same dimensions in order to compare them.');
end

if ndims(reference_field) ~= 4
    error('Both pressure fields must be 4D (i.e. transient).');
end

nx = size(comparison_field, 1);
ny = size(comparison_field, 2);
nz = size(comparison_field, 3);

error3D = zeros(nx, ny, nz);

maxnorm = 0;
for ix = 1:nx,
    for iy = 1:ny,
        for iz = 1:nz,
            maxnorm = max(maxnorm, norm(squeeze(reference_field(ix, iy, iz, :))));
            error3D = norm(squeeze(reference_field(ix, iy, iz, :) - comparison_field(ix, iy, iz, :)));
        end
    end
end

pressure_error = max(max(max(error3D))) / maxnorm; % normalize the difference by the max norm of the ref signal
