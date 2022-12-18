function phase_vector = get_phases(xdcr_array)
% Description
%     This function is used get a matrix containing the phases of all elements of a transducer array.
% Usage
%     phases = get_phases(transducer_array);
% Arguments
%     * transducer_array: A FOCUS transducer array.
% Output Parameters
%     * phases: An m by n matrix where element (m,n) contains the phase of transducer array element (m,n).


n = size(xdcr_array,1);
m = size(xdcr_array,2);
phase_vector = zeros(n,m);

for in = 1:n
    for im = 1:m
        phase_vector(in,im) = xdcr_array(in,im).phase;
    end
end

end
