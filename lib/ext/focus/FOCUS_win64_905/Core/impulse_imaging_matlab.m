function image_data = impulse_imaging_matlab(transmit_aperture, receive_aperture, scatterers, medium, fs, ndiv, nalines, tx_excitation, rx_excitation)
% Usage
% image_data = impulse_imaging_matlab(transmit_aperture, receive_aperture, scatterers, medium, fs, ndiv, nalines, tx_excitation, rx_excitation); 
% 
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
% Output Parameters
%     image_data: The B-mode data.

transmit_apeture_temp = transmit_aperture;
receive_aperture_temp = receive_aperture;

tx_elements = length(transmit_aperture);
rx_elements = length(receive_aperture);

Ny_divisions=size(transmit_aperture,2);

maxtend = 0; maxttxend=0; maxtrxend=0;

dt = 1/fs;

% Calculate the derivatives of the excitation functions
% Transmit
f0 = tx_excitation.f0;
w = tx_excitation.pulse_width;
b = tx_excitation.B;

time = 0:dt:w;
% Calculate function value at each time point
tx_excitation_prime = zeros(size(time));
for i = 1:length(time)
    t = time(i);
    % Tone burst
    if tx_excitation.type == 1
        tx_excitation_prime(i) = 2*pi*f0*cos(2*pi*f0*t);
    % Hanning-weighted pulse
    elseif tx_excitation.type == 2
        tx_excitation_prime(i) = 0.5*(((2*pi/w)*sin(2*pi*t/w))*sin(2*pi*f0*t) + (1-cos(2*pi*t/w))*(2*pi*f0)*cos(2*pi*f0*t));
    % T-cubed pulse
    elseif tx_excitation.type == 3
        tx_excitation_prime(i) = ((3*t^2)*exp(-b*t) + (t^3)*(-b*exp(-b*t)))*sin(2*pi*f0*t) + ((t^3)*exp(-b*t))*(2*pi*f0)*cos(2*pi*f0*t);
    else
        error('Invalid excitation function type.');
    end
end


% Receive
f0 = rx_excitation.f0;
w = rx_excitation.pulse_width;
b = rx_excitation.B;

time = 0:dt:w;
% Calculate function value at each time point
rx_excitation_prime = zeros(size(time));
for i = 1:length(time)
    t = time(i);
    % Tone burst
    if rx_excitation.type == 1
        rx_excitation_prime(i) = 2*pi*f0*cos(2*pi*f0*t);
    % Hanning-weighted pulse
    elseif rx_excitation.type == 2
        rx_excitation_prime(i) = 0.5*(((2*pi/w)*sin(2*pi*t/w))*sin(2*pi*f0*t) + (1-cos(2*pi*t/w))*(2*pi*f0)*cos(2*pi*f0*t));
    % T-cubed pulse
    elseif rx_excitation.type == 3
        rx_excitation_prime(i) = ((3*t^2)*exp(-b*t) + (t^3)*(-b*exp(-b*t)))*sin(2*pi*f0*t) + ((t^3)*exp(-b*t))*(2*pi*f0)*cos(2*pi*f0*t);
    else
        error('Invalid excitation function type.');
    end
end

conv_vprime = fftconv(tx_excitation_prime,rx_excitation_prime)*dt;


nscatterers = length(scatterers);

  for iscat = 1:nscatterers
   point = set_coordinate_grid([0 0 0], scatterers(iscat).x, scatterers(iscat).x, scatterers(iscat).y, scatterers(iscat).y, scatterers(iscat).z, scatterers(iscat).z);     
    for j=1:tx_elements
     for k=1:Ny_divisions
        [~,ttxend] = impulse_begin_and_end_times(transmit_apeture_temp(j,k),point,medium);
        maxttxend = max(maxttxend,ttxend + tx_excitation.pulse_width);
     end 
    end
    for j=1:rx_elements
      for k=1:Ny_divisions
        [~,trxend] = impulse_begin_and_end_times(receive_aperture_temp(j,k),point,medium);
        maxtrxend = max(maxtrxend,trxend + rx_excitation.pulse_width);
      end
    end
    maxtend = max(maxtend, maxttxend + maxtrxend);   
  end
  tendmax = maxtend;

image_data=zeros(ceil(tendmax*fs)*2,nalines);


scale_factor = dt^4*medium.density^2;

for ialines=1:nalines
    
    for j=1:tx_elements
      for k=1:Ny_divisions
       transmit_apeture_temp(j,k).amplitude(1) = transmit_aperture(j,k).amplitude(ialines) ;
       transmit_apeture_temp(j,k).time_delay(1) = transmit_aperture(j,k).time_delay(ialines);
      end
    end
    for j=1:rx_elements
      for k=1:Ny_divisions
         receive_aperture_temp(j,k).amplitude(1) = receive_aperture(j,k).amplitude(ialines);
         receive_aperture_temp(j,k).time_delay(1) = receive_aperture(j,k).time_delay(ialines);
      end
    end

    
    for iscat = 1:nscatterers
        point = set_coordinate_grid([0 0 0], scatterers(iscat).x, scatterers(iscat).x, scatterers(iscat).y, scatterers(iscat).y, scatterers(iscat).z, scatterers(iscat).z);
        [ttxstart, ttxend] = impulse_begin_and_end_times(transmit_apeture_temp, point, medium);
        [trxstart, trxend] = impulse_begin_and_end_times(receive_aperture_temp, point, medium);

        ttxstart=ceil(ttxstart*fs)*dt;
        trxstart=ceil(trxstart*fs)*dt;
        ttxend=floor(ttxend*fs)*dt;
        trxend=floor(trxend*fs)*dt;

        time_samples = set_time_samples(dt, ttxstart, ttxend);    
        ht = squeeze(impulse_response(transmit_apeture_temp, point, medium, time_samples));
        time_samples = set_time_samples(dt, trxstart, trxend);
        hr = squeeze(impulse_response(receive_aperture_temp, point, medium, time_samples));

        istart = round((ttxstart+trxstart)*fs)+1; 
        
        result = fftconv(scatterers(iscat).amplitude*scale_factor*fftconv(ht,hr), conv_vprime );
        
        iend = istart+length(result)-1;

        if size(result) ~= size(image_data(istart:iend,ialines))
            result = result';
        end

        image_data(istart:iend,ialines) = image_data(istart:iend,ialines) + result;
        
        
        
    end
end

end
