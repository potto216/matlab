%This modified code has debugging information for plots
%  Compress the data to show 60 dB of
%  dynamic range for the cyst phantom image
%
%  version 1.3 by Joergen Arendt Jensen, April 1, 1998.
%  version 1.4 by Joergen Arendt Jensen, August 13, 2007.
%          Clibrated 60 dB display made

f0=3.5e6;                 %  Transducer center frequency [Hz]
fs=100e6;                 %  Sampling frequency [Hz]
c=1540;                   %  Speed of sound [m/s]
no_lines=50;              %  Number of lines in image
image_width=40/1000;      %  Size of image sector
d_x=image_width/no_lines; %  Increment for image

%  Read the data and adjust it in time

min_sample=0;
for i=1:no_lines
    
    %  Load the result
    
    cmd=['load rf_data/rf_ln',num2str(i),'.mat'];
    disp(cmd)
    eval(cmd)
    
    %  Find the envelope
    rf_data_zeropad=[zeros(round(tstart*fs-min_sample),1); rf_data];
    %rf_env=abs(hilbert(rf_data));
    rf_env_zeropad=abs(hilbert( rf_data_zeropad)); %[zeros(round(tstart*fs-min_sample),1); rf_env];
    env(1:max(size(rf_env_zeropad)),i)=rf_env_zeropad;
    
    if any(i==[10 19 38])
        %i = 10 is homogenous
        %i = 19 is dense balls
        %i = 38 is air gaps
        %%     
        t_zeropad_usec=[0:(length(rf_env_zeropad)-1)]*1/fs*1e6;
        figure;        
        plot(t_zeropad_usec,rf_data_zeropad)
        hold on;
        plot(t_zeropad_usec,rf_env_zeropad)
        plot([0 tstart]*1e6,[0 0],'lineWidth',2)
        xlabel('\musec')
        ylabel('Volts')
        title(['Scanline ' num2str(i)]);
        xlim([0 120])
        %ylim([-3 3]*1e-20)
        
        
        
    end
end    
    %  Do logarithmic compression
    
    D=10;   %  Sampling frequency decimation factor
    
    disp('Finding the envelope')
    log_env=env(1:D:max(size(env)),:)/max(max(env));
    log_env=20*log10(log_env);
    log_env=127/60*(log_env+60);
    
    %  Make an interpolated image
    
    disp('Doing interpolation')
    ID=20;
    [n,m]=size(log_env);
    new_env=zeros(n,m*ID);
    for i=1:n
        new_env(i,:)=abs(interp(log_env(i,:),ID));
    end
    [n,m]=size(new_env);
    
    fn=fs/D;
    figure
    clf
    image(((1:(ID*no_lines-1))*d_x/ID-no_lines*d_x/2)*1000,((1:n)/fn+min_sample/fs)*1540/2*1000,new_env)
    xlabel('Lateral distance [mm]')
    ylabel('Axial distance [mm]')
    colormap(gray(127))
    axis('image')
    axis([-20 20 35 90])
    
