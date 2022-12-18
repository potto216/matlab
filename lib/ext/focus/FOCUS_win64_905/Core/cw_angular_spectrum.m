function pressure = cw_angular_spectrum(p0,coordinate_grid,medium,f0,nffts,propagator_type)
% Computation engine for angular spectrum approach.
% Usage:
% [pressure] = cw_angular_spectrum(p0,z,medium,nffts,delta,propagator_type);
% Input parameter:
% p0 - matrix of size [nx,ny], input pressure or velocity source.
% z - vector, location of destination planes, including the starting plane.
% nffts - FFT grid number.
% delta - scalar,spatial sampling interval in m.
% propagator_type - Selection for different choices of ASA method:
%   'P': Spectral propagator and pressure source without angular restriction.
%   'Pa': Spectral propagator and pressure source with angular restriction.
%   'V': Spectral propagator and velocity source without angular restriction.
%   'Va': Spectral propagator and velocity source with angular restriction.
%   'p': Spatial propagator and pressure source without angular restriction.
%   'v': Spatial propagator and velocity source without angular restriction.
% Output parameter:
% pressure - matrix of size [nx,ny,nz], calculated pressure.

% Warn the user if the input pressure field is undersampled
wavelen=medium.soundspeed/f0;

if coordinate_grid.delta(1) > wavelen/2 || coordinate_grid.delta(2) > wavelen/2
    warning('The input pressure plane is sampled at greater than half the wavelength. Please use a closer spatial sampling in x and y to avoid aliasing.');
end

% Might as well warn them if dz is too large too
if coordinate_grid.delta(3) > wavelen/2
    warning('The output spatial sampling is greater than half the wavelength. This will result in aliasing of the output pressure.');
end


% Use Pa propagator if none was specified
if nargin <= 5
    propagator_type = 'Pa';
end
if nargin > 6 || nargin < 5
    error('Incorrect number of arguments provided. Please see the documentation for the correct usage.');
end

% Get dz from coordinate grid
delta = coordinate_grid.delta(3);
% Calculate z vector using coordinate grid values
if coordinate_grid.zmin < coordinate_grid.zmax
    z = coordinate_grid.zmin:delta:coordinate_grid.zmax;

    z0=z(1);
    z=z-z0;
else
    z0 = coordinate_grid.zmin;
    z = 0;
end
nn=size(p0);
nx=nn(1);
ny=nn(2);
nz = length(z);
% Convert attenuation to Np/m
dBperNeper = 20 * log10(exp(1));
attenuationNeperspermeter=medium.attenuationdBcmMHz/dBperNeper*100*f0/1e6;

pressurez0 = fft2(p0,nffts,nffts);

for iz = 1:nz
    if (z0 == 0) && (iz == 1) % just copy the source plane into the output
        pressure(:,:,1) = p0;
    else
        delz = z(iz);

        if (~isempty(strfind(propagator_type,'P'))) || (~isempty(strfind(propagator_type,'V')))
            wavenum = 2*pi/wavelen;

            if mod(nffts,2) % odd number
                kx = [(-nffts/2-0.5):1:(nffts/2-1.5)]*wavelen/(nffts*delta);
                ky = [(-nffts/2-0.5):1:(nffts/2-1.5)]*wavelen/(nffts*delta);
            else % even number
                kx = [(-nffts/2):1:(nffts/2-1)]*wavelen/(nffts*delta);
                ky = [(-nffts/2):1:(nffts/2-1)]*wavelen/(nffts*delta);
            end

            [kxspace,kyspace] = meshgrid(kx,ky);
            kxspace = kxspace;
            kyspace = kyspace;
            kxsq_ysq = fftshift(kxspace.^2 + kyspace.^2);
            kzspace = wavenum*sqrt(1 - complex(kxsq_ysq));
            % Basic spectral propagator
            if ~isempty(strfind(propagator_type,'P'))
                if z(iz)>z0
                    H = conj(exp(1j*delz.*kzspace));
                else
                    H = exp(-1j*delz.*kzspace).*(kxsq_ysq<=1);
                end
            elseif ~isempty(strfind(propagator_type,'V'))
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
            if ~isempty(strfind(propagator_type,'a'))
                D = (nffts-1)*delta;
                thres = sqrt(0.5*D^2/(0.5*D^2+delz^2));
                filt = (sqrt(kxsq_ysq) <= thres);

                H = H.*filt;
            end

            newpress = ifft2(pressurez0.*H,nffts,nffts);
            pressure(:,:,iz) = newpress(1:nx,1:ny);

        elseif (~isempty(strfind(propagator_type,'p'))) || (~isempty(strfind(propagator_type,'v')))

            wavenum = 2*pi/wavelen - 1j * attenuationNeperspermeter;

            if mod(nffts,2) % odd number
                xD = [(-nffts/2-0.5):1:(nffts/2-1.5)]*delta;
                yD = [(-nffts/2-0.5):1:(nffts/2-1.5)]*delta;
            else        % even number
                xD = [-nffts/2:(nffts/2-1)]*delta;
                yD = [-nffts/2:(nffts/2-1)]*delta;
            end
            [ygrid,xgrid] = meshgrid(yD,xD);
            rgrid = sqrt(xgrid.^2+ygrid.^2);
            grids = sqrt(xgrid.^2+ygrid.^2+delz^2);

            if ~isempty(strfind(propagator_type,'p'))
                coeff = (delta)^2;
                if delz>=0
                    h = coeff*delz./(2*pi*(grids).^3).*(1+1j*wavenum*grids).*exp(-1j*wavenum*grids);
                else
                    h = -coeff*delz./(2*pi*(grids).^3).*(1-1j*wavenum*grids).*exp(1j*wavenum*grids);
                end
            elseif ~isempty(strfind(propagator_type,'v'))
                coeff = (delta^2)/wavelen;
                h = coeff*exp(-1j*wavenum*grids)./grids;
                [indinan,indjnan] = find(isnan(h)==1); % remove sigularities
                for m = 1:length(indinan)
                    h(indinan(m),indjnan(m)) = 1e-16
                end
            end

            H = fft2(h,nffts,nffts);
            newpress = ifft2(pressurez0.*H,nffts,nffts);
            newpress = fftshift(newpress);
            pressure(:,:,iz) = newpress(1:nx,1:ny);
        else
            error('Invalid propagator type. See the documentation for cw_angular_spectrum for valid options.');
        end
    end
end
