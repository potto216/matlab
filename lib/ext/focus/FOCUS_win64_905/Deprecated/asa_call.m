function pressure=asa_call(source,z0,z,medium,nfft,delta,type,f0)
warning('This function is deprecated and may be removed from future versions of FOCUS. Please use cw_angular_pressure instead.');
% Description
%   This function will call the C++ binary ASA routine in the final version of the program, right now it calls the Matlab protected file that has the ASA functionality. This function does not have any error checking but will abort if an insufficient number of arguments is passed.
% Usage
%   pressure = asa_call(p0, z0, z, medium, nfft, delta, type, f0); 
% Arguments
%   p0: matrix of size [nx,ny], input pressure or velocity source.
%   z0: scalar, location of the source pressure plane.
%   z: vector, location of destination planes.
%   medium: The medium in which this calculation will occur.
%   nfft: FFT grid number.
%   delta: scalar, spatial sampling interval in meters.
%   type: Selection for different choices of ASA method; default is 'Pa'.
%     'P': Spectral
%     'Pa': Spectral
%     'V': Spectral
%     'Va': Spectral
%     'p': Spatial
%     'v': Spatial
%   f0: Excitation frequency of the source wave.
% Output Parameters
%   fftpress: matrix of size [ nx ny nz ], calculated pressure.
% Notes
%   This function is for linear non-layered mediums only. Additional functions will be added later. You should already have some kind of 2-d field created before attempting to call this function. This function will change as needed when more features are added. We will attempt to keep compatibility for existing codes, but it cannot be guaranteed.
if exist('type')~=1
    type='Pa';
end
if nargin()~=8
    pressure=[];
	error('Needs exactly 8 arguments');
	return
end
if isstruct(medium)==0
    Pressure=[];
	error('error in medium struct, please fix')
end

if ndims(source)~= 2
    pressure=[];
	error('Source pressure must be 2d')
end

if nfft<max(size(source))
    error('nfft must be larger then largest dimension in the source plane')
end
pressure=[];
pressure = fftasa(source, z - z0, medium, nfft, delta, type, f0);
