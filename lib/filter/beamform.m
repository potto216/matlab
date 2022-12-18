%RF is in the form axial, lateral elements in aperture, aperture response
%sequence

function beamform(RF,dx_m,fs,c_mPerSec,tstart_sec)
min_sample=0;
dz_m=1/fs*c_mPerSec/2;
lDistance_mm=((0:(size(RF,2)-1))*dx_m-size(RF,2)*dx_m/2)*1000;
aDistance_mm=((0:(size(RF,1)-1))/fs+min_sample/fs)*c_mPerSec/2*1000;
dz_mm=dz_m*1000;
dx_mm=dx_m*1000;

%show prebeamformed data
if false
    %%
    %figure; imagesc(lDistance_mm,aDistance_mm,(abs(RF(:,:,1)))); colormap(gray(256));
    transmitElement=128;
    figure; imagesc(lDistance_mm,aDistance_mm,(abs(RF(:,:,transmitElement)).^0.5)); colormap(gray(256));
    xlabel('lateral (mm)');
    ylabel('axial (mm)');
    title(['Transmit Element = ' num2str(transmitElement) ' tstart = ' num2str(tstart_sec) 'sec ']);
end


%%
Na=size(RF,2); %aperture size

xAxis_mm=[-Na:Na]*dx_mm;
channelDelay_mm=abs(xAxis_mm);
xArray_mm=channelDelay_mm;
transmitChannelIndex=Na+1;

z_mm=[0:(size(RF,1)-1)]'*dz_mm;
%z_sec=2*(z_mm/1000)/c_mPerSec; %this includes the return time
z_sec=(z_mm/1000)/c_mPerSec; %no return time

%figure; plot(z_sec,z_mm)

%this is the extra length that the point will travel to the array element.
%This will be used to correct the time it takes for the signal to travel
%the full distance
distanceToFp_mm=sqrt(repmat(xArray_mm.^2,length(z_mm),1)+repmat(z_mm.^2,1,length(xArray_mm)));
%roundTripTimeToFp_sec=2*(distanceToFp_mm/1000)/c_mPerSec; %this includes the return time
roundTripTimeToFp_sec=(distanceToFp_mm/1000)/c_mPerSec; %this includes the return time

if false
    %% debug code to compare the depth and delay calcs
    figure;
    subplot(1,2,1)
    imagesc(channelDelay_mm,z_mm,distanceToFp_mm); colormap(jet(256)); colorbar
    xlabel('channel # 0 is center')
    ylabel('depth (mm)')
    
    
    subplot(1,2,2)
    imagesc(channelDelay_mm,z_mm,roundTripTimeToFp_sec); colormap(jet(256)); colorbar
    xlabel('channel # 0 is center')
    ylabel('time (sec)')
end


% focusDelays_mm=sqrt(repmat(xArray_mm.^2,length(z_mm),1)+repmat(z_mm.^2,1,length(xArray_mm)))-repmat(z_mm,1,length(xArray_mm));
% %The delay time includes the return time so it is in seconds and it is the
% %extra time needed for the signal to travel from the center focus line to the outer array element.  Therefore return
% focusDelays_sec=2*(focusDelays_mm/1000)/c_mPerSec;
% maxDelay_sec=max(focusDelays_sec(:));
% useFocusDelays_sec=maxDelay_sec-focusDelays_sec;

scanlineX=zeros(size(RF,1),size(RF,2));
w=ones(Na,1);
w=hanning(Na);

if false
    figure;
    plot(roundTripTimeToFp_sec(:,1),'b');
    hold on;
    plot(roundTripTimeToFp_sec(:,Na/2),'r');
    xlabel('sample #')
    ylabel('sec')
    %return
end


%Loop over the transmit element.  In this case all elements receive, but
%the index number corresponds with the element that is transmitting.  this
%needs to be centered on the carrier
if Na~=size(RF,2)
    error('Only works when the aperture is the complete receive array');
end

for trxii=1:Na  %loop over the transmitting elements
    rcvChannels=1:Na;
    aX=RF(:,rcvChannels,trxii);
    ascX=zeros(size(aX));
    fprintf(1,'%d of %d\n',trxii,Na);
    
    %Example 128 elements
    %So when trx =1 the rcv ranges from 1 to 128
    %roundTripTimeToFp_sec should be centered 129:256
    %when trx=2
    %roundTripTimeToFp_sec should be centered 128:256
    %when trx=3
    %roundTripTimeToFp_sec should be centered 127:255
    %...
    %when trx=128
    %roundTripTimeToFp_sec should be centered 2:129
    validPosition=[transmitChannelIndex-trxii+1:(transmitChannelIndex-trxii+Na)];
    for jj=1:size(aX,2)        
        ascX(:,jj)=interp1(z_sec,aX(:,jj),roundTripTimeToFp_sec(:,validPosition(jj)),'pchip',0);
        if false
            %%
            jj=1
            figure; 
            plot(aX(:,jj))
            hold on
            plot(ascX(:,jj))            
        end
            
    end
    if false
        %%
       figure; 
       subplot(1,2,1)
       imagesc(abs(aX)); colormap(gray(256))
       subplot(1,2,2)
       imagesc(abs(ascX)); colormap(gray(256))
       figure; imagesc(abs(aX)); colormap(gray(256)); xlabel('elements'); ylabel('axial')
    end
       
    
    
    scanlineX(:,trxii)=ascX*w;
    
    if false
        %% debug code to look at a specfic apodozation.  There should be horizontal allignment if
        % it is all working
        figure;
        ax(1)=subplot(1,2,1)
        imagesc(channels,z_mm,abs(aX)); colormap(gray(256))
        title('prebeamformed')
        xlabel('channel number')
        ylabel('mm')
        
        ax(2)=subplot(1,2,2)
        imagesc(channels,z_mm,abs(ascX)); colormap(gray(256))
        linkaxes(ax,'xy');
        title('postbeamformed')
        xlabel('channel number')
        ylabel('mm')
        return
    end
end

figure;
subplot(1,2,1)
imagesc(xAxis_mm,z_mm,mean(abs(RF),3).^.5); colormap(gray(256));
title('prebeamformed')
xlabel('mm')
ylabel('mm')

subplot(1,2,2)
imagesc(xAxis_mm,z_mm,abs(scanlineX).^0.5); colormap(gray(256));
title('postbeamformed')
xlabel('mm')
ylabel('mm')
disp('done');