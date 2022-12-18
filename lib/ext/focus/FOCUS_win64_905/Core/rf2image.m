function bimage = rf2image(image_data,xalines,c,fs,minz,maxz,window,level,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if(nargin == 8)
    Ninterp = 10;
else
    Ninterp = varargin{1};
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

[n,m]=size(image_data);

for i=1:m
  imagedata(:,i) = 20*log10(abs(hilbert(image_data(:,i))));
end

% imagedata = (imagedata - max(max(imagedata)));

%  Make an interpolated image



interpdata=zeros(n*Ninterp,m);
if (Ninterp~=1)
  for i=1:m
    interpdata(:,i)=interp(imagedata(:,i),Ninterp);
  end
else
  interpdata=imagedata;
end;

maxm = round(2*maxz/c*fs*Ninterp);

pcolor(1e3*(xalines),1e3*((0:(maxm-1))/fs*c/Ninterp/2-zshift),interpdata(1:maxm,:));
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

bimage=interpdata(1:maxm,:);
end

