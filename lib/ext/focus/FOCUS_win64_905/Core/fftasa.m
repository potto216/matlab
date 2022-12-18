function [fftpress] = fftasa(p0,z,medium,N,delta,sign,f0)
% Computation engine for angular spectrum approach.
% Usage:
% [fftpress] = fftasa(p0,z,medium,N,delta,sign);
% Input parameter:
% p0 - matrix of size [nx,ny], input pressure or velocity source.
% z - vector, location of destination planes, including the starting plane.
% N - FFT grid number.
% delta - scalar,spatial sampling interval in m.
% sign - Selection for different choices of ASA method:
%   'P': Spectral propagator and pressure source without angular restriction.
%   'Pa': Spectral propagator and pressure source with angular restriction.
%   'V': Spectral propagator and velocity source without angular restriction.
%   'Va': Spectral propagator and velocity source with angular restriction.
%   'p': Spatial propagator and pressure source without angular restriction.
%   'v': Spatial propagator and velocity source without angular restriction.
% Output parameter:
% fftpress - matrix of size [nx,ny,nz], calculated pressure.

z0=z(1);
nn=size(p0);
nx=nn(1);
ny=nn(2);
wavelen=medium.soundspeed/f0;
% atten=medium.atten_coeff/.1151*100*f0;
dBperNeper = 20 * log10(exp(1));
attenuationNeperspermeter=medium.attenuationdBcmMHz/dBperNeper*100*f0/ 1e6;

fftpressz0 = fft2(p0,N,N);
nz = length(z);
% fftpress(:,:,1)=p0;
for iz = 1:nz,
    if (z0 == 0)  && (iz == 1), % just copy the source plane into the output
        fftpress(:,:,1) = p0;
    else
% for iz = 2:nz, previously, the source plane would be at iz = 1, but now,
% we are more flexible and we allow the source plane to be elsewhere
    delz = z(iz);
%     delz = z(iz)-z0; % used to do it this way, but now that the source
%     plane is sent separately in asa_call, the delz entries are indeed equal to z 

    
    if (~isempty(findstr(sign,'P'))) || (~isempty(findstr(sign,'V')))

        wavenum = 2*pi/wavelen;

        if mod(N,2) % odd number
            kx = [(-N/2-0.5):1:(N/2-1.5)]*wavelen/(N*delta);
            ky = [(-N/2-0.5):1:(N/2-1.5)]*wavelen/(N*delta);
        else % even number
            kx = [(-N/2):1:(N/2-1)]*wavelen/(N*delta);
            ky = [(-N/2):1:(N/2-1)]*wavelen/(N*delta);
        end

        [kxspace,kyspace] = meshgrid(kx,ky);
        kxsq_ysq = fftshift(kxspace.^2 + kyspace.^2);
        kzspace = wavenum*sqrt(1 - kxsq_ysq);
        % Basic spectral propagator
        if ~isempty(findstr(sign,'P'))
            if z(iz)>z0
                H = conj(exp(1j*delz.*kzspace));
            else
                H = exp(-1j*delz.*kzspace).*(kxsq_ysq<=1);
            end
        elseif ~isempty(findstr(sign,'V'))
            H = wavenum*conj(exp(1j*kzspace*delz))./(1j*kzspace);
            [indinan,indjnan] = find(isnan(H)==1); % remove sigularities
            for m = 1:length(indinan)
                H(indinan(m),indjnan(m)) = 1e-16;
            end
        end
        %% attenuation
        if attenuationNeperspermeter>0
            evans_mode = sqrt(kxsq_ysq)<1;
            H =H.*exp(- attenuationNeperspermeter * delz./cos(asin(sqrt(kxsq_ysq))).*evans_mode).*evans_mode;
        end

        %% angular threshold
        if ~isempty(findstr(sign,'a'))
            D = (N-1)*delta;
            thres = sqrt(0.5*D^2/(0.5*D^2+delz^2));
            filt = (sqrt(kxsq_ysq) <= thres);
% figure(9)
% contour(filt)
            H = H.*filt;
% mesh(abs(H))
        end

        newpress = ifft2(fftpressz0.*H,N,N);
        fftpress(:,:,iz) = newpress(1:nx,1:ny);

    elseif (~isempty(findstr(sign,'p'))) || (~isempty(findstr(sign,'v')))

        wavenum = 2*pi/wavelen - 1j * attenuationNeperspermeter;

        if mod(N,2) % odd number
            xD = [(-N/2-0.5):1:(N/2-1.5)]*delta;
            yD = [(-N/2-0.5):1:(N/2-1.5)]*delta;
        else        % even number
            xD = [-N/2:(N/2-1)]*delta;
            yD = [-N/2:(N/2-1)]*delta;
        end
        [ygrid,xgrid] = meshgrid(yD,xD);
        rgrid = sqrt(xgrid.^2+ygrid.^2);
        grids = sqrt(xgrid.^2+ygrid.^2+delz^2);

        if ~isempty(findstr(sign,'p'))
            coeff = (delta)^2;
            if delz>=0
                h = coeff*delz./(2*pi*(grids).^3).*(1+1j*wavenum*grids).*exp(-1j*wavenum*grids);
            else
                h =-coeff*delz./(2*pi*(grids).^3).*(1-1j*wavenum*grids).*exp(1j*wavenum*grids);
            end
        elseif ~isempty(findstr(sign,'v'))
            coeff = (delta^2)/wavelen;
            h = coeff*exp(-1j*wavenum*grids)./grids;
            [indinan,indjnan] = find(isnan(h)==1); % remove sigularities
            for m = 1:length(indinan)
                h(indinan(m),indjnan(m)) = 1e-16
            end
        end

        H = fft2(h,N,N);
        newpress = ifft2(fftpressz0.*H,N,N);
        newpress = fftshift(newpress);
        fftpress(:,:,iz) = newpress(1:nx,1:ny);

    end
    
    end
end
