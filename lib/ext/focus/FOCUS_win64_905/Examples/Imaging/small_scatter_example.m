%Simulations to run (0=off, 1=on)
run_reference_simulation = 1;
run_focus_simulation = 1;

%plot B-mode Images after simulations (0=off, 1=on)
display_plot = 1;



%Number of scatters to run the simulations with
Nscatter = 100;

%frequency to generate reference
fs_reference = 1e9;

%frequency to generate the FOCUS image at
fs = 16e6;

%  Transducer center frequency [Hz]
f0=3e6;
% Set the excitation signal
excitation = set_excitation_function(1,f0,1/f0,0);


% set the medium
medium = set_medium('soundspeed',1540,'density',1000);

lambda=medium.soundspeed/f0;  %  Wavelength [m]

%settup transducer parameters
width = lambda;               %  Width of element
element_height=5/1000;        %  Height of element [m]
kerf=0.1/1000;                %  Kerf [m]

z_focus=30/1000;          %  Transmit focus

N_elements=192;
N_active=24;             %  Number of active elements
r_curv = 30e-3;
N_alines = 129;    % Number of A-lines
image_width=128*(width+kerf);
d_x=image_width/(N_alines-1);
xalines=-image_width/2:d_x:image_width/2;

% set Windowing for active elements
% apo=ones(1,N_active);
apo=hanning(N_active)';


% FOCUS parameters
nx = N_elements;          %  Number of elements
nactive_elements = N_active;
ny = 1;

%Number of Gaussian quadratures needed to reach arbitrary tolerance
ndiv = 6;

% Create a Curved Array
% N_divisions_y=5;
% xdcr = create_rect_curved_strip_array(N_elements, N_divisions_y, width, element_height, kerf, r_curv);
% %  Generate aperture for transmit
% emit_aperture_focus = create_rect_curved_strip_array(N_elements, N_divisions_y, width, element_height, kerf, r_curv);
% %  Generate aperture for reception
% receive_aperture_focus = create_rect_curved_strip_array(N_elements, N_divisions_y, width, element_height, kerf, r_curv);


%Create a Planar Array
N_divisions_y=1;
xdcr = create_rect_planar_array(nx, ny, width, element_height, kerf, kerf);
%  Generate aperture for transmit
emit_aperture_focus = create_rect_planar_array(nx, ny, width, element_height, kerf, 0);
%  Generate aperture for reception
receive_aperture_focus = create_rect_planar_array(nx, ny, width, element_height, kerf, 0);


xelement_centers = zeros(nx, ny);
for ix = 1:nx,
    xelement_centers(ix) = xdcr(ix).center(1);
end

if exist([num2str(Nscatter) '_scatters.mat'], 'file')
    fprintf('%i_scatters.mat already exsists\n', Nscatter);
else
    [phantom_positions, phantom_amplitudes] = cyst_phantom(Nscatter);
    save([num2str(Nscatter) '_scatters.mat'],'phantom_positions','phantom_amplitudes','Nscatter','-v7.3');
end

load([ num2str(Nscatter) '_scatters']);

for iscat = 1:Nscatter
    scatterers(iscat) = get_scatterer(phantom_positions(iscat,1),phantom_positions(iscat,2),phantom_positions(iscat,3),phantom_amplitudes(iscat));
end


emit = emit_aperture_focus;
receive = receive_aperture_focus;
 
% Setup time delays
 for i = 1:N_alines
   % Calculate time delays and apodization
   icenter=find(xelement_centers>=xalines(i),1);
   iaperture=(icenter-floor(nactive_elements/2)):(icenter+ceil(nactive_elements/2-1));
   N_pre  = (icenter-floor(nactive_elements/2))-1;
   N_post = N_elements - N_pre - N_active;
   apo_vector = [zeros(1,N_pre) apo zeros(1,N_post)];

   emit = set_apodization(emit, apo_vector);
   receive = set_apodization(receive, apo_vector);
   emit = set_time_delay_centers(emit, xalines(i), 0, z_focus, medium,[xalines(i),0,0]);
   receive = set_time_delay_centers(receive, xalines(i), 0, z_focus, medium,[xalines(i),0,0]);
   
   % Copy the amplitude and time delay values into the array structures

    for j=1:nx
        for k=1:N_divisions_y
            emit_aperture_focus(j,k).amplitude(i) = apo_vector(j);
            receive_aperture_focus(j,k).amplitude(i) = apo_vector(j);
            if ~isempty(emit(j,k).time_delay)
                emit_aperture_focus(j,k).time_delay(i) = emit(j).time_delay;
            end
           if ~isempty(receive(j).time_delay)
                receive_aperture_focus(j,k).time_delay(i) = receive(j).time_delay;
            end

         end
    end
    
 end

%Calculate the Reference
if run_reference_simulation
if exist([ num2str(Nscatter) '_impulse_ref_' num2str(fs_reference/1e6) 'MHz.mat'], 'file')
    fprintf('Reference data already exsists\n');
else
    fprintf('Creating Reference B-mode data\n');
    tic;
    impulse_data = calc_bmode_data(emit_aperture_focus, receive_aperture_focus, scatterers, medium, fs_reference, ndiv, N_alines, excitation, excitation, 'impulse response');
    %impulse_data = calc_bmode_data(emit_aperture_focus, receive_aperture_focus, scatterers, medium, fs_reference, ndiv, N_alines, excitation, excitation, 'impulse response c');
    time_to_calc_impulse = toc;
    save([ num2str(Nscatter) '_impulse_ref_' num2str(fs_reference/1e6) 'MHz'],'impulse_data','Nscatter','phantom_positions','xalines','phantom_amplitudes','fs_reference','time_to_calc_impulse','-v7.3');
    clear impulse_data;
end
end

%Calculate the B-mode data with FOCUS
if run_focus_simulation
if exist([ num2str(Nscatter) '_focus_image_' num2str(fs/1e6) 'MHz.mat'], 'file')
    fprintf('FOCUS data already exsists\n');
else
    fprintf('Creating FOCUS B-mode data\n');
    tic;
    image_data = calc_bmode_data(emit_aperture_focus, receive_aperture_focus, scatterers, medium, fs, ndiv, N_alines, excitation, excitation, 'hybrid c');
    %image_data = calc_bmode_data(emit_aperture_focus, receive_aperture_focus, scatterers, medium, fs, ndiv, N_alines, excitation, excitation, 'fnm c');
    %image_data = calc_bmode_data(emit_aperture_focus, receive_aperture_focus, scatterers, medium, fs, ndiv, N_alines, excitation, excitation, 'fnm');
    time_to_calc_image = toc;
    save([ num2str(Nscatter) '_focus_image_' num2str(fs/1e6) 'MHz'],'image_data','Nscatter','phantom_positions','xalines','phantom_amplitudes','fs','time_to_calc_image','-v7.3');
    clear image_data;
end
end

image_data=0;
impulse_data=0;

if run_reference_simulation
load([ num2str(Nscatter) '_impulse_ref_' num2str(fs_reference/1e6) 'MHz']);
fprintf('\nReference calculation took %f seconds\n', time_to_calc_impulse);
end

if run_focus_simulation
load([ num2str(Nscatter) '_focus_image_' num2str(fs/1e6) 'MHz']);
fprintf('calculation took %f seconds\n\n', time_to_calc_image);
end

if run_focus_simulation && run_reference_simulation
fprintf('RMS error of FOCUS compared to Reference = %f %%\n', calc_norm_error(impulse_data, image_data, fs_reference, fs)*100 );
fprintf('PEAK error of FOCUS compared to Reference = %f %%\n\n', calc_peak_error(impulse_data, image_data, fs_reference, fs)*100);
end 

if display_plot
    window = 60;
    level = -20;

    zmin=79.5e-3;
    zmax=zmin+60e-3;

    Ninterp=5;
    Ndec=25;
    zshift=79.5e-3;
    maxx=20e-3;

    maxamp = max(max(max(image_data)),max(max(impulse_data)));
    imaxamp = 1/maxamp;
    image_data = image_data*imaxamp;
    impulse_data = impulse_data*imaxamp;

    close all;
    
    if run_focus_simulation
    figure(1)
    rf2image(image_data,xalines,1540,fs,zmin,zmax,window,level,Ninterp,zshift,maxx);
    title( sprintf(['Focus\n' num2str(fs/1e6) 'MHz']))
    end
    
    if run_reference_simulation
    figure(2)    
    rf2imageni(impulse_data,xalines,1540,fs_reference,zmin,zmax,window,level,Ndec,zshift,maxx);
    title( sprintf(['Reference\n' num2str(fs_reference/1e6) 'MHz']))
    end
end


clear image_data;
clear impulse_data;



