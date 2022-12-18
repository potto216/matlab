function pressure = fnm_transient_parfor(xdcr, cg, medium, fs, ndiv, excitation_function, dflag)
%FNM_TRANSIENT_PARFOR Uses the MATLAB parfor command to use multiple threads to
%process transducer arrays.
% Arguments are the same as for fnm_transient and fnm_transient_call
pressure = 0;
parfor i = 1:size(xdcr,1)*size(xdcr,2)
    pressure = pressure + fnm_transient_call(xdcr(i), cg, medium, fs, ndiv, excitation_function, dflag);
end
end