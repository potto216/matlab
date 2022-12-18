%This function compares the IR data to the RF track
function analyzeIRvsRF(caseFile,trackFilename,roiIndex)

switch(nargin)
    case 3
        %do nothing
    otherwise
        error('Invalid number of input arguments.')
end

[metadata]=loadCaseData(caseFile);
caseStr=getCaseName(metadata);

disp(metadata.irFilename);
%% Load the data and setup the default regions
[roiList,roiOut,mmodeImg]=loadTrackBlock(metadata,trackFilename);

irMotion=dlmread(metadata.irFilename);
%% Setup the sampling points which will be used
%the sample ratio is about (RF/IR) 31.7972 samples/94.0092 samples

%120Hz for the IR Motion Capture

rfMotion=roiOut(roiIndex).rfMotion; %#ok<NASGU>


%% Correlate the Ultrasound RF with the IR motion data.
rfMotionRaw=rfMotion;
irMotionRaw=irMotion;

rfFPS=getCaseDataFrameRate(metadata,'rf');
irFPS=getCaseDataFrameRate(metadata,'ir');

rfMotion=rfMotion-mean(rfMotion);

%Do a 1D interp.  Here the RF and IR should be sampled at the sample time
%interval.  Because the RF will be shorter than the IR it must be trimed to
%match the IR.  
if irFPS>rfFPS
    tIr=[0:(length(irMotionRaw)-1)].'/irFPS;
    tRf=[0:(length(rfMotion)-1)].'/rfFPS;  %This is ideal
    
    %trim the time to the end of the 
    tRfNew=tIr(1:find(tIr<=max(tRf),1,'last'));
    if max(tRfNew)>max(tRf)
        error('The new rf time should be less than the old')
    end
    
    %rfMotionCompare=100*resample(rfMotion-mean(rfMotion),irFPS,rfFPS);    
    %rfMotionCompare((end-34):end)=0; %cleanup the resample filter
    rfMotionCompare=interp1(tRf,rfMotion,tRfNew,'spline');
    
    
else
    error('ir fps should be higher than the rf fps')
end




irMotionCompare=irMotion*180/pi;
irMotionCompare=irMotionCompare-mean(irMotionCompare);

%we need to match the RF up to the IR.  The only problem is that the RF is
%saved in a limited size buffer so you know that the end of time for the IR and RF is about
%synced up, but you do not know if the begining is.  therefore we will correlate
%starting from the end and look for a match.  We will do this by flipping
%the buffers around and starting from the end and going to the begining.

[cr,lg]=xcorr(flipud(rfMotionCompare(:)/max(abs(rfMotionCompare))),flipud(irMotionCompare(:)/max(abs(irMotionCompare))));
[mv1, mi1]=max(abs(cr));
irMotionCompare=circshift(irMotionCompare(:),lg(mi1))*sign(cr(mi1));


if false
figure;
subplot(2,1,1);
plot(irMotionCompare/max(abs(irMotionCompare)),'b');
hold on;
plot(rfMotionCompare/max(abs(rfMotionCompare)),'r')
xlabel('count'); ylabel(''); title('Joint Velocity IR vs RF Motion')

subplot(2,1,2);
plot(diff(irMotionCompare),'b');
hold on;
plot(-diff(rfMotionCompare),'r')
xlabel('count'); ylabel(''); title('Joint Velocity IR')




end

%% new plot
f1=figure;
subplot(3,2,2)
plot(lg,cr); xlabel('lag'); ylabel('amplitude');
title(['Crosscorr of Joint Velocity IR and RF motion for ' caseStr],'interpreter','none')


mp=min(length(rfMotionCompare),length(irMotionCompare));
rfMotionCompare=rfMotionCompare(1:mp);
irMotionCompare=irMotionCompare(1:mp);

irMotionCompare=irMotionCompare/max(irMotionCompare)*max(rfMotionCompare);


subplot(3,2,[4 6])
plot(irMotionCompare,'b'); xlabel('count'); ylabel('deg/sec');
hold on
plot(rfMotionCompare,'r')
legend('Joint Velocity IR','RF motion');
title(['Synced Motion shift of ' num2str(lg(mi1)) ' samples'])



%% Try a least squares fit to the data



axLeastsq=subplot(3,2,[1 3 5]);

plot(rfMotionCompare,irMotionCompare,'.'); 

xlabel('RF'); ylabel('Joint Velocity IR');
axv=[min([rfMotionCompare(:); irMotionCompare(:)]) max([rfMotionCompare(:); irMotionCompare(:)])];
xlim(axv);
ylim(axv);


%do a least squares fit
p = polyfit(rfMotionCompare,irMotionCompare,1);
px=axv;
py=polyval(p,px);
hold on
plot(px,py,'r');
legend('data','line fit')
hold off

testIdx=1:length(irMotionCompare);
[b,bint,r,rint,stats] = regress(irMotionCompare(testIdx),[rfMotionCompare(testIdx) ones(size(rfMotionCompare(testIdx),1),1)]);
title(['R squared value is ' num2str(stats(1))]);

set(zoom(f1),'ActionPostCallback',{@zoomCallback,rfMotionCompare,irMotionCompare,axLeastsq});



