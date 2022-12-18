%%*****************************CREATE RAW TEST DATA************************
%% also create data
maxFrames=10;
frameSize_rc=[1040,256];
%shiftAmount=[ 0 1 2 3 4 5 6 5 4 3 2 1 0];
shiftAmount=[ 6 5 4 3 2 1 0 1 2 3 4 5 6];
A_all=randn(frameSize_rc(1)+10,frameSize_rc(2)+10);
A_all(500:512,100:112)=3;

Im=zeros(frameSize_rc(1),frameSize_rc(2),maxFrames);

for ii=1:size(Im,3)
    totalShift(ii)=shiftAmount(mod(ii,length(shiftAmount))+1);
    Im(:,:,ii)=A_all((1:frameSize_rc(1))+totalShift(ii),(1:frameSize_rc(2))+totalShift(ii));
end


f1=figure;
for ii=1:size(Im,3)
    figure(f1);
    imagesc(Im(:,:,ii));
    pause(1)
end

save(['test_linear_dn_data.mat'],'Im');




%% create a circle
maxFrames=20;
frameSize_rc=[1040,256];
% shiftAmountRow=[ 0 1 2 3 4 5 6 5 4 3 2 1 0];
% shiftAmountColumn=[ 0 1 2 3 4 5 6 5 4 3 2 1 0];

theta=linspace(0,360,maxFrames)*(pi/180);
shiftAmountRow=round((sin(theta)+1)*5);
shiftAmountColumn=round((cos(theta)+1)*5);
A_all=randn(frameSize_rc(1)+20,frameSize_rc(2)+20);

A_all(500:512,100:112)=3;

Im=zeros(frameSize_rc(1),frameSize_rc(2),maxFrames);

for ii=1:size(Im,3)
    totalShiftRow(ii)=shiftAmountRow(mod(ii,length(shiftAmountRow))+1);
    totalShiftColumn(ii)=shiftAmountColumn(mod(ii,length(shiftAmountColumn))+1);
    Im(:,:,ii)=A_all((1:frameSize_rc(1))+totalShiftRow(ii),(1:frameSize_rc(2))+totalShiftColumn(ii));
end


f1=figure;
for ii=1:size(Im,3)
    figure(f1);
    imagesc(Im(:,:,ii));
    axis([50 150 300 600])
    colormap(gray)
    pause(.3)
end

save(['test_data_circle_small.mat'],'Im');


%% Line angle
maxFrames=20;
frameSize_rc=[1040,256];

shiftAmountColumn=[ 0:(maxFrames-1)];
shiftAmountRow=round(tand(15)*shiftAmountColumn);

A_all=randn(frameSize_rc(1)+20,frameSize_rc(2)+20);

A_all(500:512,100:112)=3;

Im=zeros(frameSize_rc(1),frameSize_rc(2),maxFrames);

for ii=1:size(Im,3)
    totalShiftRow(ii)=shiftAmountRow(mod(ii,length(shiftAmountRow))+1);
    totalShiftColumn(ii)=shiftAmountColumn(mod(ii,length(shiftAmountColumn))+1);
    Im(:,:,ii)=A_all((1:frameSize_rc(1))+totalShiftRow(ii),(1:frameSize_rc(2))+totalShiftColumn(ii));
end


f1=figure;
for ii=1:size(Im,3)
    figure(f1);
    imagesc(Im(:,:,ii));
    axis([50 150 300 600])
    colormap(gray)
    pause(.3)
end

save(['test_data_line_angle.mat'],'Im');
%% *************************************CREATE CORR TEST DATA ***********************
%% generate test lattice
latticeTest=zeros(128,199);

maxShift=3;
x=randn(size(latticeTest,1)+maxShift*2,1);
x=x-min(x);
xTranslate=maxShift*sin(6*2*pi*(0:(size(latticeTest,2)-1))/size(latticeTest,2));

for ii=1:length(xTranslate)
    latticeTest(:,ii)=interp1((-maxShift:(size(latticeTest,1)-1+maxShift)),x,(0:(size(latticeTest,1)-1))+xTranslate(ii),'spline');
end

figure;
imagesc(latticeTest)
colormap(gray);
%%
[roiOut]=calc1DTrack(caseFile,roiList,latticeTest,'showGraphics',true, ...
    'compute1DSpeckleTrackOptions',{'corrInterpMethod','spline','templateFrameOffset',-3});

[imH,figH]=showTrackBlock(caseFile,roiList,roiOut,latticeTest)
