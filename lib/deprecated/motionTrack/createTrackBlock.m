%When given a spline this function creates a tracking block  of data
%roiOut will be 1 greater than the list because the last value is the
%highest correlation values possible out of all the matches.
%
%ultrasonixGetFrameParms - The parameters to configure the ultrasonix get
%frame function.
%
function [sOutputFilename,mmodeImg,roiOut,splineData]=createTrackBlock(caseFile,roiList,activeSplineIndex,varargin)
%% Load the data and setup the default regions

p = inputParser;   % Create an instance of the class.
p.addRequired('caseFile', @ischar);
p.addRequired('roiList', @(x) isstruct(x) && isvector(x));
p.addRequired('activeSplineIndex', @(x) isscalar(x) && isnumeric(x));
p.addParamValue('showGraphics',{},@(x) islogical(x) && isscalar(x));
p.addParamValue('commentTag',[],@(x) true); %can be anything
p.addParamValue('ultrasonixGetFrameParms',{},@iscell);

p.parse(caseFile,roiList,activeSplineIndex,varargin{:});

showGraphics=p.Results.showGraphics;
commentTag=p.Results.commentTag;
ultrasonixGetFrameParms=p.Results.ultrasonixGetFrameParms;

[metadata]=loadCaseData(caseFile);
caseStr=getCaseName(metadata);

load(metadata.splineFilename,'splineData');

axisRange=metadata.axisRange;
framesToProcess=metadata.validFramesToProcess;

if isempty(framesToProcess)
    [header] = ultrasonixGetInfo(metadata.rfFilename);
    framesToProcess=(1:(header.nframes-1));
end

%% Setup the sampling points which will be used
%plot image incase need to get new values
[img,header] = ultrasonixGetFrame(metadata.rfFilename,1,ultrasonixGetFrameParms{:});

samplePoints_rc=splineSample(splineData(activeSplineIndex).controlpt.x,splineData(activeSplineIndex).controlpt.y,size(img,2));

if showGraphics
    fig = figure();
    imagesc(abs(img).^0.5); colormap(gray);

    yy = spline(splineData(activeSplineIndex).controlpt.x,splineData(activeSplineIndex).controlpt.y,(1:size(img,2)));
    hold on; plot(yy,'y'); hold off;
    title(caseStr,'interpreter','none')



    figure;
    imagesc(abs(img).^0.5); colormap(gray);
    hold on; plot(yy,'y');
    plot((1:size(img,2)),yy,'ro')
    plot(samplePoints_rc(2,:),samplePoints_rc(1,:),'go')
    legend('spline','old sampling','new sampling');
    hold off;
    title(caseStr,'interpreter','none')
end


%% Sample the image with the spline points and
mmodeImg = zeros(size(img,2),length(framesToProcess));
for ii=1:length(framesToProcess)
    frameNumber=framesToProcess(ii);
    [img,header] = ultrasonixGetFrame(metadata.rfFilename,frameNumber,ultrasonixGetFrameParms{:});
    mmodeLine=computeCurvedMMode(abs(img).^0.5, samplePoints_rc);
    %    mmodeLine=computeCurvedMMode(abs(img).^0.5, yy);
    mmodeImg(:,ii) = mmodeLine;


    if showGraphics
        figure(1);
        subplot(8,1,1:4); imagesc(abs(img(400:end,:)).^0.5); colormap(gray);hold on; plot(yy-400,'y'); hold off; set(gca,'XTickLabel',''); ylabel('Depth')

        subplot(8,1,5:8); imagesc(mmodeImg'); xlabel('Lateral distance'); ylabel('Frames');
    end
end


%% Perform correlation match
trackcolors={'y','r','g','b','c','m'};
if showGraphics
    f1=figure;
    imagesc(mmodeImg); colormap(gray); hold on;
end

for jj=1:length(roiList)
    roiOut(jj).corrMatch = zeros(length(framesToProcess),1); %#ok<AGROW>
    roiOut(jj).corrMaxVal = zeros(length(framesToProcess),1); %#ok<AGROW>
    roiOut(jj).corr= zeros(roiList(jj).search(end)-length(roiList(jj).template)-roiList(jj).search(1)+1,length(framesToProcess)); %#ok<AGROW>
    roiOut(jj).commentTag=commentTag;
    for ii=1:length(framesToProcess)
        [roiOut(jj).corrMatch(ii),roiOut(jj).corrMaxVal(ii), roiOut(jj).corr(:,ii), roiOut(jj).hitRail(ii)] = compute1DSpeckleTrack(mmodeImg,ii,roiList(jj).template,roiList(jj).search); %#ok<AGROW>
    end
    roiOut(jj).rfMotion = cumsum(roiOut(jj).corrMatch); %#ok<AGROW>
    if showGraphics
        figure(f1);
        plot(roiOut(jj).rfMotion,trackcolors{jj},'Linewidth',2);
        plot(repmat(jj*2,length(roiList(jj).search),1),roiList(jj).search,trackcolors{jj},'Linewidth',1);
        if any(roiOut(jj).hitRail)
            plot(find(roiOut(jj).hitRail),roiOut(jj).rfMotion(roiOut(jj).hitRail),[trackcolors{jj} 'o'],'Linewidth',2);
        end
    end
end

[bestCorrMaxVal bestCorrIndex]=max([roiOut.corrMaxVal],[],2);
roiOut(end+1).corrMaxVal=bestCorrMaxVal;
cm=[roiOut.corrMatch];
%pull out the best correlation lags
roiOut(end).corrMatch=cm(sub2ind(size(cm),reshape(1:size(cm,1),[],1),bestCorrIndex));
roiOut(end).rfMotion = cumsum(roiOut(end).corrMatch);

if showGraphics
    plot(roiOut(end).rfMotion,trackcolors{jj+1},'Linewidth',4);
    hold off;
    xlabel('frames')
    ylabel('lateral distance')
    title([caseStr '.  the bold line is using max of the corr values','interpreter','none'])
end


%% Save the results
sOutputFilename=fullfile(metadata.Speckle1DTrackPath,['ROITrack_' datestr(now,'yyyymmddHHMMSS') '.mat']);
save(sOutputFilename,'roiList','roiOut','mmodeImg','splineData','activeSplineIndex');

end