function pressure = fnm_cw_parfor(xdcr, cg, medium, ndiv, f0, dflag)
%FNM_CW_PARFOR Uses the MATLAB parfor command to use multiple threads to
%process transducer arrays.
% Arguments are the same as for fnm_call and fnm_cw
pressure = 0;
parfor i = 1:size(xdcr,1)*size(xdcr,2)
    pressure = pressure + fnm_call(xdcr(i), cg, medium, ndiv, f0, dflag);
end
end