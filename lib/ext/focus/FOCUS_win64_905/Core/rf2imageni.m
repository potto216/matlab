function bimage = rf2imageni(image_data,xalines,c,fs,minz,maxz,window,level,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if(nargin == 8)
    Ndec = 25;
else
    Ndec = varargin{1};
end
if(nargin >= 10)
    zshift = varargin{2};
else
    zshift = 0;
end
if(nargin >= 11)
    maxx = varargin{3};
else
    maxx = max(xalines(:));
end

image_data=image_data(1:Ndec:end,:);

[~,m]=size(image_data);

for i=1:m
  imagedata(:,i) = 20*log10(abs(hilbert(image_data(:,i))));
end

% imagedata = (imagedata - max(max(imagedata)));

maxm = round(2*maxz/Ndec/c*fs);

pcolor(1e3*xalines,1e3*((0:(maxm-1))/fs*Ndec*c/2-zshift),imagedata(1:maxm,:));
caxis([level-window/2 level+window/2]);
colormap(gray)
% shading FLAT;
shading interp;
axis('image')
axis([-1e3*maxx 1e3*maxx 1e3*(minz-zshift) 1e3*(maxz-zshift)]);
set(gca,'YTick',0:10:1e3*maxz);
set(gca,'FontSize',15);
set(gca,'TickDir', 'out');
xlabel('x (mm)');
ylabel('z (mm)');
drawnow

bimage = imagedata(1:maxm,:);
end

