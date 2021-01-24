function objFieldII=objFieldIIConfigure(objFieldII )
%This function will configure the field II simulation environment with the
%settings specified by the field II object.  The following parameters can be
%overridden:
%numberOfSubdivisionsInX 
%numberOfSubdivisionsInY 


%  Set the sampling frequency
set_sampling(objFieldII.sampleRate_Hz);

%  Generate aperture for emission
probe=objFieldII.probe(objFieldII.xmit.probeIndex);


numberOfSubdivisionsInX=1;
numberOfSubdivisionsInY=10;
objFieldII.xmit.deviceHandle = xdc_linear_array (probe.elementTotalPhysical, probe.element.width_m, probe.element.height_m, probe.element.kerf_m, numberOfSubdivisionsInX, numberOfSubdivisionsInY,objFieldII.xmit.focalPoint_m);

%  Set the impulse response and excitation of the xmit aperture
xdc_impulse (objFieldII.xmit.deviceHandle, objFieldII.xmit.impulseResponse);

xdc_excitation (objFieldII.xmit.deviceHandle, objFieldII.xmit.excitation);

%  Generate aperture for reception

probe=objFieldII.probe(objFieldII.rcv.probeIndex);

objFieldII.rcv.deviceHandle = xdc_linear_array (probe.elementTotalPhysical, probe.element.width_m, probe.element.height_m, probe.element.kerf_m, numberOfSubdivisionsInX, numberOfSubdivisionsInY,objFieldII.rcv.focalPoint_m);
%  Set the impulse response for the receive aperture
xdc_impulse (objFieldII.rcv.deviceHandle, objFieldII.rcv.impulseResponse);
xdc_excitation (objFieldII.rcv.deviceHandle, objFieldII.rcv.excitation);

end