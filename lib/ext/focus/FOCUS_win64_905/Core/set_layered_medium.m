function layered_media_struct = set_layered_medium(layer_z_start, layer_medium_properties)
%SET_LAYERED_MEDIUM Create an object representing a layered medium
%   layer_z_start: 1-d array of z-coordinates representing the beginning of each layer
%   layer_medium_properties: 1-d array of medium structs (from set_medium())
%       corresponding to the start points in layer_z_start. layer(n)
%       extends from z_start(i) to z_start(i+1). The last layer extends to
%       infinity.

layered_media_struct = [];
% Check for 1-d arrays
if ndims(layer_z_start) > 2 || ndims(layer_medium_properties) > 2
    error('Layer z-indices and layer properties arrays must be one-dimensional.');
end
% Check for same lengths
if size(layer_z_start) ~= size(layer_medium_properties)
    error('layer_z_start must have the same number of elements as layer_medium_properties.');
end
% First layer must start at z = 0
if layer_z_start(1) ~= 0
    error('The first layer must start at z = 0.');
end
% Start filling the array of media
nlayers = length(layer_z_start);
for i = 1:nlayers
    % Set up the struct
    layered_media_struct(i).specificheatofblood = layer_medium_properties(i).specificheatofblood;
    layered_media_struct(i).bloodperfusion = layer_medium_properties(i).bloodperfusion;
    layered_media_struct(i).density = layer_medium_properties(i).density;
    layered_media_struct(i).soundspeed = layer_medium_properties(i).soundspeed;
    layered_media_struct(i).powerlawexponent = layer_medium_properties(i).powerlawexponent;
    layered_media_struct(i).attenuationdBcmMHz = layer_medium_properties(i).attenuationdBcmMHz;
    layered_media_struct(i).specificheat = layer_medium_properties(i).specificheat;
    layered_media_struct(i).thermalconductivity = layer_medium_properties(i).thermalconductivity;
    layered_media_struct(i).nonlinearityparameter = layer_medium_properties(i).nonlinearityparameter;
    % Set the z start and end
    layered_media_struct(i).z_start = layer_z_start(i);
    layered_media_struct(i).z_end = Inf;
    if i > 1
        layered_media_struct(i-1).z_end = layer_z_start(i);
        if layer_z_start(i-1) >= layer_z_start(i)
            layered_media_struct = [];
            error('Layer z-coordinates must be monotonically increasing.');
        end
    end
end
end
