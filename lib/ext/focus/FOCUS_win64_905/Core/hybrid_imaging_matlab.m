function [image_data, outputdata] = hybrid_matlab(transmit_aperture, receive_aperture, scatterers, medium, fs, ndiv, nalines, tx_excitation, rx_excitation)

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
ptx_length = ceil(maxtend*fs);
prx_length = ceil(maxtend*fs);
tx_ele_istart = zeros(tx_elements,Ny_divisions);
rx_ele_istart = zeros(rx_elements,Ny_divisions);
tx_pressures = zeros(tx_elements,Ny_divisions, 0);
rx_pressures = zeros(rx_elements,Ny_divisions, 0);

tx_ele_start = zeros(tx_elements,Ny_divisions);
rx_ele_start = zeros(tx_elements,Ny_divisions);

tx_ele_end = zeros(tx_elements,Ny_divisions);
rx_ele_end = zeros(tx_elements,Ny_divisions);

interp_spacing = 64;%256;
freq_upscale = 8;

for iscat = 1:nscatterers
 point = set_coordinate_grid([0 0 0], scatterers(iscat).x, scatterers(iscat).x, scatterers(iscat).y, scatterers(iscat).y, scatterers(iscat).z, scatterers(iscat).z);
 tx_pressures = zeros(tx_elements,Ny_divisions, 0);
 rx_pressures = zeros(rx_elements,Ny_divisions, 0);


    for j=1:tx_elements
      for k=1:Ny_divisions
       transmit_apeture_temp(j,k).amplitude(1) = 1;
       transmit_apeture_temp(j,k).time_delay(1) = 0;
%        [ttxstart,ttxend] = impulse_begin_and_end_times(transmit_apeture_temp(j,k),point,medium);
%        tx_ele_start(j,k) = ttxstart;
%        tx_ele_end(j,k) = ttxend+tx_excitation.pulse_width;
%        ittxstart=ceil(ttxstart*fs)+1;
%        timestx = set_time_samples(dt,ttxstart,ttxend+tx_excitation.pulse_width);
%        ptx = squeeze(fnm_tsd(transmit_apeture_temp(j,k),point,medium,timestx,ndiv,tx_excitation))';
%        
%        tx_ele_istart(j,k) = ittxstart;
%        ptx_padded = [ 0 0 0 0 ptx 0 0 0 0];
%        ptx_interp_padded = interp1((1:length(ptx_padded)), ptx_padded, (1:(1/interp_spacing):length(ptx_padded)) ,'linear');%pchip
%        
%        ptx_interp_padded_adj_old = ptx_interp_padded(interp_spacing*3:end);
% %        tx_pressures(j,k,1:length(ptx_interp_padded_adj)) = ptx_interp_padded_adj;
       


       %Hybrid method

       fs= fs*freq_upscale;
       dt = 1/fs;
       [ttxstart,ttxend] = impulse_begin_and_end_times(transmit_apeture_temp(j,k),point,medium);
       tx_ele_start(j,k) = ttxstart;
       tx_ele_end(j,k) = ttxend+tx_excitation.pulse_width;
       ittxstart=ceil(ttxstart*fs)+1;
       
       timestx = set_time_samples(dt,ttxstart,ttxend+tx_excitation.pulse_width);
       ptx = squeeze(fnm_tsd(transmit_apeture_temp(j,k),point,medium,timestx,ndiv,tx_excitation))';
       
       tx_ele_istart(j,k) = ittxstart;
       ptx_padded = [ 0 0 0 0 ptx 0 0 0 0];
       ptx_interp_padded = interp1((1:length(ptx_padded)), ptx_padded, (1:(1/interp_spacing):length(ptx_padded)) ,'linear');
       
       ptx_interp_padded_adj = [ zeros(1,interp_spacing) ptx_interp_padded(interp_spacing*4:freq_upscale:end)];
       tx_pressures(j,k,1:length(ptx_interp_padded_adj)) = ptx_interp_padded_adj;
       
       fs= fs/freq_upscale;
       dt = 1/fs;
%        
%        
%         figure(2)
%         plot(ptx_interp_padded)
%         figure(1)
%         plot(ptx_interp_padded_adj_old)
%         hold on 
%         plot(ptx_interp_padded_adj,'--red')
%         hold off
%         pause
       
      end
    end
    for j=1:rx_elements
      for k=1:Ny_divisions
        receive_aperture_temp(j,k).amplitude(1) = 1;
        receive_aperture_temp(j,k).time_delay(1) = 0;
%         [trxstart,trxend] = impulse_begin_and_end_times(receive_aperture_temp(j,k),point,medium);
%         rx_ele_start(j,k) = trxstart;
%         rx_ele_end(j,k) = trxend+rx_excitation.pulse_width;
%         irtxstart=ceil(trxstart*fs)+1;
%         %irxtend=floor((trxend+rx_excitation.pulse_width)*fs)+1;
% %         trxstart=(irtxstart-1)*dt;
% %         trxend=(irxtend-1)*dt;
% %         timesrx = set_time_samples(dt,trxstart,trxend);
% %         prx = squeeze(fnm_tsd(receive_aperture_temp(j,k),point,medium,timesrx,ndiv,rx_excitation))';
%         timesrx = set_time_samples(dt,trxstart,trxend+rx_excitation.pulse_width);
%         prx = squeeze(fnm_tsd(receive_aperture_temp(j,k),point,medium,timesrx,ndiv,rx_excitation))';
% 
%         rx_ele_istart(j,k) = irtxstart;
% 
%         %prx_interp = interp1((1:length(prx)), prx, (1:(1/interp_spacing):length(prx)) ,'pchip');
% 
%        prx_padded = [ 0 0 0 0 prx 0 0 0 0];
%        prx_interp_padded = interp1((1:length(prx_padded)), prx_padded, (1:(1/interp_spacing):length(prx_padded)) ,'spline');
% 
%        prx_interp_padded_adj = prx_interp_padded(interp_spacing*3:end);
%        rx_pressures(j,k,1:length(prx_interp_padded_adj)) = prx_interp_padded_adj;

        fs= fs*freq_upscale;
        dt = 1/fs;
        [trxstart,trxend] = impulse_begin_and_end_times(receive_aperture_temp(j,k),point,medium);
        rx_ele_start(j,k) = trxstart;
        rx_ele_end(j,k) = trxend+rx_excitation.pulse_width;
        irtxstart=ceil(trxstart*fs)+1;
        timesrx = set_time_samples(dt,trxstart,trxend+rx_excitation.pulse_width);
        prx = squeeze(fnm_tsd(receive_aperture_temp(j,k),point,medium,timesrx,ndiv,rx_excitation))';
        rx_ele_istart(j,k) = irtxstart;
        prx_padded = [ 0 0 0 0 prx 0 0 0 0];
%         prx_interp_padded = interp1((1:length(prx_padded)), prx_padded, (1:(1/interp_spacing):length(prx_padded)) ,'spline');
%         prx_interp_padded_adj = prx_interp_padded(1:4:end);
%         rx_pressures(j,k,1:length(prx_interp_padded_adj)) = prx_interp_padded_adj;
        prx_interp_padded = interp1((1:length(prx_padded)), prx_padded, (1:(1/interp_spacing):length(prx_padded)) ,'linear');
        prx_interp_padded_adj = [ zeros(1,interp_spacing) prx_interp_padded(interp_spacing*4:freq_upscale:end) ];
        rx_pressures(j,k,1:length(prx_interp_padded_adj)) = prx_interp_padded_adj;
        fs= fs/freq_upscale;
        dt = 1/fs;

      end
    end

	for ialines=1:nalines
        sum_ptx_el = zeros(1,ptx_length);
        sum_prx_el = zeros(1,prx_length);

           for j=1:tx_elements
                for k=1:Ny_divisions
                    if transmit_aperture(j,k).amplitude(ialines) > 0
                        %fnm
%                        transmit_apeture_temp(j,k).amplitude(1) = transmit_aperture(j,k).amplitude(ialines) ;
%                        transmit_apeture_temp(j,k).time_delay(1) = transmit_aperture(j,k).time_delay(ialines);
%                        [ttxstart,ttxend] = impulse_begin_and_end_times(transmit_apeture_temp(j,k),point,medium);
%                        % align times to samples
%                        ittxstart=ceil(ttxstart*fs)+1;
%                        itxtend=floor((ttxend+tx_excitation.pulse_width)*fs)+1;
%                        ttxstart=(ittxstart-1)*dt;
%                        ttxend=(itxtend-1)*dt;
% 
%                        timestx = set_time_samples(dt,ttxstart,ttxend);
%                        ptx2 = squeeze(fnm_tsd(transmit_apeture_temp(j,k),point,medium,timestx,ndiv,tx_excitation))';
%     %                    tend = (ittxstart+length(ptx)-1);
%     %                    sum_ptx_el(ittxstart:tend) = sum_ptx_el(ittxstart:tend) + ptx;
%                        fnmstart =ittxstart;
                       %figure(1)
                       %plot(ptx2)
                   %for test = 1:interp_spacing*2-1
                       %round(tx_ele_istart(j,k) + transmit_aperture(j,k).time_delay(ialines)*fs)
                       %ceil((tx_ele_start(j,k) + transmit_aperture(j,k).time_delay(ialines))*fs)+1
                       %(tx_ele_start(j,k) + transmit_aperture(j,k).time_delay(ialines))*fs - rx_ele_istart(j,k)
                       %offset = (tx_ele_start(j,k) + transmit_aperture(j,k).time_delay(ialines))*fs - rx_ele_istart(j,k);
                       %offset = offset - floor(offset)

                       %interp_spacing*2 - interp_spacing*2*offset

                       %(tx_ele_start(j,k) - (tx_ele_istart(j,k)-1)*dt)*fs
                       % tx_ele_start(j,k)*fs - floor(tx_ele_start(j,k)*fs)


                       %round(tx_ele_istart(j,k) + transmit_aperture(j,k).time_delay(ialines)*fs)
                       %ceil((tx_ele_start(j,k) + transmit_aperture(j,k).time_delay(ialines))*fs)+1

                       %(tx_ele_istart(j,k) + transmit_aperture(j,k).time_delay(ialines)*fs) - ceil((tx_ele_start(j,k) + transmit_aperture(j,k).time_delay(ialines))*fs)+1


%                        offset = (tx_ele_istart(j,k) + transmit_aperture(j,k).time_delay(ialines)*fs) - ceil((tx_ele_start(j,k) + transmit_aperture(j,k).time_delay(ialines))*fs)+1;
%                        offset = offset -1;
%                        offset = round(interp_spacing*2 - offset*interp_spacing)+1;
% 
                        
%     %                    test
%                     
%                     figure(2)
                     %for test = 1:interp_spacing*2-1
                       offset = ((tx_ele_start(j,k) + transmit_aperture(j,k).time_delay(ialines))*fs) - floor((tx_ele_start(j,k) + transmit_aperture(j,k).time_delay(ialines))*fs);
                       offset = round((interp_spacing - offset*interp_spacing)+interp_spacing);
                       %tx_ele_start(j,k)*fs - floor((tx_ele_start(j,k) + transmit_aperture(j,k).time_delay(ialines))*fs)%+1
                       %round(tx_ele_istart(j,k) + transmit_aperture(j,k).time_delay(ialines)*fs) - ceil((tx_ele_start(j,k) + transmit_aperture(j,k).time_delay(ialines))*fs)+1
                       %ttxstart=(ittxstart-1)*dt - 
                       
                       %tx_ele_istart(j,k) + transmit_aperture(j,k).time_delay(ialines)*fs - ceil((tx_ele_start(j,k) + transmit_aperture(j,k).time_delay(ialines))*fs)+1
                       %(tx_ele_istart(j,k) + transmit_aperture(j,k).time_delay(ialines)*fs) - ceil((tx_ele_start(j,k) + transmit_aperture(j,k).time_delay(ialines))*fs)+1
                       %((tx_ele_istart(j,k)-1)*dt - tx_ele_start(j,k))*fs + transmit_aperture(j,k).time_delay(ialines)*fs - floor(transmit_aperture(j,k).time_delay(ialines)*fs)
                       
                       
                    % end
%                        ptx4 = squeeze(tx_pressures(j,k,(offset+1:interp_spacing:end)))'*transmit_aperture(j,k).amplitude(ialines);
%                        plot(ptx4,'--blue')
%                        ptx5 = squeeze(tx_pressures(j,k,(offset-1:interp_spacing:end)))'*transmit_aperture(j,k).amplitude(ialines);
%                        plot(ptx5,'--red')
                       
    %                    %figure(3)
    %                    %plot(ptx2(1:length(ptx2))-ptx(1:length(ptx2)))
                       
    %                    end

                        %ittxstart =  round(tx_ele_istart(j,k) + transmit_aperture(j,k).time_delay(ialines)*fs);
                        %ittxstart=ceil(tx_ele_start(j,k)*fs)+1;
                        
                        
                         ittxstart =  ceil((tx_ele_start(j,k) + transmit_aperture(j,k).time_delay(ialines))*fs)+1;
                         pressure_length = ceil((tx_ele_end(j,k)+transmit_aperture(j,k).time_delay(ialines))*fs - ittxstart)+1;
                         if (offset == interp_spacing)
                             offset= interp_spacing +1;
                         end
                        
                         ptx = squeeze(tx_pressures(j,k,(offset:interp_spacing:((pressure_length+1)*interp_spacing))))'*transmit_aperture(j,k).amplitude(ialines);
% 
%                          figure(1)
%                          plot(ptx2)
%                          hold on
%                          plot(ptx,'--red')
%                          hold off
%                          %figure(2)
%                          %plot(ptx2-ptx)
%                          error = max(abs(ptx2-ptx))/max(abs(ptx2))
%                          pause


                        tend = (ittxstart+length(ptx)-1);
                        %sum_ptx_el(ittxstart:tend) = sum_ptx_el(ittxstart:tend) + ptx*transmit_aperture(j,k).amplitude(ialines);
                        sum_ptx_el(ittxstart:tend) = sum_ptx_el(ittxstart:tend) + ptx;
                    end
                end
           end

           for j=1:rx_elements
                for k=1:Ny_divisions
                    if receive_aperture(j,k).amplitude(ialines) > 0
                        % fnm
%                         receive_aperture_temp(j,k).amplitude(1) = receive_aperture(j).amplitude(ialines);
%                         receive_aperture_temp(j,k).time_delay(1) = receive_aperture(j).time_delay(ialines);
%                        [trxstart,trxend] = impulse_begin_and_end_times(receive_aperture_temp(j,k),point,medium);
%                        irtxstart=ceil(trxstart*fs)+1;
%                        irxtend=floor((trxend+rx_excitation.pulse_width)*fs)+1;
%                        trxstart=(irtxstart-1)*dt;
%                        trxend=(irxtend-1)*dt;
%                        timesrx2 = set_time_samples(dt,trxstart,trxend);
%                        prx2 = squeeze(fnm_tsd(receive_aperture_temp(j,k),point,medium,timesrx2,ndiv,rx_excitation))';
                       %fnmstart =ittxstart;
    %                    tend = (irtxstart+length(prx)-1);
    %                    sum_prx_el(irtxstart:tend) = sum_prx_el(irtxstart:tend) + prx;

                        %prx = squeeze(rx_pressures(j,k,1:end))';
%                         offset = (rx_ele_istart(j,k) + receive_aperture(j,k).time_delay(ialines)*fs) - ceil((rx_ele_start(j,k) + receive_aperture(j,k).time_delay(ialines))*fs)+1;
%                         offset = offset -1;
%                         offset = round(interp_spacing*2 - offset*interp_spacing)+1;
                       offset = ((rx_ele_start(j,k) + receive_aperture(j,k).time_delay(ialines))*fs) - floor((rx_ele_start(j,k) + receive_aperture(j,k).time_delay(ialines))*fs);
                       offset = round((interp_spacing - offset*interp_spacing)+interp_spacing);
                       
                       if (offset == interp_spacing)
                             offset= interp_spacing +1;
                       end
                         
                       %sums data
                        irtxstart =  ceil((rx_ele_start(j,k) + receive_aperture(j,k).time_delay(ialines))*fs)+1;
                         pressure_length = ceil((rx_ele_end(j,k)+receive_aperture(j,k).time_delay(ialines))*fs - irtxstart)+1;
                         prx = squeeze(rx_pressures(j,k,(offset:interp_spacing:((pressure_length+1)*interp_spacing))))'*receive_aperture(j,k).amplitude(ialines);
                       
                        % need to figure out timedelay
                        
                        %irtxstart =  round(rx_ele_istart(j,k) + receive_aperture(j,k).time_delay(ialines)*fs);
                        tend = (irtxstart+length(prx)-1);
                        %sum_prx_el(irtxstart:tend) = sum_prx_el(irtxstart:tend) + prx*receive_aperture(j,k).amplitude(ialines);
                        sum_prx_el(irtxstart:tend) = sum_prx_el(irtxstart:tend) + prx;%*receive_aperture(j,k).amplitude(ialines);
                    end
                end
           end

           if(ialines ==49)
               outputdata= sum_ptx_el;
           end

           itstart = 1;%irtxstart+ittxstart-1;
           itend = itstart+length(sum_ptx_el)+length(sum_prx_el)-2;%itstart+length(ptx)+length(prx)-2;

           result = fftconv(sum_ptx_el, sum_prx_el)* scatterers(iscat).amplitude * scale_factor*dt / (medium.density)^2;

           if size(result) ~= size(image_data(itstart:itend,ialines))
                result = result';
           end

           image_data(itstart:itend,ialines) = image_data(itstart:itend,ialines) + result;
	end
end
end
