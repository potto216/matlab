%  Example of use of the new Field II program running under Matlab
%
%  This example shows how a phased array B-mode system scans an image
%
%  This script assumes that the field_init procedure has been called
%  Here the field simulation is performed and the data is stored
%  in rf-files; one for each rf-line done. The data must then
%  subsequently be processed to yield the image. The data for the
%  scatteres are read from the file pht_data.mat, so that the procedure
%  can be started again or run for a number of workstations.
%
%  Example by Joergen Arendt Jensen and Peter Munk, March 18, 1997.

%  Generate the transducer apertures for send and receive

f0=5e6;                  %  Transducer center frequency [Hz]
fs=100e6;                %  Sampling frequency [Hz]
c=1540;                  %  Speed of sound [m/s]
lambda=c/f0;             %  Wavelength [m]
width=lambda/2;          %  Width of element
element_height=7/1000;   %  Height of element [m]
kerf=0.0025/1000;        %  Kerf [m]
focus=[0 0 70]/1000;     %  Fixed focal point [m]
N_elements=64;           %  Number of physical elements

% Use triangles

set_field('use_triangles',0);

%  Set the sampling frequency

set_sampling(fs);

%  Generate aperture for emission

xmit_aperture = xdc_linear_array (N_elements, width, element_height, kerf, 1, 4, focus);

%  Set the impulse response and excitation of the xmit aperture

impulse_response=sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response=impulse_response.*hanning(max(size(impulse_response)))';
xdc_impulse (xmit_aperture, impulse_response);

excitation=sin(2*pi*f0*(0:1/fs:1/f0));
xdc_excitation (xmit_aperture, excitation);

%  Generate aperture for reception

receive_aperture = xdc_linear_array (N_elements, width, element_height, kerf, 1, 4, focus);

%  Set the impulse response for the receive aperture

xdc_impulse (receive_aperture, impulse_response);

%   Load the computer phantom

load pht_data

%   Do linear array imaging

no_lines=128;                   %  Number of lines in image
d_theta=0.7/180*pi;             %  Angle increment

%  Set the different focal zones for reception

z_rec_zones=[40:10:140]'/1000;
focus_times=(z_rec_zones-5/1000)/c;

%  Set Hanning apodization on the apertures

apo=hanning(N_elements)';
xdc_apodization (xmit_aperture, 0, apo);
xdc_apodization (receive_aperture, 0, apo);

%  Transmit focus

z_focus=70/1000;   

% Do imaging line by line

i_start=63;
theta= -no_lines/2*d_theta + (i_start-1)*d_theta;

for i=i_start:no_lines
i
  %   Set the focus for this direction

  xdc_focus (xmit_aperture, 0, [z_focus*sin(theta) 0 z_focus*cos(theta)]);
  xdc_focus (receive_aperture, focus_times, [z_rec_zones*sin(theta) zeros(max(size(z_rec_zones)),1) z_rec_zones*cos(theta)]);

  %   Calculate the received response

  [rf_data, tstart]=calc_scat(xmit_aperture, receive_aperture, phantom_positions, phantom_amplitudes);

  %  Store the result

  cmd=['save sim_feu/rf_ln',num2str(i),'.mat rf_data tstart']
  eval(cmd)

  %  Steer in another direction

  theta=theta+d_theta;
  end

%   Free space for apertures

xdc_free (xmit_aperture)
xdc_free (receive_aperture)

