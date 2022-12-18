function [ objFieldII ] = objFieldIISetup(name )
%This function will configure the field II object for a standard
%configuration which can have particular settings overridden if needed.
switch(name)
    case 'ultrasonix'
        objFieldII=objFieldIISetupUltrasonixL145W60();
    case 'verasonicsGenericTx128_Rcv64'
        objFieldII=objFieldIISetupVerasonicsGenericTx128_Rcv64();
    case 'verasonicsGenericTx128_Rcv128'
        objFieldII=objFieldIISetupVerasonicsGenericTx128_Rcv128();        
    case 'verasonicsGenericTx64_Rcv64'
        objFieldII=objFieldIISetupVerasonicsGenericTx64_Rcv64(); 
    case 'objFieldIISetupVerasonicsGenericTx64_Rcv64_Probe64'
        objFieldII=objFieldIISetupVerasonicsGenericTx64_Rcv64_Probe64();
    otherwise
        error(['Unsupported configuration name of ' name]);

end

end


function objFieldII=objFieldIISetupUltrasonix() %#ok<DEFNU>
objFieldII.sampleRate_Hz=100e6;              % Sampling frequency [Hz]
objFieldII.speedOfSound_mPerSec=1540;        % Speed of sound [m/s]

%TODO use 7.5Mz but this will adjust the element width (was 3.5Mhzz
objFieldII.probe.centerFrequency_Hz=7e6;         % Transducer center frequency [Hz]
objFieldII.probe.element.width_m=2*objFieldII.speedOfSound_mPerSec/objFieldII.probe.centerFrequency_Hz;
objFieldII.probe.element.height_m=5/1000;           %  Height of element [m]
objFieldII.probe.element.kerf_m=0.05/1000;       %  Kerf [m]
objFieldII.probe.elementTotalPhysical=128;         %  Number of physical elements
%objFieldII.probe.elementTotalActive=64;            %  Number of active elements

%apo=hanning(objFieldII.probe.elementTotalActive);

fs=objFieldII.sampleRate_Hz;
f0=objFieldII.probe.centerFrequency_Hz;

excitation=sin(2*pi*f0*(0:1/fs:2/f0));

impulseResponse=sin(2*pi*f0*(0:1/fs:2/f0));
impulseResponse=impulseResponse.*hanning(max(size(impulseResponse)))';


%setup Transmit
objFieldII.xmit.focalPoint_m=[0 0 12]/1000;         %  Fixed focal point [m]
objFieldII.xmit.apodization=apo;
objFieldII.xmit.excitation=excitation;
objFieldII.xmit.impulseResponse=impulseResponse;
objFieldII.xmit.deviceHandle=[];
objFieldII.xmit.probeIndex=1;

%setup Receive
objFieldII.rcv.focalPoint_m=[0 0 12]/1000;         %  Fixed focal point [m]
objFieldII.rcv.focalZones_m=(10:2:15)'/1000;   %assumed to be in z direction
objFieldII.rcv.focalTimes_sec=(objFieldII.rcv.focalZones_m-0/1000)/objFieldII.speedOfSound_mPerSec;
objFieldII.rcv.apodization=apo;
objFieldII.rcv.excitation=excitation;
objFieldII.rcv.impulseResponse=impulseResponse;
objFieldII.rcv.deviceHandle=[];
objFieldII.rcv.probeIndex=1;

objFieldII.collect.numberOfLines=50;         %  Number of lines in image
objFieldII.collect.imageWidth_m=30/1000;     %  Size of image sector
end

%Uses the information from the L14-5W/60 data sheet updated Aug 2009
function objFieldII=objFieldIISetupUltrasonixL145W60()
objFieldII.sampleRate_Hz=100e6;              % Sampling frequency [Hz]
objFieldII.speedOfSound_mPerSec=1540;        % Speed of sound [m/s]

%L14-5W/60
objFieldII.probe.centerFrequency_Hz=7.5e6;         % Transducer center frequency [Hz]
objFieldII.probe.element.width_m=0.477/1000;
objFieldII.probe.element.height_m=4/1000;           %  Height of element [m]
objFieldII.probe.element.kerf_m=0.025/1000;       %  Kerf [m]
objFieldII.probe.elementTotalPhysical=128;         %  Number of physical elements


fs=objFieldII.sampleRate_Hz;
f0=objFieldII.probe.centerFrequency_Hz;

excitation=sin(2*pi*f0*(0:1/fs:2/f0));

impulseResponse=sin(2*pi*f0*(0:1/fs:2/f0));
impulseResponse=impulseResponse.*hanning(max(size(impulseResponse)))';


%setup Transmit
objFieldII.xmit.elementTotalActive=32;            %  Number of active elements
objFieldII.xmit.focalPoint_m=[0 0 12]/1000;         %  Fixed focal point [m]
objFieldII.xmit.apodization=hanning(objFieldII.xmit.elementTotalActive);
objFieldII.xmit.excitation=excitation;
objFieldII.xmit.impulseResponse=impulseResponse;
objFieldII.xmit.deviceHandle=[];
objFieldII.xmit.probeIndex=1;

%setup Receive
objFieldII.rcv.elementTotalActive=32;            %  Number of active elements
objFieldII.rcv.focalPoint_m=[0 0 12]/1000;         %  Fixed focal point [m]
objFieldII.rcv.focalZones_m=(10:2:15)'/1000;   %assumed to be in z direction
objFieldII.rcv.focalTimes_sec=(objFieldII.rcv.focalZones_m-0/1000)/objFieldII.speedOfSound_mPerSec;
objFieldII.rcv.apodization=hanning(objFieldII.rcv.elementTotalActive);
objFieldII.rcv.excitation=excitation;
objFieldII.rcv.impulseResponse=impulseResponse;
objFieldII.rcv.deviceHandle=[];
objFieldII.rcv.probeIndex=1;

objFieldII.collect.numberOfLines=50;         %  Number of lines in image
objFieldII.collect.imageWidth_m=30/1000;     %  Size of image sector

end

%Uses the information from the L14-5W/60 data sheet updated Aug 2009
%setup for plane wave
%This will center the rcv in the middle of the transmit since the transmit
%array is larger
function objFieldII=objFieldIISetupVerasonicsGenericTx128_Rcv64()
objFieldII.sampleRate_Hz=100e6;              % Sampling frequency [Hz]
objFieldII.speedOfSound_mPerSec=1540;        % Speed of sound [m/s]

%L14-5W/60
objFieldII.probe.centerFrequency_Hz=7.5e6;         % Transducer center frequency [Hz]
objFieldII.probe.element.width_m=0.477/1000;
objFieldII.probe.element.height_m=4/1000;           %  Height of element [m]
objFieldII.probe.element.kerf_m=0.025/1000;       %  Kerf [m]
objFieldII.probe.elementTotalPhysical=128;         %  Number of physical elements


fs=objFieldII.sampleRate_Hz;
f0=objFieldII.probe.centerFrequency_Hz;

excitation=sin(2*pi*f0*(0:1/fs:2/f0));

impulseResponse=sin(2*pi*f0*(0:1/fs:2/f0));
impulseResponse=impulseResponse.*hanning(max(size(impulseResponse)))';


%setup Transmit
objFieldII.xmit.elementTotalActive=128;            %  Number of active elements
objFieldII.xmit.focalPoint_m=[0 0 inf]/1000;         %  Fixed focal point [m] want no focus
objFieldII.xmit.apodization=ones(1,objFieldII.xmit.elementTotalActive);
objFieldII.xmit.excitation=excitation;
objFieldII.xmit.impulseResponse=impulseResponse;
objFieldII.xmit.deviceHandle=[];
objFieldII.xmit.probeIndex=1;

%setup Receive
objFieldII.rcv.elementTotalActive=64;            %  Number of active elements
objFieldII.rcv.focalPoint_m=[];         %  Fixed focal point [m]
objFieldII.rcv.focalZones_m=[];   %assumed to be in z direction
objFieldII.rcv.focalTimes_sec=[];
objFieldII.rcv.apodization=zeros(1,objFieldII.xmit.elementTotalActive);
objFieldII.rcv.apodization(32:95)=ones(objFieldII.rcv.elementTotalActive,1);
objFieldII.rcv.excitation=excitation;
objFieldII.rcv.impulseResponse=impulseResponse;
objFieldII.rcv.deviceHandle=[];
objFieldII.rcv.probeIndex=1;

objFieldII.collect.numberOfLines=[];         %  Number of lines in image
objFieldII.collect.imageWidth_m=30/1000;     %  Size of image sector

end

%This will center the rcv in the middle of the transmit since the transmit
%array is larger and on the Verasonics it only receives 64 elements 
function objFieldII=objFieldIISetupVerasonicsGenericTx128_Rcv128()
objFieldII.sampleRate_Hz=100e6;              % Sampling frequency [Hz]
objFieldII.speedOfSound_mPerSec=1540;        % Speed of sound [m/s]

%L14-5W/60
objFieldII.probe.centerFrequency_Hz=7.5e6;         % Transducer center frequency [Hz]
objFieldII.probe.element.width_m=0.477/1000;
objFieldII.probe.element.height_m=4/1000;           %  Height of element [m]
objFieldII.probe.element.kerf_m=0.025/1000;       %  Kerf [m]
objFieldII.probe.elementTotalPhysical=128;         %  Number of physical elements


fs=objFieldII.sampleRate_Hz;
f0=objFieldII.probe.centerFrequency_Hz;

excitation=sin(2*pi*f0*(0:1/fs:2/f0));

impulseResponse=sin(2*pi*f0*(0:1/fs:2/f0));
impulseResponse=impulseResponse.*hanning(max(size(impulseResponse)))';


%setup Transmit
objFieldII.xmit.elementTotalActive=128;            %  Number of active elements
objFieldII.xmit.focalPoint_m=[0 0 40]/1000;         %  Fixed focal point [m] want no focus
objFieldII.xmit.apodization=ones(1,objFieldII.xmit.elementTotalActive);
objFieldII.xmit.excitation=excitation;
objFieldII.xmit.impulseResponse=impulseResponse;
objFieldII.xmit.deviceHandle=[];
objFieldII.xmit.probeIndex=1;

%setup Receive
objFieldII.rcv.elementTotalActive=128;            %  Number of active elements
objFieldII.rcv.focalPoint_m=[0 0 40]/1000;         %  Fixed focal point [m]
objFieldII.rcv.focalZones_m=[];   %assumed to be in z direction
objFieldII.rcv.focalTimes_sec=[];
objFieldII.rcv.apodization=zeros(1,objFieldII.xmit.elementTotalActive);
objFieldII.rcv.apodization(32:95)=ones(1,64);
objFieldII.rcv.excitation=excitation;
objFieldII.rcv.impulseResponse=impulseResponse;
objFieldII.rcv.deviceHandle=[];
objFieldII.rcv.probeIndex=1;

objFieldII.collect.numberOfLines=[];         %  Number of lines in image
objFieldII.collect.imageWidth_m=30/1000;     %  Size of image sector

end

%All 64 elements transmit and receive
function objFieldII=objFieldIISetupVerasonicsGenericTx64_Rcv64()
objFieldII.sampleRate_Hz=100e6;              % Sampling frequency [Hz]
objFieldII.speedOfSound_mPerSec=1540;        % Speed of sound [m/s]

%L14-5W/60
objFieldII.probe.centerFrequency_Hz=7.5e6;         % Transducer center frequency [Hz]
objFieldII.probe.element.width_m=0.477/1000;
objFieldII.probe.element.height_m=4/1000;           %  Height of element [m]
objFieldII.probe.element.kerf_m=0.025/1000;       %  Kerf [m]
objFieldII.probe.elementTotalPhysical=128;         %  Number of physical elements


fs=objFieldII.sampleRate_Hz;
f0=objFieldII.probe.centerFrequency_Hz;

excitation=sin(2*pi*f0*(0:1/fs:2/f0));

impulseResponse=sin(2*pi*f0*(0:1/fs:2/f0));
impulseResponse=impulseResponse.*hanning(max(size(impulseResponse)))';


%setup Transmit
objFieldII.xmit.elementTotalActive=64;            %  Number of active elements
objFieldII.xmit.focalPoint_m=[0 0 40]/1000;         %  Fixed focal point [m] want no focus
objFieldII.xmit.apodization=ones(1,objFieldII.xmit.elementTotalActive);
objFieldII.xmit.excitation=excitation;
objFieldII.xmit.impulseResponse=impulseResponse;
objFieldII.xmit.deviceHandle=[];
objFieldII.xmit.probeIndex=1;

%setup Receive
objFieldII.rcv.elementTotalActive=64;            %  Number of active elements
objFieldII.rcv.focalPoint_m=[0 0 40]/1000;         %  Fixed focal point [m]
objFieldII.rcv.focalZones_m=[];   %assumed to be in z direction
objFieldII.rcv.focalTimes_sec=[];
objFieldII.rcv.apodization=ones(1,objFieldII.xmit.elementTotalActive);
objFieldII.rcv.excitation=excitation;
objFieldII.rcv.impulseResponse=impulseResponse;
objFieldII.rcv.deviceHandle=[];
objFieldII.rcv.probeIndex=1;

objFieldII.collect.numberOfLines=[];         %  Number of lines in image
objFieldII.collect.imageWidth_m=30/1000;     %  Size of image sector

end

%All 64 elements transmit and receive
function objFieldII=objFieldIISetupVerasonicsGenericTx64_Rcv64_Probe64()
objFieldII.sampleRate_Hz=100e6;              % Sampling frequency [Hz]
objFieldII.speedOfSound_mPerSec=1540;        % Speed of sound [m/s]

%L14-5W/60
objFieldII.probe.centerFrequency_Hz=7.5e6;         % Transducer center frequency [Hz]
objFieldII.probe.element.width_m=0.477/1000;
objFieldII.probe.element.height_m=4/1000;           %  Height of element [m]
objFieldII.probe.element.kerf_m=0.025/1000;       %  Kerf [m]
objFieldII.probe.elementTotalPhysical=64;         %  Number of physical elements


fs=objFieldII.sampleRate_Hz;
f0=objFieldII.probe.centerFrequency_Hz;

excitation=sin(2*pi*f0*(0:1/fs:2/f0));

impulseResponse=sin(2*pi*f0*(0:1/fs:2/f0));
impulseResponse=impulseResponse.*hanning(max(size(impulseResponse)))';


%setup Transmit
objFieldII.xmit.elementTotalActive=64;            %  Number of active elements
objFieldII.xmit.focalPoint_m=[0 0 40]/1000;         %  Fixed focal point [m] want no focus
objFieldII.xmit.apodization=ones(1,objFieldII.xmit.elementTotalActive);
objFieldII.xmit.excitation=excitation;
objFieldII.xmit.impulseResponse=impulseResponse;
objFieldII.xmit.deviceHandle=[];
objFieldII.xmit.probeIndex=1;

%setup Receive
objFieldII.rcv.elementTotalActive=64;            %  Number of active elements
objFieldII.rcv.focalPoint_m=[0 0 40]/1000;         %  Fixed focal point [m]
objFieldII.rcv.focalZones_m=[];   %assumed to be in z direction
objFieldII.rcv.focalTimes_sec=[];
objFieldII.rcv.apodization=ones(1,objFieldII.xmit.elementTotalActive);
objFieldII.rcv.excitation=excitation;
objFieldII.rcv.impulseResponse=impulseResponse;
objFieldII.rcv.deviceHandle=[];
objFieldII.rcv.probeIndex=1;

objFieldII.collect.numberOfLines=[];         %  Number of lines in image
objFieldII.collect.imageWidth_m=30/1000;     %  Size of image sector

end
