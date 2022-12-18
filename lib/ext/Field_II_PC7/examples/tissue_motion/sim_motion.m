%  Example of use of the Field II program running under Matlab.
%
%  This example shows how to generate rf signals for the carotid artery. 
%  The position of the scatterers are determined by the blood flow, breathing
%  and pulsation - thereby the motion in the surrounding tissue is incorporated.
%
%
%  This script assumes that the field_init procedure has been called
%  Here the field simulation is performed and the data is stored
%  in rf-files; one for each rf-line done. The data for the
%  scatteres are read from the file XXXXX.mat, so that the procedure
%  can be started again or run for a number of workstations.
%
%  Example by Malene Schlaikjer and Joergen Arendt Jensen, January 15, 1999.
%

%  Generate the transducer apertures for send and receive

f0=3.75e6;               %  Transducer center frequency [Hz]
M=8;                     %  Number of cycles in emitted pulse
fs=105e6;                %  Sampling frequency [Hz]
c=1540;                  %  Speed of sound [m/s]
lambda=c/f0;             %  Wavelength [m]
element_height=15/1000;  %  Height of element [m]
kerf=0.03/1000;          %  Kerf [m]
width=0.4/1000-kerf;     %  Width equals pitch-kerf
Rconvex=20/1000;         %  Transducer curvature properties
Rfocus=60/1000;          %  Transducer curvature properties
focus=[0 0 40]/1000;     %  Fixed focal point [m]
N_elements=60;           %  Number of physical elements
fprf=3.5e3;
Nshoots=fprf;            %  Number of shots




% Do not use triangles

set_field('use_triangles',0);

%  Set the sampling frequency

set_sampling(fs);

%  Generate aperture for emission

emit_aperture = xdc_convex_focused_array (N_elements, width, element_height,...
kerf,Rconvex, Rfocus, 1, 15, focus); 

%  Set the impulse response and excitation of the emit aperture

impulse_response=sin(2*pi*f0*(0:1/fs:4/f0));
impulse_response=impulse_response.*hanning(max(size(impulse_response)))';
xdc_impulse (emit_aperture, impulse_response);

excitation=sin(2*pi*f0*(0:1/fs:M/f0));
xdc_excitation (emit_aperture, excitation);

%  Generate aperture for reception

receive_aperture = xdc_convex_focused_array (N_elements, width, element_height, kerf,...
Rconvex, Rfocus, 1, 15, focus);

%  Set the impulse response for the receive aperture

xdc_impulse (receive_aperture, impulse_response);

%  Set a Hanning apodization on the apertures

apo=hanning(N_elements)';
xdc_apodization (emit_aperture, 0, apo);
xdc_apodization (receive_aperture, 0, apo);

%  Set receive and transmit focus

xdc_focus(emit_aperture, 0, focus);
xdc_focus(receive_aperture, 0, focus);

%  Calculate scatter signal for all positions
i=1;
lines_done=0;
while (lines_done<200) & (i<=Nshoots)

  %  Check if the file already exits
  
  file_name = ['RFdata/rfMW_ln',num2str(i),'.mat'];
  cmd=['fid = fopen(file_name,''r'');'];
  eval(cmd);
  
  %  Do the processing if the file does not exit
   
  if (fid == -1)
    cmd=['save RFdata/rfMW_ln',num2str(i),'.mat i']
    eval(cmd);
     
    %   Load the data

    cmd = ['load Position/pos_simMW',num2str(i),'.mat']
    eval(cmd)

      
    %   Calculate the received response
    
    [rf_data, tstart]=calc_scat(emit_aperture, receive_aperture, positions,...
    ampNow);

    %  Store the result and perform decimation (down to fs=15 MHz - equal to a
    %  factor of 7);
    
    
    rf_data15=rf_data(1:7:length(rf_data));
    cmd=['save RFdata/rfMW_ln',num2str(i),'.mat rf_data15 tstart']


    eval(cmd)
    lines_done=lines_done+1;
  else
    fclose (fid);
    end
  i=i+1;
  end

%   Free space for apertures

xdc_free (emit_aperture)
xdc_free (receive_aperture)
field_end

%  Write the stop file if all simulations has been done

if (i>=Nshoots)
  save stop.mat i
  end

  
