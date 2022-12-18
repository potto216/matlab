%This function will display the rf phase for an ultrasound sequence
%
%caseFile - The filename of the case
%
%ultrasonixGetFrameParms - The parameters to configure the ultrasonix get
%
%%displayFcn - this is the function used to display the results on the
%screen for the user.  Its default is @(x) = abs(x).^0.5 which reduces the dynamic
%range of the image, but to see the full range of the RF (+-) you could
%pass in a function @(x) absIfIM(x).  The key point is this should be an
%anonymous function.
%
%commandLineOnly - this command is used to output data that has been
%automatically processed.  This is useful to compute the temporal frequency
%of the shear wave
%
%FrameStart the frame to start at for the processing.  This defaults to 0.
function showRFPhase(caseFile,varargin)

p = inputParser;   % Create an instance of the class.
p.addRequired('caseFile', @(x) ischar(x) || isstruct(x));
p.addParamValue('ultrasonixGetFrameParms',{},@iscell);
p.addParamValue('displayFcn',@(x) abs(x).^0.5,  @(x) isa(x,'function_handle'));
p.addParamValue('commandLineOnly',false,@islogical);
p.addParamValue('frameStart',0,@(x) isnumeric(x) && x>0);

p.parse(caseFile,varargin{:});

ultrasonixGetFrameParms=p.Results.ultrasonixGetFrameParms;
displayFcn = p.Results.displayFcn;
commandLineOnly = p.Results.commandLineOnly;
frameStart = p.Results.frameStart;

%% Load the data and setup the default regions
[metadata]=loadCaseData(caseFile);
caseStr=getCaseName(metadata);


framesToProcess=metadata.validFramesToProcess;

if isempty(framesToProcess)
    [header] = ultrasonixGetInfo(metadata.rfFilename);
    framesToProcess=(1:(header.nframes-1));
end

%% Setup the sampling points which will be used
maxMemoryForArrayInSamples=1500*32*128; %this is the max value to prevent an out of memory error for an array that is too large
maxFrames=floor(maxMemoryForArrayInSamples/(header.w*header.h));
maxFramesToProcess=min(header.nframes,maxFrames);
[imgBlock,header] = ultrasonixGetFrame(metadata.rfFilename,[0:(maxFramesToProcess-1)]+frameStart,ultrasonixGetFrameParms{:});

frameNumber=1;
img=imgBlock(:,:,frameNumber);


%% Sample the image with the spline points and



imgAngle_rad=angle(imgBlock(:,1:end,1:(end-1)).*conj(imgBlock(:,1:end,2:end)));

imgAngleFilt_rad=zeros(size(imgAngle_rad));
for k = 1:size(imgAngle_rad,3)
    imgAngleFilt_rad(:,:,k) = medfilt2(imgAngle_rad(:,:,k),[5,3]);
    imgAngleFilt_rad(:,:,k) = conv2(imgAngleFilt_rad(:,:,k),ones(10,1)/10,'same');
    
end
%imgAngleFilt_rad=imgAngle_rad;


fft_phase = zeros(size(imgAngleFilt_rad,1),size(imgAngleFilt_rad,2));
fft_frequency = zeros(size(imgAngleFilt_rad,1),size(imgAngleFilt_rad,2));
fftBinFreqToRealFreq=make_f(size(imgAngleFilt_rad,3),header.dr);


for k=1:size(imgAngleFilt_rad,1);
    for l=1:size(imgAngleFilt_rad,2)
        sig = squeeze(imgAngleFilt_rad(k,l,:));
        sig = sig - mean(sig);
        sig = sig.*hanning(length(sig));
        %         imgAngleFilt_rad_interp = interp(sig,5);
        imgAngleFilt_rad_fft = (fft(sig));
        
        %only look at the positive frequencies
        [fund_peak_val,fund_peak] = max(abs(imgAngleFilt_rad_fft(1:floor(end/2))));
        
        fft_phase(k,l) = angle(imgAngleFilt_rad_fft(fund_peak));
        fft_frequency(k,l) = fund_peak;

    end;
end


commonFreqBin=mode(fft_frequency(:));
badFreqIdx=find(commonFreqBin~=fft_frequency(:));
freqsNoMatch=length(badFreqIdx)/(size(fft_frequency,1)*size(fft_frequency,2));
disp(['Case ' caseStr ' total frames processed ' num2str(maxFramesToProcess)])
disp(['The most common frequency found is ' num2str(fftBinFreqToRealFreq(commonFreqBin)) 'Hz.'])
disp([num2str(freqsNoMatch*100) '% of the freqs do not match']);

if commandLineOnly
    return;
end


figure; imagesc(fftBinFreqToRealFreq(fft_frequency)); colorbar
xlabel('Lateral  Distance (Scan Line #)')
ylabel('Axial Depth')
title(['Case ' caseStr ' Frequencies before being forced to ' num2str(fftBinFreqToRealFreq(commonFreqBin)) 'Hz.' ' frame start = ' num2str(frameStart) ],'interpreter','none')


%reprocess freqs to match in frequency so that the phase is computed for
%the correct frequencies.
for k=1:length(badFreqIdx)
    
    [badRow,badColumn] = ind2sub(size(fft_frequency),badFreqIdx(k));
    sig = squeeze(imgAngleFilt_rad(badRow,badColumn,:));
    sig = sig - mean(sig);
    sig = sig.*hanning(length(sig));
    imgAngleFilt_rad_fft = (fft(sig));
    
    fft_phase(badRow,badColumn) = angle(imgAngleFilt_rad_fft(commonFreqBin));
    fft_frequency(badRow,badColumn) = commonFreqBin;
    
end





figure; imagesc(fft_phase); colorbar
xlabel('Lateral  Distance (Scan Line #)')
ylabel('Axial Depth')
title(['Case ' caseStr ' Shear Wave Phase Values' ' frame start = ' num2str(frameStart)],'interpreter','none')


fig = figure('KeyPressFcn',{@plotPhase,fft_phase,caseStr,imgAngleFilt_rad,fftBinFreqToRealFreq});
imagesc(displayFcn(img)); colormap(gray);hold on;

xlabel('Lateral  Distance (Scan Line #)')
ylabel('Axial Depth')
title(['Case ' caseStr ' frame start = ' num2str(frameStart) ', temporal frequency found is ' num2str(fftBinFreqToRealFreq(commonFreqBin)) 'Hz.' 10  'Select phase line with "p".'],'interpreter','none')


end



%
% function plotPhase(src,evnt,imgAngle_rad,imgAngleFilt_rad)
%
% if lower(evnt.Character) ~= 'p'
%     return;
% end
%
% saveTitleStr=get(get(get(src,'Children'),'Title'),'String');
% set(get(get(src,'Children'),'Title'),'String',['Select start/stop points with mouse' 10]);
%
% [x,y]=ginput(2);
%
% %if a horizontal line
% if abs(diff(y)/diff(x))<=1
%     y(2)=y(1);
%     plot(x,y,'g')
%     figure;
%     if x(1)>x(2) % swap
%         x=x(end:-1:1);
%     end
%     x=ceil(x);
%     y=ceil(y);
%
%
%     angInfo_rad=squeeze(imgAngle_rad(y(1),(x(1)):(x(2)),:));
%     angInfoLags=zeros(size(angInfo_rad,1),1);
%
%     for ii=1:(size(angInfo_rad,1))
%         [c,lag]=xcorr(angInfo_rad(1,:),angInfo_rad(ii,:));
%         [maxVal, maxValIdx]=max((c));
%         angInfoLags(ii)=lag(maxValIdx);
%     end
%
%     maxlags=20;
%     angInfoFilt_rad=squeeze(imgAngleFilt_rad(y(1),(x(1)):(x(2)),:));
%     angInfoFileLags=zeros(size(angInfoFilt_rad,1),1);
%
%     for ii=1:(size(angInfoFilt_rad,1))
%         [c,lag]=xcorr(angInfoFilt_rad(1,:),angInfoFilt_rad(ii,:));
%         [maxVal, maxValIdx]=max((c));
%         angInfoFiltLags(ii)=lag(maxValIdx);
%         %         figure; plot(lag(maxValIdx),abs(c))
%         %
%         %         figure; plot(squeeze(imgAngleFilt_rad(200,ii+2,:)),'b'); hold on; plot(squeeze(imgAngleFilt_rad(200,ii+22,:)),'r')
%         %         figure; plot(angInfo_rad(ii+2,:),'b'); hold on; plot(angInfo_rad(ii+22,:),'r')
%
%     end
%
%
%     subplot(2,2,1)
%     plot(angInfoLags);
%     title('Not Filt Lags')
%
%     subplot(2,2,2)
%     plot(angInfoFiltLags);
%     title('Filt Lags')
%
%
%     subplot(2,2,3)
%
% %     angInfo_rad=imgAngle_rad(y(1):y(2),x(1),:);
% %     angInfo_rad=angInfo_rad;
%     plot(angInfo_rad.'*180/pi,'b.-')
%     title(['Not filt Phase Run from (x,y) (' num2str(x(1)) ',' num2str(y(1)) ') to (' num2str(x(2)) ',' num2str(y(2)) ')'])
%     xlabel('time(frame #)')
%     ylabel('degrees')
%     ylim([-180 180])
%     %
%     subplot(2,2,4)
%     plot(angInfoFilt_rad.'*180/pi,'b.-')
%     title(['Filt Phase Run from (x,y) (' num2str(x(1)) ',' num2str(y(1)) ') to (' num2str(x(2)) ',' num2str(y(2)) ')'])
%     xlabel('time(frame #)')
%     ylabel('degrees')
%     ylim([-180 180])
%
%     %     plot(unwrap(angInfo_rad)*180/pi,'b.-')
%     %     xlabel('lateral')
%     %     ylabel('degrees')
%     %     title('Unwrapped phase')
%
%
%     figure(src);
% elseif abs(diff(y)/diff(x))>1   %if a vertical line
%     x(2)=x(1);
%     plot(x,y,'g')
%     %        h=msgbox('Can''t do vertical lines yet')
%     %       uiwait(h)
%     figure;
%     if y(1)>y(2) % swap
%         y=y(end:-1:1);
%     end
%
%     x=ceil(x);
%     y=ceil(y);
%     %angInfo=img(y(1):y(2),x(1));
%     %angInfo_rad=angle(angInfo);
%     angInfo_rad=imgAngle_rad(y(1):y(2),x(1));
%
%
%
%     angInfo_rad=angInfo_rad-angInfo_rad(1);
%     subplot(2,1,1)
%     plot(angInfo_rad*180/pi)
%     title(['Phase Run from (x,y) (' num2str(x(1)) ',' num2str(y(1)) ') to (' num2str(x(2)) ',' num2str(y(2)) ')'])
%     xlabel('axial')
%     ylabel('degrees')
%     ylim([-180 180])
%
%     subplot(2,1,2)
%     plot(unwrap(angInfo_rad)*180/pi)
%     xlabel('axial')
%     ylabel('degrees')
%     title('Unwrapped phase')
%
%     figure(src);
% else
%     error('This should never happen')
% end
%
% set(get(get(src,'Children'),'Title'),'String',saveTitleStr);
%
% end

function plotPhase(src,evnt,fft_phase,caseStr,imgAngleFilt_rad,fftBinFreqToRealFreq)
persistent phaseLine

switch(lower(evnt.Character))
    case 'f'
        [x,y]=ginput2(1,'xg');
        x=fix(x);
        y=fix(y);
        sig = squeeze(imgAngleFilt_rad(y,x,:));
        sig = sig - mean(sig);
        sig = sig.*hanning(length(sig));
        imgAngleFilt_rad_fft = (fft(sig));

        plot(x,y,'gx');

        figure;
        plot(fftshift(fftBinFreqToRealFreq),fftshift(20*log10(abs(imgAngleFilt_rad_fft))));
        xlabel('Hz')
        ylabel('dB')
        
        title(['Freq for (' num2str(x) ',' num2str(y) ')']);
        return;

    case 'p'
    otherwise
    return;
end

saveTitleStr=get(get(get(src,'Children'),'Title'),'String');
set(get(get(src,'Children'),'Title'),'String',['Select start/stop points with mouse (use RIGHT click and backspace to delete)' 10]);

[x,y]=ginput2(2,'xr');

%if a horizontal line
if abs(diff(y)/diff(x))<=1
    y(2)=y(1);
    plot(x,y,'g')
    figure;
    if x(1)>x(2) % swap
        x=x(end:-1:1);
    end
    x=ceil(x);
    y=ceil(y);
    
    
    %angInfo_rad=squeeze(imgAngle_rad(y(1),(x(1)):(x(2)),:));
    fftPhaseStrip=fft_phase(y(1),(x(1):x(2)));
    
    
    
    subplot(2,1,1)
    plot((x(1):x(2)).'*18.12/33,fftPhaseStrip.'*180/pi,'b.-')
    title(['Phase Strip Run from (x,y) (' num2str(x(1)) ',' num2str(y(1)) ') to (' num2str(x(2)) ',' num2str(y(2)) ')'])
    xlabel('Lateral  Distance (mm)')
    ylabel('degrees')
    ylim([-180 180])
    %
    subplot(2,1,2)
    plot((x(1):x(2)).'*18.12/33,unwrap(fftPhaseStrip).'*180/pi,'b.-')
    title(['Unwrapped Phase Strip Run from (x,y) (' num2str(x(1)) ',' num2str(y(1)) ') to (' num2str(x(2)) ',' num2str(y(2)) ')'])
    xlabel('Lateral  Distance (mm)')
    ylabel('degrees')
    
    figure(src);
elseif abs(diff(y)/diff(x))>1   %if a vertical line
    x(2)=x(1);
    plot(x,y,'g')
    %        h=msgbox('Can''t do vertical lines yet')
    %       uiwait(h)
    figure;
    if y(1)>y(2) % swap
        y=y(end:-1:1);
    end
    
    x=ceil(x);
    y=ceil(y);
    
    fftPhaseStrip=fft_phase(y(1):y(2),x(1));
    
    subplot(2,1,1)
    plot(fftPhaseStrip.'*180/pi,'b.-')
    title(['Phase Strip Run from (x,y) (' num2str(x(1)) ',' num2str(y(1)) ') to (' num2str(x(2)) ',' num2str(y(2)) ')'])
    xlabel('Lateral  Distance (Scan Line #)')
    ylabel('degrees')
    ylim([-180 180])
    %
    subplot(2,1,2)
    plot(unwrap(fftPhaseStrip).'*180/pi,'b.-')
    title(['Unwrapped Phase Strip Run from (x,y) (' num2str(x(1)) ',' num2str(y(1)) ') to (' num2str(x(2)) ',' num2str(y(2)) ')'])
    xlabel('Lateral  Distance (Scan Line #)')
    ylabel('degrees')
    
    figure(src);
else
    error('This should never happen')
end

phaseLine(end+1).phase_deg=unwrap(fftPhaseStrip(:))*180/pi;
phaseLine(end).run.x=x*18.12/33;
phaseLine(end).run.y=y;
phaseLine(end).caseStr=caseStr;
phaseLine(end).sOutputText=['Phase Strip Run from (x,y) (' num2str(x(1)) ',' num2str(y(1)) ') to (' num2str(x(2)) ',' num2str(y(2)) ')'];
text(x(1)-1.5,y(1),num2str(length(phaseLine)),'Color',[0 1 0],'FontSize',12)

assignin('base', 'phaseLine', phaseLine)

set(get(get(src,'Children'),'Title'),'String',saveTitleStr);

end
