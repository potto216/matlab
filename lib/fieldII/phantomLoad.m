function [ objPhantom ] = phantomLoad(objFieldII, name,phantomArguments )
%This function is used to load a set of phantom scatters and any
%accomping meta code.  The function also computes the background scatter
%denisty to make sure it will provide accurate results.  The minimal
%requirment is 30 scatters per cubic wavelength

switch(name)
    case 'tendon'        
        objPhantom = phantomSimTendonInit(phantomArguments{:});                
        
    case 'rectusFemoris'
        objPhantom = phantomSimRectusFemorisInit(phantomArguments{:});                        
    
    case 'rectusFemoris_sphereScatter'
        objPhantom = phantomSimRectusFemorisSphereScatterInit(phantomArguments{:});  
        
    case 'rectusFemoris_fascicle'
        objPhantom = phantomSimRectusFemorisFascicleInit(phantomArguments{:});  
        
    case 'trapezius'        
        objPhantom = phantomSimTrapeziusInit(phantomArguments{:});                
        
    case 'cyst'        
       objPhantom  = phantomSimCystInit(phantomArguments{:});
        
    otherwise
        error(['The phantom name of ' name ' is not supported.'])
end

objPhantom.phantomArguments=phantomArguments;
objPhantom.name=name;

%TODO: Change volume calc to pull all scatters

backgroundVolume_m=[min(objPhantom.background.x_m) min(objPhantom.background.y_m) min(objPhantom.background.z_m); max(objPhantom.background.x_m) max(objPhantom.background.y_m) max(objPhantom.background.z_m)];
volumeCalc_m3=cumprod(diff(backgroundVolume_m,[],1));
volumeCalc_m3=volumeCalc_m3(3);

scattersPerMeterCubed=length(objPhantom.background.x_m)/volumeCalc_m3;

wavelength_m=objFieldII.speedOfSound_mPerSec/objFieldII.probe(objFieldII.xmit.probeIndex).centerFrequency_Hz;

scattersPerWavelengthCubed=scattersPerMeterCubed*(wavelength_m^3);

disp(['[phantomLoad] The amount of scatters per wavelength cubed is ' num2str(scattersPerWavelengthCubed) '.'])

if scattersPerWavelengthCubed<30 
    disp('----The number of scatters is low.  A good simulation requires > 30 scatters per wavelength cubed.');
end
    


end

