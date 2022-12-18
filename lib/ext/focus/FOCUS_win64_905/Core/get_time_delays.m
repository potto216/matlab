function td_vector = get_time_delays(xdcr_array)
% Description
%     This function is used get a matrix containing the time delays of all elements of a transducer array.
% Usage
%     time_delays = get_time_delays(transducer_array);
% Arguments
%     * transducer_array: A FOCUS transducer array.
% Output Parameters
%     * time_delays: An m by n matrix where element (m,n) contains the time delay of transducer array element (m,n).

n = size(xdcr_array,1);
m = size(xdcr_array,2);
td_vector = zeros(n,m);

for in = 1:n
    for im = 1:m
        td_vector(in,im) = xdcr_array(in,im).time_delay;
    end
end

end
