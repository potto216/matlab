% function [oe,zcrs,par,FIo,FIe,FBo,FBe] = quadeg(I,par);
% Input:
%    I = image
%    par = vector for 4 parameters, default = [8,1,21,3]
%      [number of filter orientations, number of scales, filter size, elongation]
%      To use any of the default values, put 0.
% Output:
%    oe = orientation energy
%    zcrs = zero crossing
%    par = actual par used
%    [FIo,FIe] = odd and even filter responses
%    [FBo,FBe] = odd and even filters
%

% Stella X. Yu, July 9 2003

function [oe2D,zcrs,par,FIo,FIe,FBo,FBe] = orientEnergy2D(I,par);

[r,c,k] = size(I);
if k>1,
    I = rgb2gray(I);
end    

% any missing parameter is substituted by a default value
def_par = [8,1,21,3];
if nargin<2 | isempty(par),
   par = def_par;
end
par(end+1:4)=0;
j = (par>0);
par = par .* j + def_par .* not(j);
% make the filter size an odd number so that the responses are not skewed
if mod(par(3),2)==0, par(3) = par(3)+1; end
j = num2cell(par);
[n_filter,n_scale,winsz,enlong] = deal(j{:});

% filter the image with quadrature filters
FBo = make_filterbank_odd2(n_filter,n_scale,winsz,enlong);
FBe = make_filterbank_even2(n_filter,n_scale,winsz,enlong);
n = ceil(winsz/2);
f = [fliplr(I(:,2:n+1)), I, fliplr(I(:,c-n:c-1))];
f = [flipud(f(2:n+1,:)); f; flipud(f(r-n:r-1,:))];
FIo = fft_filt_2(f,FBo,1); 
FIo = FIo(n+[1:r],n+[1:c],:);
FIe = fft_filt_2(f,FBe,1);
FIe = FIe(n+[1:r],n+[1:c],:);

lst = [5 6 7 8 1 2 3 4];
% at each orientation compute the orientation energy 
% which is a sum of odd and even filter outputs
for i=1:8
  % 1D oriented energy  
  oe1D(:,:,i) = sqrt(FIo(:,:,i).^2 + FIe(:,:,i).^2);
end;

% 2D oriented energy sum of 1D energies along particular 
% orientation and orientation perpecdicular to it
for i=1:8
  f = [fliplr(oe1D(:,2:n+1,i)), I, fliplr(oe1D(:,c-n:c-1,i))];
  f = [flipud(f(2:n+1,:)); f; flipud(f(r-n:r-1,:))];
  temp1_2D = fft_filt_2(f,FBo(:,:,lst(i)),1); 
  % size(temp1_2D)
  % [i, n,r,c]
  temp1_2D = temp1_2D(n+[1:r],n+[1:c]);
  temp2_2D = fft_filt_2(f,FBe(:,:,lst(i)),1);
  temp2_2D = temp2_2D(n+[1:r],n+[1:c]);
  oe2D(:,:,i) = sqrt(temp1_2D.^2 + temp2_2D.^2);
end

oe = sum(oe2D,3);
[oem,max_id] = max(FIo.^2+FIe.^2,[],3);

oe = oe / max(oe(:));
np = r * c;
zcrs = reshape(FIe([1:np]'+(max_id(:)-1)*np),[r,c]);
zcrs = (zcrs>=0) - (zcrs<0);