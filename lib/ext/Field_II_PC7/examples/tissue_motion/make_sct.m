%  Example of use of the Field II program running under Matlab.
%
% This program generates the positions for blood and tissue scatterers - lying
% at some distance from the skin and at some angle relative to the direction of
% the transducer and emitted pulse. 
% The program takes into account the motion due to pulsation and respiration.

% Example by Malene Schlaikjer and Jørgen Arendt Jensen, January 15, 1999.


% Initializing parameters

f0=3.75e6;                % Transducer center frequency [Hz]
fs=105e6;                 % Sampling frequency [Hz]
c=1540;                   % Speed of sound [m/s]
lambda=c/f0;              % Wavelength
element_height=15/1000;   % Height of elements in transducer [m]
No_elements=60;           % Number of physical elements
kerf=0.03/1000;           % Kerf [m] - explain
focus=[0 0 40]/1000;      % Fixed focal point [m]
fprf = 3.5e3;             % Pulse repetition frequency

% Set the seed of the random generator

randn('seed',sum(100*clock));

% Initialize the ranges for the scatterers.

x_range=0.012;     % x range for the scatteres [m].

z_range=0.030;     % z range for the scatteres [m].

y_range=0.015;     % y range for the scatteres [m]. 

z_depth=30/1000;   % depth of center of the scatteres [m]. 

R=0.004;           % Radius of blood vessel [m].

Rwv=0.0003+R;      % Radius of blood vessel and vessel wall.

R_scanrange=0.020; % Value of scan range.



% Set the number of scatterers. Roughly 10 scatterers per resolution cell.

N=10*(x_range/(5*lambda))*(y_range/(5*lambda))*(z_range/(2*lambda))
disp([num2str(N),' Scatteres'])

% Generate the coordinates and amplitude. Amplitude has a Gaussion distribution.
% Coordinates are rectangular within the range.

x=x_range*(rand(1,N)-0.5);
y=y_range*(rand(1,N)-0.5);
z=z_range*(rand(1,N)-0.5);

% Generating scatterers that is resembles the vessel wall

N_ex=1000;

x_ex=x_range*(rand(1,N_ex)-0.5);

radius_ex=rand(1,N_ex)*0.0003+R;
angle_ex=(rand(1,N_ex)-0.5)*2*pi;

[y_ex,z_ex]=pol2cart(angle_ex,radius_ex);


% All scatterer positions

x=[x x_ex];
   
y=[y y_ex];
   
z=[z z_ex];


% Assign an amplitude and a velocity for each scatterer.

v0=0.5;                   % Largest velocity of scatteres [m/s]

blood_to_stationary=0.1;  % Ratio between amplitude of blood to stationary
                          % tissue.
			  
amp=randn(N+N_ex,1);      % Initializing amplitudes.

 

Tprf=1/fprf;      % Time between pulse emissions [s]. 
Nshoots=fprf;     % Number of shoots. 


% Loading of file containing blood velocity profiles generated from Womersley's
% velocity model.

 eval('load velocity;');

  
% Estimation of dilation values due to pulsation for one cycle

  cyclesteps=0:Tprf:(1-Tprf);
  deltaR_puls=(1.05*sin(pi*cyclesteps).*exp(-2.7*cyclesteps)/1000);

% Estimation of dilation values due to breathing

  timeresp=0:Tprf:(5-Tprf);
  movResp=abs(0.0004*sin(2*pi*timeresp/9));

  for m=1:Nshoots
    m

  [angleP,radius]=cart2pol(y,z);

% Adjustment of radius as a function of time is included due to the 
% movement of the vessel wall because of the pulsation of the heart.
% The change in radius of scatterer - relative to center of vessel -
% depends on whether the scatterer is lying within or outside the vessel,
% and the change is damped the further away from the vessel center the 
% scatterer is positioned.

  timePulse=mod(m,fprf);

   if timePulse==0
     timePulse=fprf;
   end  

  within_vessel=radius<R;

 
  radiusN=radius+deltaR_puls(timePulse)*(radius.*within_vessel/R)...
     +deltaR_puls(timePulse)*(1-radius./R_scanrange).*(1-within_vessel);
     
  Rnew=R+deltaR_puls(timePulse);

  [yP,zP]=pol2cart(angleP,radiusN);

  r_rel=radiusN/Rnew;
  r_rel_index=round(r_rel/0.0025)+1;
  

% Index that controls assignment of the velocities obtained from
% from the velocity profile matrix.
% In the matrix the velocities are ordered according to relative radius 
% - equal to : radius_scatterer/radius_of_vessel.
% Index 401 indicates velocity=0 m/s.
  
  index_final=r_rel_index.*within_vessel+(1-within_vessel)*401;

% Assign new velocity for each scatterer.

  velocity=profiles(index_final,timePulse)';


  ampN1=amp.*(within_vessel*blood_to_stationary)';
  
  within_wall1=(radius>=R);
  within_wall2=(radius<Rwv);
  within_wall=bitand(within_wall1,within_wall2);
  
% Weighting of the influence from vessel wall scatterers
  
  ampN2=amp.*(within_wall.*(sin(angleP).^2)*6)';
  
  outside=(radius>=Rwv);  
  ampN3=amp.*(outside)';
  
  
  ampNow=ampN1+ampN2+ampN3;

% Generate the rotated and offset block of sample
  
    theta=45/180*pi;
    xnew=x*cos(theta)+zP*sin(theta);
    znew=zP*cos(theta)-x*sin(theta)+z_depth;
    znew=znew-(movResp(m)*znew/0.032);



  % Save the matrix with the values

   positions=[xnew; yP; znew;]';


  % Including an "offset" scatterer that will make the RF lines have the
  % same start time, and also a stop scatterer.
   
   offset1=[0 0 0.002]; 
   offset2=[0 0 0.058]; 

   positions=[offset1
              positions
	      offset2];

   ampNow=[0
           ampNow
	   0];

 
   filename=['Position/pos_simMW' num2str(m)];
   save(filename,'positions','ampNow');
   clear positions
 
 
   
  %  Propagate the scatterers and aliaze them
  %  to lie within the correct range
  
    x1=x;
    x=x+velocity*Tprf;
    outside_range=(x>x_range/2);
    x=x-x_range*outside_range;


    
 end
