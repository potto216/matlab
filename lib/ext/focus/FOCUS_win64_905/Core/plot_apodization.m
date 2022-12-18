function plot_apodization(xdcr_array)
%PLOT_APODIZATION Plot the apodization of a given transducer array
%   xdcr_array: An array of FOCUS transducer structs
xdcr_count = size(xdcr_array,1);
ap_vector = ones(1,xdcr_count);

for i = 1:xdcr_count
    ap_vector(i) = xdcr_array(i).amplitude;
end

figure();
plot(1:xdcr_count, ap_vector);
end
