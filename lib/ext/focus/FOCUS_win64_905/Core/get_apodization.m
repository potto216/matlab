function amplitude_vector = get_apodization(xdcr_array)
% Description
%     This function is used get a matrix containing the amplitudes of all elements of a transducer array.
% Usage
%     amplitudes = get_apodization(transducer_array);
% Arguments
%     * transducer_array: A FOCUS transducer array.
% Output Parameters
%     * amplitudes: An m by n matrix where element (m,n) contains the amplitude of transducer array element (m,n).

n = size(xdcr_array,1);
m = size(xdcr_array,2);

amplitude_vector = zeros(n,m);

for in = 1:n
    for im = 1:m
        amplitude_vector(in,im) = xdcr_array(in,im).amplitude;
    end
end


end
