function output = nonlinasa(u0,z,tissue_struct,N,delta,sign,f0,nmax,nout)
% Simulate pressure in a homogeneous nonlinear medium.
% Usage:
% output = nonlinasa(u0,z,N,nmax,nout,nx,ny,delta,f0,tissue_struct,sign)
% Input parameter:
% u0 - matrix of size [nx,ny], input particle velocity source,
%      source pressure plane is located at z(1), not necessarily 
%      on radiator surface.
% z - vector, location of destination planes.
% N - FFT grid number.
% nmax - scalar, maxium number of harmonics involved in the calculation.
% nout - scalar, the number of harmonics to return.
% delta - scalar, scalar,spatial sampling interval in m.
% f0 - scalar, excitation frequency.
% tissue_struct - MATLAB structure, parameters of tissue medium.
% sign - Select pressure or particle velocity as output.
%        'v' - velocity, 'p' - pressure.
% Output parameter:
% Output - matrix of size [nx,ny,nz], press or vel.
% press - matrix of size [nx,ny,nz], calculated pressure.
% vel - matrix of size [nx,ny,nz], calculated particle velocity.
[nx ny]= size(u0);
dz = z(2)-z(1);
nz = length(z);
z0 = z(1);
u_matrix = zeros(nx,ny,1,nmax);
u_matrix(:,:,1,1) = u0;
% Attenuation coefficient associated with the fundamental frequency
atten0 = tissue_struct.attenuationdBcmMHz/ 8.685889638065037 * 100 * f0/ 1e6;
% Wavelength associated with the fundamental frequency
wavelen0 = tissue_struct.soundspeed/f0;

% Initiate output
output = zeros(nx,ny,1,nout);

if sign == 'v'
    output(:,:,1,1) = u0;
elseif sign == 'p'
    output(:,:,1,1) = u0*tissue_struct.soundspeed*tissue_struct.density;
end

for iz = 2:nz
    for n = 1:nmax
        wavelen = wavelen0/n;
        atten = atten0*n^tissue_struct.powerlawexponent;
        %temp = asa_call(u_matrix(:,:,1,n),z0,[z0 z(iz)],tissue_struct,N,delta,'P',n*f0);%cw_angular_spectrum(u_matrix(:,:,1,n),coords,tissue_struct,f0,N,'P');%asa_call(u_matrix(:,:,1,n),z0,[z0 z(iz)],tissue_struct,N,delta,'P',f0);
        coords = set_coordinate_grid([0 0 delta], 0, 0, 0, 0, z0, z(iz));
        temp = cw_angular_spectrum(u_matrix(:,:,1,n),coords,tissue_struct,n*f0,N);
        u_matrix(:,:,1,n)=temp(:,:,2);
    end
    [u_matrix,nmax] = adpnonlinstep(u_matrix,nmax,nx,ny,dz,f0,tissue_struct);
    % fprintf('z=%f,nmax=%d,pmax=%f\n',z(iz),nmax,max(abs(u_matrix(:))));
    if sign == 'v'
        output = cat(3,output,u_matrix(:,:,1,1:nout));
    elseif sign == 'p'
        output =cat(3,output,u_matrix(:,:,1,1:nout)*tissue_struct.soundspeed*tissue_struct.density);
    end
    % Update the source plane location
    z0 = z(iz);
end


function [unew_matrix,nmax] =adpnonlinstep(u_matrix,nmax,nx,ny,dz,f0,tissue_struct)
scalar = 1j*tissue_struct.nonlinearityparameter*(pi*f0/tissue_struct.soundspeed^2)*dz; %% scalar = scalar / 2;
scalar = scalar / 2; 
unew_matrix = u_matrix;
for n = 1:nmax % no. of harmonics
    for k = 1:(n-1)
        unew_matrix(:,:,1,n) = unew_matrix(:,:,1,n) + ...
            scalar*k*u_matrix(:,:,1,k).*u_matrix(:,:,1,n-k);
    end
    for k = (n+1):nmax 
        unew_matrix(:,:,1,n) = unew_matrix(:,:,1,n) + ...
            scalar*n*u_matrix(:,:,1,k).*conj(u_matrix(:,:,1,k-n));
    end
end
% Update harmonic
if max(max(abs(u_matrix(:,:,1,nmax)))) >= 0.01*max(abs(u_matrix(:)))
    nmax = nmax+1;
    unew_matrix(:,:,1,nmax) = zeros(nx,ny);
end
