%Simulations to run (0=off, 1=on)
%Warning running the reference image with impulse response will take days
%to complete
run_reference_simulation = 0;

%Focus will complete in less than an hour
run_focus_simulation = 1;

%plot B-mode Images after simulations (0=off, 1=on)
display_plot = 1;

%Number of scatters to run the simulations with
Nscatter = 100000;

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
focus_tx=30/1000; 
focus_rx=[5;15;25;35;45;55]/1000;
zones=   [0;10;20;30;40;50;Inf]/1000;

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
N_divisions_y=5;
xdcr = create_rect_curved_strip_array(N_elements, N_divisions_y, width, element_height, kerf, r_curv);
%  Generate aperture for transmit
emit_aperture_focus = create_rect_curved_strip_array(N_elements, N_divisions_y, width, element_height, kerf, r_curv);
%  Generate aperture for reception
receive_aperture_focus = create_rect_curved_strip_array(N_elements, N_divisions_y, width, element_height, kerf, r_curv);


% Create a Planar Array
% N_divisions_y=1;
% xdcr = create_rect_planar_array(nx, ny, width, element_height, kerf, kerf);
% %  Generate aperture for transmit
% emit_aperture_focus = create_rect_planar_array(nx, ny, width, element_height, kerf, 0);
% %  Generate aperture for reception
% receive_aperture_focus = create_rect_planar_array(nx, ny, width, element_height, kerf, 0);


xelement_centers = zeros(nx, ny);
for ix = 1:nx,
    xelement_centers(ix) = xdcr(ix).center(1);
end

% create the scatterers
if exist([num2str(Nscatter) '_scatters.mat'], 'file')
    fprintf('%i_scatters.mat already exsists\n', Nscatter);
else
    [phantom_positions, phantom_amplitudes] = cyst_phantom(Nscatter);
    save([num2str(Nscatter) '_scatters.mat'],'phantom_positions','phantom_amplitudes','Nscatter','-v7.3');
end

%load the scatterers
load([ num2str(Nscatter) '_scatters']);

for iscat = 1:Nscatter
    scatterers(iscat) = get_scatterer(phantom_positions(iscat,1),phantom_positions(iscat,2),phantom_positions(iscat,3),phantom_amplitudes(iscat));
end

%Save workspace variables for parfor zone calculation
save('workspace_vars.mat', 'Nscatter', 'emit_aperture_focus', 'receive_aperture_focus', 'xelement_centers','zones','N_alines','xalines','nactive_elements','N_elements','N_active','apo','focus_tx','focus_rx','medium','nx','ny','N_divisions_y','fs_reference','fs','scatterers','ndiv','excitation');
parfor izone = 1:(length(zones)-1)     

    calc_bmode_zone(izone, run_reference_simulation, run_focus_simulation);
    
end

image_data_multizone=zeros(1,N_alines);
impulse_data_multizone=zeros(1,N_alines);

time_to_calc_multizone_image=0;
time_to_calc_multizone_impulse=0;

%consolidate results into 1 file 
if run_focus_simulation
for izone = 1:(length(zones)-1) 
    load([ num2str(Nscatter) '_focus_image_zone_' num2str(izone) '_' num2str(fs/1e6) 'MHz']);

    if length(image_data)>length(image_data_multizone)
        image_data_multizone(size(image_data_multizone,1)+1:length(image_data),:) =  zeros((length(image_data)-size(image_data_multizone,1)),N_alines);
    end

    image_data_multizone(1:length(image_data),:) = image_data_multizone(1:length(image_data),:) + image_data;

    time_to_calc_multizone_image = time_to_calc_multizone_image + time_to_calc_image;
    clear image_data;
      
end
save([ num2str(Nscatter) '_focus_image_multizone_' num2str(fs/1e6) 'MHz'],'image_data_multizone','Nscatter','phantom_positions','xalines','phantom_amplitudes','fs','time_to_calc_multizone_image','-v7.3');
end


if run_reference_simulation
for izone = 1:(length(zones)-1) 
    load([ num2str(Nscatter) '_impulse_ref_zone_' num2str(izone) '_' num2str(fs_reference/1e6) 'MHz']);

    if length(impulse_data)>length(impulse_data_multizone)
        impulse_data_multizone(size(impulse_data_multizone,1)+1:length(impulse_data),:) =  zeros((length(impulse_data)-size(impulse_data_multizone,1)),N_alines);
    end

    impulse_data_multizone(1:length(impulse_data),:) = impulse_data_multizone(1:length(impulse_data),:) + impulse_data;

    time_to_calc_multizone_impulse = time_to_calc_multizone_image + time_to_calc_impulse;
    clear impulse_data;
end
save([ num2str(Nscatter) '_impulse_ref_multizone_' num2str(fs_reference/1e6) 'MHz'],'impulse_data_multizone','Nscatter','phantom_positions','xalines','phantom_amplitudes','fs_reference','time_to_calc_multizone_impulse','-v7.3');
end

    

if run_reference_simulation
load([ num2str(Nscatter) '_impulse_ref_multizone_' num2str(fs_reference/1e6) 'MHz']);
fprintf('\nReference calculation took %f seconds\n', time_to_calc_multizone_impulse);
end

if run_focus_simulation
load([ num2str(Nscatter) '_focus_image_multizone_' num2str(fs/1e6) 'MHz']);
fprintf('calculation took %f seconds\n\n', time_to_calc_multizone_image);
end

if run_focus_simulation && run_reference_simulation
fprintf('RMS error of FOCUS compared to Reference = %f %%\n', calc_norm_error(impulse_data_multizone, image_data_multizone, fs_reference, fs)*100 );
fprintf('PEAK error of FOCUS compared to Reference = %f %%\n\n', calc_peak_error(impulse_data_multizone, image_data_multizone, fs_reference, fs)*100);
end 

%Display B-mode images
if display_plot
    window = 60;
    level = -20;

    zmin=79.5e-3;
    zmax=zmin+60e-3;

    Ninterp=5;
    Ndec=25;
    zshift=79.5e-3;
    maxx=20e-3;

    maxamp = max(max(max(image_data_multizone)),max(max(impulse_data_multizone)));
    imaxamp = 1/maxamp;
    image_data_multizone = image_data_multizone*imaxamp;
    impulse_data_multizone = impulse_data_multizone*imaxamp;

    close all;
    
    if run_focus_simulation
    figure(1)
    rf2image(image_data_multizone,xalines,1540,fs,zmin,zmax,window,level,Ninterp,zshift,maxx);
    title( sprintf(['Focus\n' num2str(fs/1e6) 'MHz']))
    end
    
    if run_reference_simulation
    figure(2)    
    rf2imageni(impulse_data_multizone,xalines,1540,fs_reference,zmin,zmax,window,level,Ndec,zshift,maxx);
    title( sprintf(['Reference\n' num2str(fs_reference/1e6) 'MHz']))
    end
end


clear image_data_multizone;
clear impulse_data_multizone;



