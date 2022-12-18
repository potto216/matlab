function xdcr = set_apodization(xdcr, apodization, r)
% Description
%   This function is used to apodize transducer arrays by setting the amplitudes of the individual transducers.
% Usage
%   transducer = set_apodization(transducer, apodization, r); 
% Arguments
%   transducer: A FOCUS transducer array.
%   apodization: A vector the same size as the transducer array containing the amplitude to be used for each element in the array, e.g. [0 0.5 1 0.5 0] for a five-element array. This argument can also be a string representing the type of apodization to use. Options are:
%     bartlett: Bartlett-Hann window � see documentation for the MATLAB bartlett() function for details.
%     chebyshev: Chebyshev window � see documentation for the MATLAB chebwin() function for details.
%     hamming: Hamming window � w(n) = 0.54 - 0.46cos(2? n/N - 1)
%     hann: Hann window � w(n) = 0.5(1 - cos(2? n/N - 1))
%     triangle: Triangular window � w(n) = 2n/N - 1(N - 1/2 - |n - N - 1/2|)
%     uniform: Uniform window � w(n) = 1
%   r: An optional tuning parameter used only for Chebyshev apodization. r is the desired size of the sidelobes relative to the main lobe in dB. The default value is 100.
% Output Parameters
%   transducer: The transducer struct with the new amplitude values.

xdcr_size = size(xdcr,1);
curved = size(xdcr,2);
% Detect string type
if ischar(apodization)
    if strcmp(apodization,'bartlett')
        ap_vector = bartlett(xdcr_size);
    elseif strcmp(apodization, 'chebyshev')
        if ~exist('r','var')
            r = 100;
        end
        % Chebwin only works on MATLAB, not Octave
        if exist('OCTAVE_VERSION')
            warning('Chebyshev apodization not supported on Octave.');
            ap_vector = ones(xdcr_size,1);
        else
                ap_vector = chebwin(xdcr_size,r);
        end
    elseif strcmp(apodization, 'hamming')
        ap_vector = hamming(xdcr_size);
    elseif strcmp(apodization, 'hann') || strcmp(apodization, 'hanning')
        if exist('OCTAVE_VERSION')
            warning('Hann apodization not supported on Octave.');
            ap_vector = ones(xdcr_size,1);
        else
                ap_vector = hann(xdcr_size);
        end
    elseif strcmp(apodization, 'triangle')
        if exist('OCTAVE_VERSION')
            warning('Triangle apodization not supported on Octave.');
            ap_vector = ones(xdcr_size,1);
        else
            ap_vector = triang(xdcr_size);
        end
    elseif strcmp(apodization, 'uniform')
        ap_vector = ones(1,xdcr_size);
    else
        error('Unrecognized apodization type. Please check the type and try again.');
    end
    xdcr = set_apodization(xdcr, ap_vector);
else
    if xdcr_size ~= length(apodization)
        error('Apodization vector must be the same size as the transducer array.');
    end
    if isvector(xdcr) % 1-D transducer array
        for i=1:xdcr_size
            xdcr(i).amplitude = apodization(i);
        end
    else % 2-D array
        for i=1:xdcr_size
            for j=1:curved
                xdcr(i,j).amplitude = apodization(i);
            end
        end
    end
end
end