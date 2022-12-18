% Creates a phantom for a fetus The size of the image is 100 x 60 (width and depth) 
% and the thickness is 15 mm. The phantom starts 20 mm from the transducer surface.
% 
%  Example by Jørgen Arendt Jensen and Peter Munk, Ver. 1, March 26, 1997.

function [positions, amp] = feu_pha(N_tot)

% The total number of scatterers is N_tot=N*N_group
% memory problems forces to split the calculation up in parts
% The sub calculation size is 1000

N=1000;
N_group=floor(N_tot/N);
if N_group~=(N_tot/N)
 error('Group split is not a multiplum of the total number of scatterers');
 end

% Define image coordinates

x_size = 100/1000 ;
z_size = 60/1000 ;
y_size = 15/1000;

z_start = 20/1000;

% Load input baby map

[fetus,MAP]=bmpread('fetus.bmp');

%  Find the white structures and generate data for them

index=1;
strong = (fetus > 250);
[n,m]=size(strong);
for i=1:n
disp([num2str(i/n*100),' % finished'])
  for j=1:m
    if (strong(i,j))
      strong_pos(index,:) = [(j/m-0.5)*x_size 0 i/n*z_size+z_start];
      index=index+1;
      end
    end
  end
disp([num2str(i),' strong pixel values found'])


for mm=1:N_group
mm

  % calculate position data

  x0 = rand(N,1);
  x = (x0-0.5)* x_size;
  z0 = rand(N,1);
  z = z0*z_size+z_start;
  y0 = rand(N,1);
  y = (y0-0.5)* y_size; 

  positions((mm-1)*N+(1:N),:) = [x y z];

  % Amplitudes with different variance must be generated according to the the 
  % input map.
  % The amplitude of the fetus image is used to scale the variance

  var_value(:,mm)=diag(fetus(fix([1+z0*(size(fetus,1)-1)]),fix([1+x0*(size(fetus,2)-1)])));
  amp(:,mm)=var_value(:,mm).*randn(size(var_value,1),1);

  end

%  Make it into column vectors

%  var_value=reshape(var_value,N*N_group,1);

amp=reshape(amp,N*N_group,1);

%  Include the strong scatterers

positions=[positions; strong_pos];
amp=[amp; N_tot/index*20*ones(index-1,1)];

end

