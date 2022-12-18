function image_data = fnm_imaging_matlab(transmit_aperture, receive_aperture, scatterers, medium, fs, ndiv, nalines,tx_excitation, rx_excitation)
% Usage
% image_data = fnm_imaging_matlab(transmit_aperture, receive_aperture, scatterers, medium, fs, ndiv, nalines, tx_excitation, rx_excitation); 
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

nscatterers = length(scatterers);

transmit_apeture_temp = transmit_aperture;
receive_aperture_temp = receive_aperture;

tx_elements = length(transmit_aperture);
rx_elements = length(receive_aperture);

Ny_divisions=size(transmit_aperture,2);

maxtend = 0; maxttxend=0; maxtrxend=0;

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

dt = 1/fs;
scale_factor = (dt*medium.density)^2;

%image_data=zeros(1,ceil(maxtend*fs));
image_data=zeros(ceil(maxtend*fs)*2,nalines);

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
       [ttxstart,ttxend] = impulse_begin_and_end_times(transmit_apeture_temp,point,medium);
       [trxstart,trxend] = impulse_begin_and_end_times(receive_aperture_temp,point,medium);

       % align times to samples
       ittxstart=ceil(ttxstart*fs)+1;
       irtxstart=ceil(trxstart*fs)+1;
       itxtend=floor((ttxend+tx_excitation.pulse_width)*fs)+1;
       irxtend=floor((trxend+rx_excitation.pulse_width)*fs)+1;

       ttxstart=(ittxstart-1)*dt;
       trxstart=(irtxstart-1)*dt;
       ttxend=(itxtend-1)*dt;
       trxend=(irxtend-1)*dt;

       timestx = set_time_samples(dt,ttxstart,ttxend);
       timesrx = set_time_samples(dt,trxstart,trxend);

       ptx = squeeze(fnm_tsd(transmit_apeture_temp,point,medium,timestx,ndiv,tx_excitation))';
       prx = squeeze(fnm_tsd(receive_aperture_temp,point,medium,timesrx,ndiv,rx_excitation))';
       
       itstart = irtxstart+ittxstart-1;
       itend = itstart+length(ptx)+length(prx)-2;

       result = fftconv(ptx, prx)* scatterers(iscat).amplitude * scale_factor*dt / (medium.density)^2;

       if size(result) ~= size(image_data(itstart:itend,ialines))
            result = result';
       end

       image_data(itstart:itend,ialines) = image_data(itstart:itend,ialines) + result;
    end
end
end
