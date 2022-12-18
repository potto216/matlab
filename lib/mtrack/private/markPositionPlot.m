function [ results ] = markPositionPlot(trialName,rfBasefilename, report )
%MARKPOSITIONPLOT Summary of this function goes here
%   Detailed explanation goes here
t_sec=report.ultrasound.t_sec;
dSmooth_mm=report.ultrasound.dSmooth_mm;
dBackwardSmooth_mm=report.ultrasound.dBackwardSmooth_mm;
distanceMeasure=report.distanceMeasure;

fc=createFigure;

%Peak detect, btu did not work very well
absF=abs(fft(dSmooth_mm-mean(dSmooth_mm)));
[~,periodsPerWaveform]=max(absF(1:floor(end/2)));
periodLengthInSamples=length(dSmooth_mm)/periodsPerWaveform;
%This is for the peak search and
%since we take the absolute value the freq is doubled then
%we assume that the peak distance will be no more than a half of that. so we
%have a min distance of
minPeakDistance_sample=periodLengthInSamples/(2*2);

[~,locationIndex] = findpeaks(abs(dSmooth_mm),'MINPEAKDISTANCE',floor(minPeakDistance_sample));


plot(t_sec(locationIndex),dSmooth_mm(locationIndex),'xr');
hold on
hForSmooth=plot(t_sec,dSmooth_mm,'linewidth',1,'Color',0.7*[0 0 1]);

%    dcmObj=makedatatip(hForSmooth,locationIndex);

xlabel('time (sec)');
ylabel('displacement (mm)');
title(['Smoothed Muscle Displacement for ' trialName ' file ' rfBasefilename  ' distance metric ' distanceMeasure.key ],'interpreter','none');
legend(hForSmooth,  'forward smoothed');
disp('Mark Position Plot');
hMsg = msgbox('Close this message box after you have marked the datapoints to the workspace (red are the autodetected peaks).');
uiwait(hMsg)
dcmObj=datacursormode(fc);

cursorInfo=dcmObj.getCursorInfo;
if ~isempty(cursorInfo)
    targetList=arrayfun(@(x) x.Target,cursorInfo);
    
    getPositionDataAsCell=@(targetId) arrayfun(@(x) x.Position',cursorInfo(targetList==targetId),'UniformOutput',false);
    getPositionData=@(targetId) cell2mat(fliplr(getPositionDataAsCell(targetId)));
    
    figFilename=[strrep([trialName '_' rfBasefilename '_forward'],'.','_') '.fig'];
    saveas(fc,figFilename,'fig');
    
    results.ultrasound.forwardTrackPositionMarked_sec_mm=getPositionData(hForSmooth);
    [~,si]=sort(results.ultrasound.forwardTrackPositionMarked_sec_mm(1,:));
    results.ultrasound.forwardTrackPositionMarked_sec_mm=results.ultrasound.forwardTrackPositionMarked_sec_mm(:,si);
end

close(fc);


fc=createFigure;
hBackSmooth=plot(t_sec,dBackwardSmooth_mm,'linewidth',1,'Color',0.7*[1 0 1]);

xlabel('time (sec)');
ylabel('displacement (mm)');
title(['Smoothed Muscle Displacement for ' trialName ' file ' rfBasefilename  ' distance metric ' distanceMeasure.key],'interpreter','none');
legend( hBackSmooth, 'backward smoothed');
disp('Mark Position Plot');
hMsg = msgbox('Close this message box after you have marked the datapoints to the workspace.');
uiwait(hMsg);
dcmObj=datacursormode(fc);

cursorInfo=dcmObj.getCursorInfo;
if ~isempty(cursorInfo)
    targetList=arrayfun(@(x) x.Target,cursorInfo);
    
    getPositionDataAsCell=@(targetId) arrayfun(@(x) x.Position',cursorInfo(targetList==targetId),'UniformOutput',false);
    getPositionData=@(targetId) cell2mat(fliplr(getPositionDataAsCell(targetId)));
    
    figFilename=[strrep([trialName '_' rfBasefilename '_backward'],'.','_') '.fig'];
    saveas(fc,figFilename,'fig');
    
    results.ultrasound.backwardTrackPositionMarked_sec_mm=getPositionData(hBackSmooth);
    
    [~,si]=sort(results.ultrasound.backwardTrackPositionMarked_sec_mm(1,:));
    results.ultrasound.backwardTrackPositionMarked_sec_mm=results.ultrasound.backwardTrackPositionMarked_sec_mm(:,si);
    
end
close(fc);

end

function fh=createFigure
fh=figure;
end
