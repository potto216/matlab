function image_data = calc_bmode_data(transmit_aperture, receive_aperture, scatterers, medium, fs, ndiv, nalines, tx_excitation, rx_excitation, method)
% Description
%     Calculates B-mode data using one of the image simulation methods.
% Usage
%     image_data = calc_bmode_data(transmit_aperture, receive_aperture,
%     scatterers, medium, fs, ndiv, nalines, tx_excitation, rx_excitation, method)
% Arguments
%     transmit_aperture: A FOCUS transducer array for the transmit aperture.
%     receive_aperture: A FOCUS transducer array for the receive aperture.
%     scatterers: An array of scatters as created by get_scatterer.
%     medium: A medium struct like the ones created by set_medium.
%     fs: The frequency used to calculate the B-mode data.
%     ndiv: The number of integral points to use.
%     nalines: The number of A-lines.
%     tx_excitation: An excitation function for the transmit aperture as created by set_excitation_function.
%     rx_excitation: An excitation function for the transmit aperture as created by set_excitation_function.
%     method: The simulation method. Options are:
%       'impulse response': Uses the Matlab Impulse Response Imaging routine
%       'impulse response c': Uses the MEX Impulse Response Imaging routine
%       'fnm': Uses the Matlab FNM Imaging routine
%       'fnm c': Uses the MEX FNM Imaging routine
%       'hybrid c': Uses the MEX Hybrid Imaging routine
% Output Parameters
%     image_data: The B-mode data.
% Notes
%     "hybrid c" is the fastest option and will generate accurate images at 16MHz, "impulse response" requires a sample frequency of at least 1GHz to be accurate.

if(nargin ~= 10)
    error('image_data = calc_bmode_data(transmit_aperture, receive_aperture, scatterers, medium, fs, ndiv, nalines, tx_excitation, rx_excitation, method ');
end

if strfind(method,'hybrid')
    if strfind(method, 'c')
        image_data = hybrid_imaging(transmit_aperture, receive_aperture, scatterers, medium, fs, ndiv, nalines, tx_excitation, rx_excitation);
    else
        error('This image simulation method is not currently supported.');
        %image_data = hybrid_imaging_matlab(transmit_aperture, receive_aperture, scatterers, medium, fs, ndiv, nalines, tx_excitation, rx_excitation);
    end
elseif strfind(method,'fnm')
    if strfind(method,'c')
        image_data = fnm_imaging(transmit_aperture, receive_aperture, scatterers, medium, fs, ndiv, nalines, tx_excitation, rx_excitation);
    else
        image_data = fnm_imaging_matlab(transmit_aperture, receive_aperture, scatterers, medium, fs, ndiv, nalines, tx_excitation, rx_excitation);
    end
elseif strfind(method,'impulse response')
    if strfind(method,'c')
        image_data = impulse_imaging(transmit_aperture, receive_aperture, scatterers, medium, fs, ndiv, nalines, tx_excitation, rx_excitation);
    else
        image_data = impulse_imaging_matlab(transmit_aperture, receive_aperture, scatterers, medium, fs, ndiv, nalines, tx_excitation, rx_excitation);
    end
else
    error('Unrecognized image simulation method.');
end

image_data=image_data*fs*fs;
