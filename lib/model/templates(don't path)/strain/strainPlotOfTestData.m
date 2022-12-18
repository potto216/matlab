clear 
%%
dataPath='C:\Documents and Settings\potto\My Documents\localData\Yingying''s data\Phantomdata continuous steps';
datafilename='Car(001)_D.mat';
data=load(fullfile(dataPath,datafilename));
figure; imagesc(sqrt(abs(hilbert(data.b_data150)))); colormap(gray(256));
%%
dataPath='C:\Documents and Settings\potto\My Documents\localData\Yingying''s data\Phantomdata discreteSteps\John\01per';
datafilename='Car(003).mat';
data=load(fullfile(dataPath,datafilename));
figure; imagesc(sqrt(abs(hilbert(data.b_data)))); colormap(gray(256));

%%
dataPath='C:\Documents and Settings\potto\My Documents\localData\Yingying''s data\Phantomdata discreteSteps\John\2er';
datafilename='Car(003).mat';
data=load(fullfile(dataPath,datafilename));
figure; imagesc(sqrt(abs(hilbert(data.b_data)))); colormap(gray(256));


%%
dataPath='C:\Documents and Settings\potto\My Documents\localData\Yingying''s data\Phantomdata discreteSteps\John\01per';
datafilename='Car(003).mat';
data0001_percent=load(fullfile(dataPath,datafilename));

dataPath='C:\Documents and Settings\potto\My Documents\localData\Yingying''s data\Phantomdata discreteSteps\John\1per';
datafilename='Car(003).mat';
data0100_percent=load(fullfile(dataPath,datafilename));


dataPath='C:\Documents and Settings\potto\My Documents\localData\Yingying''s data\Phantomdata discreteSteps\John\2er';
datafilename='Car(003).mat';
data0200_percent=load(fullfile(dataPath,datafilename));


imData=zeros(size(data0001_percent.b_data,1),size(data0001_percent.b_data,2),3);

imData(:,:,1)=sqrt(abs(hilbert(data0001_percent.b_data)));
imData(:,:,2)=sqrt(abs(hilbert(data0100_percent.b_data)));
imData(:,:,3)=sqrt(abs(hilbert(data0200_percent.b_data)));
ax=[];

figure; 
ax(1)=subplot(1,3,1);
imagesc(imData(:,:,1)); colormap(gray(256));
title('0.01% (red)')

ax(2)=subplot(1,3,2);
imagesc(imData(:,:,2)); colormap(gray(256));
title('1% (green)')

ax(3)=subplot(1,3,3);
imagesc(imData(:,:,3)); colormap(gray(256));
title('2% (blue)')

imDatargb=imData;
for ii=1:size(imDatargb,3)
imDatargb(:,:,ii)=imDatargb(:,:,ii)/max(max(imDatargb(:,:,ii)));
end

figure;
imagesc(imDatargb); 
ax(4)=gca;
linkaxes(ax,'xy')



%%
T=randn(size(data0001_percent.b_data));
[ A ] = colvecfun( @(a,b) xcorr(a,b,100), T,T );
figure; imagesc(1:size(A,2),-((size(A,1)-1)/2):((size(A,1)-1)/2),abs(A)); colorbar;


%%
maxShift=100;
[ A ] = colvecfun( @(a,b) xcorr(a,b,maxShift), (data0001_percent.b_data),(data0001_percent.b_data) );
figure; imagesc(1:size(A,2),-((size(A,1)-1)/2):((size(A,1)-1)/2),abs(A)); colorbar;
[~, maxIdxA]=max(abs(A));
if all(maxIdxA==(maxShift+1))
    title('autocorrelation works and max value is zero lag');
else    
    error('autocorrelation failed and max value is not zero lag');
end
 
%%
axp=[];
maxShift=10;
dataRange=[1000:1050];
tfun=@(x) hilbert(x);
tfun=@(x) x;
[ A ] = colvecfun( @(a,b) xcorr(a,b,maxShift,'coeff'), tfun(data0001_percent.b_data(dataRange,:)),tfun(data0100_percent.b_data(dataRange,:)) );
[~, maxIdxA]=max(abs(A));
maxLagA=maxIdxA-(maxShift+1);
figure; 
axp(1)=subplot(6,1,[1:4]);
imagesc(1:size(A,2),-((size(A,1)-1)/2):((size(A,1)-1)/2),abs(A)); colorbar;

xLimTop=get(axp(1),'XLim');
axp(2)=subplot(6,1,5);
plot((xLimTop(1)+0.5):1:(xLimTop(2)-0.5),maxLagA)
axis tight;

axp(3)=subplot(6,1,6);
hist(maxLagA,max(maxLagA)-min(maxLagA)+1)

axisPositionTop=get(axp(1),'Position');
axisPosition=get(axp(2),'Position');
axisPosition(3)=axisPositionTop(3);
set(axp(2),'Position',axisPosition);
xlabel('shift')

%%
tfun=@(x) hilbert(x);
%tfun=@(x) x;
figure;
imagesc(angle(conv2(ones(50,1)/50,tfun(data0100_percent.b_data(:,:)).*conj(tfun(data0200_percent.b_data(:,:)))))); colorbar
