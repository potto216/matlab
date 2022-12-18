function pressure = rayleigh_transient_parfor(xdcr, cg, medium, time_struct, ndiv, excitation_function, dflag)
%RAYLEIGH_TRANSIENT_PARFOR Uses the MATLAB parfor command to use multiple threads to
%process transducer arrays.
% Arguments are the same as for rayleigh_transient
pressure = 0;
parfor i = 1:size(xdcr,1)*size(xdcr,2)
    pressure = pressure + rayleigh_transient(xdcr(i), cg, medium, time_struct, ndiv, excitation_function, dflag);
end
end

