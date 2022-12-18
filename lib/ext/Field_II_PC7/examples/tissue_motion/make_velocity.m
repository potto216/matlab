%  Calculate the function determining velocity profiles
%  for the common carotid artery
%
%  Version 1.0, April 5, 1993, JAJ

%  Physical parameters

rho=1.06e3;        %  Density of blood   [kg/m^3]
mu=0.004;          %  Viscosity of blood [kg/m s]
R=0.0040;          %  Radius of vessel   [m]
omega_0=2*pi*1;  %  Angular frequency, heart rate = 62 beats/min
V0=0.15;           %  Mean velocity      [m/s]

deltaR=0.0025;
r_rel=(0:deltaR:1)';  %  Values for the relative radius
time_values=(0:1/3500:1)';  %  Calculate the different values for the time


%   Calculate psi

i=sqrt(-1);
for p=1:8
  disp(['Harmonic number ',num2str(p)])
  omega=p*omega_0;
  tau_alpha=i^(3/2)*R*sqrt(omega*rho/mu);
  Be=tau_alpha*besselj(0,tau_alpha);
  psi(:,p)=(Be-tau_alpha*besselj(0,r_rel.*tau_alpha))/(Be-2*besselj(1,tau_alpha));
  end

%   Data for phase and amplitude of waveform

Vp=[1.00    0.00
    0.33   74 
    0.24   79 
    0.24  121
    0.12  146 
    0.11  147 
    0.13  179
    0.06  233 
    0.04  218];

%  Convert the data to the correct amplitude

Vp(:,1)=Vp(:,1)*V0;
Vp(:,2)=Vp(:,2)*pi/180;


time_index=1;
for time=time_values'
  index=1;
  disp (['Time is ',num2str(time),' seconds'])
  prof=2*V0*(1-r_rel.^2);
  index=[1:max(size(r_rel))];
  for p=2:8
    prof=prof + Vp(p,1)*abs(psi(index,p-1)).*cos((p-1)*omega_0*time - Vp(p,2) + angle(psi(index,p-1)));
    end;
  profiles(:,time_index)=prof;
  time_index=time_index+1;
  end;

save velocity profiles r_rel
