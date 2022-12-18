%This function will display the rf motion for the ultrasound and create a movie if required.
%To improve the display the square root of the absolute value is taken.
%>>showRF(caseFile,activeSplineIndex,pair1,value1)
%
%INPUT
%
%caseFile - The filename of the case
%

%
%ureadParms - The parameters to configure the uread function
%
%sampleLattice - if the sample lattice is given then it will be displayed
%in sync with the video output.
%
%framesToShow - This is a vector of the frame numbers (base 1 not base 0)
%to show.
%
%%displayFcn - this is the function used to display the results on the
%screen for the user.  Its default is @(x) = abs(x).^0.5 which reduces the dynamic
%range of the image, but to see the full range of the RF (+-) you could
%pass in a function @(x) absIfIM(x).  The key point is this should be an
%anonymous function.
%
%movieFilename - The filename for the movie, if it is empty no movie will
%be created.  It is assumed this will also include the path.
%frame function.
%
%showSpline - show the spline on the movie
%
%imgClip - This is how much to clip the output image.  It can be a scalar or a
%four element vector.  If a scalar it is the axial row to start on with a
%default of 400.
%
%EXAMPLES
%showRF([],[],'ureadParms',{'decimateLaterial',true,'frameFormatComplex',true});
function showRF(varargin)

p = inputParser;   % Create an instance of the class.
p.addOptional('caseFile',[], @(x) ischar(x) || isstruct(x) || isempty(x) || isa(x,'DataBlockObj'));
p.addOptional('activeSplineIndex', [],@(x) (isscalar(x) && isnumeric(x)) || isempty(x));
p.addParamValue('ureadParms',{},@iscell);
p.addParamValue('framesToShow',[], @(x) (isvector(x) && isnumeric(x)) || isempty(x));
p.addParamValue('movieFilename',{},@(x) (ischar(x) || isempty(x)));
p.addParamValue('movieType',{},@(x) (ischar(x) || isempty(x)));
p.addParamValue('displayFcn',@(x) abs(x).^0.5,@(x) isa(x,'function_handle'));
p.addParamValue('imgClip',400,@(x) (isvector(x) && isnumeric(x)));
p.addParamValue('sampleLattice',[],@(x) (ismatrix(x) && isnumeric(x)) || isempty(x));
p.addParamValue('showSpline',false,@(x) islogical(x));
p.addParamValue('axisToMarkPositionOn',[],@(x) ishandle(x));
p.addParamValue('samplingSkeleton',struct([]),@(x) isstruct(x));





p.parse(varargin{:});
caseFile=p.Results.caseFile;
activeSplineIndex=p.Results.activeSplineIndex;
ureadParms=p.Results.ureadParms;
movieFilename=p.Results.movieFilename;
displayFcn = p.Results.displayFcn;
framesToShow = p.Results.framesToShow;
imgClip = p.Results.imgClip;
sampleLattice = p.Results.sampleLattice;
showSpline = p.Results.showSpline;
axisToMarkPositionOn = p.Results.axisToMarkPositionOn;
samplingSkeleton=p.Results.samplingSkeleton;

if ~isscalar(imgClip)
    error('Only scalar is currently supported for imgClip');
end



%% Load the data and setup the default regions
if isa(caseFile,'DataBlockObj')
    dataBlockObj=caseFile;
    ureadParms=dataBlockObj.openArgs;
    [metadata]=loadCaseData(dataBlockObj.metadata.sourceFilename);
    caseStr=dataBlockObj.activeCaseName;
else
    [metadata]=loadCaseData(caseFile);
    caseStr=getCaseName(caseFile);
end


if isfield(metadata,'splineFilename')  &&  exist(metadata.splineFilename,'file')
    
    
    load(metadata.splineFilename,'splineData');
    
    if isempty(activeSplineIndex)
        activeSplineIndex=getCaseActiveSpline(metadata);
    else
        %do nothing
    end
    
else
    splineData=[];
    if isempty(samplingSkeleton)
        showSpline=false;  %override any user settings since there is none to show.
    else
        %ignore the setting
    end
end

% if isfield(metadata,'axisRange')
%     axisRange=metadata.axisRange;
% else
%     axisRange=[];
% end
if isempty(framesToShow)
    framesToProcess=metadata.validFramesToProcess;
else
    framesToProcess=framesToShow;
end

if isempty(framesToProcess)
    [~,header] = uread(metadata.rfFilename,-1);
    framesToProcess=(1:(header.nframes-1));
end

%% Setup the sampling points which will be used
%plot image incase need to get new values
[img] = uread(metadata.rfFilename,0,ureadParms{:});


if ~isempty(movieFilename)
    vid=vopen(movieFilename,'w',2,{'avi','compression','none'});
end

lateralLengthUnits_mm=getCaseRFUnits(metadata,'lateral','mm',ureadParms);
axialLengthUnits_mm=getCaseRFUnits(metadata,'axial','mm');

axialAxis=linspace(0,(size(img,1)*axialLengthUnits_mm),size(img,1));
lateralAxis=linspace(0,(size(img,2)*lateralLengthUnits_mm),size(img,2));

%setup the display figure
figDisplay = figure();
if ~isempty(sampleLattice)
    hBModeIm=subplot(1,2,1);
    hSampleLattice=subplot(1,2,2);
    imagesc(abs(sampleLattice)); colormap(gray);hold on;
    xlabel('Frame Number')
    ylabel('Sample Number')
    title('Resampled Data')
else
    hBModeIm=subplot(1,1,1);
end


%setup the control figure
figControls = figure();
set(figDisplay,'Name',caseStr);
set(figControls,'Name',[caseStr ' Controls']);

figDisplayPosition=get(figDisplay,'OuterPosition');
%we want the controls under the figure and the same width.
figControlsPosition=figDisplayPosition;
%[left, bottom, width, height] for OuterPosition
%we want the position to be just below the figure and about a third the
%height
figControlsPosition(4)=floor(figDisplayPosition(4)/3);
figControlsPosition(2)=figDisplayPosition(2)-figControlsPosition(4);

set(figControls,'OuterPosition',figControlsPosition);


btnPause=uicontrol(figControls,'Style', 'pushbutton', 'String', 'Pause',...
    'Position', [20 20 50 20],...
    'Callback', @pausePlot); %#ok<NASGU>

btnSnapshot=uicontrol(figControls,'Style', 'pushbutton', 'String', 'Snapshot',...
    'Position', [220 20 50 20],...
    'Callback', @snapShot); %#ok<NASGU>

txtCurrentFrame=uicontrol(figControls,'Style', 'edit', 'String', num2str(framesToProcess(1)),...
    'Position', [70 80 50 20]);
sldrCurrentFrame=uicontrol(figControls,'Style', 'slider', 'Min', framesToProcess(1),...
    'Max', framesToProcess(end),'Position', [70 50 200 20],'Callback', @updateFrame);
set(sldrCurrentFrame,'Value',framesToProcess(1));

quitGUI=false;
command='playVideo';
sampleLatticeCurrentFrameIndicator=[];
pausePlotRequest=false;
markPositionLine=[];
samplingSkeletonSpline=[];
while(~quitGUI)
    
    
    switch(command)
        case 'playVideo'
            startFrameIndex=find(framesToProcess==str2double(get(txtCurrentFrame,'String')));
            if length(startFrameIndex)~=1
                error('Unable to find startFrameIndex');
            end
            
            for ii=startFrameIndex:length(framesToProcess)
                
                currentFrame=framesToProcess(ii);
                
                if ~isempty(axisToMarkPositionOn) && ishghandle(axisToMarkPositionOn)
                    if ~isempty(markPositionLine) && ishghandle(markPositionLine)
                        delete(markPositionLine);
                    else
                        %do nothing
                    end
                    saveNextPlot=get(axisToMarkPositionOn,'NextPlot');
                    set(axisToMarkPositionOn,'NextPlot','add');
                    y=get(axisToMarkPositionOn,'ylim');
                    markPositionLine=plot(axisToMarkPositionOn,[currentFrame currentFrame],y,'y');
                    set(axisToMarkPositionOn,'NextPlot',saveNextPlot);
                    
                else
                    %do nothing
                end
                paintImage(framesToProcess(ii));
                if pausePlotRequest
                    pausePlotRequest=false;
                    break;
                else
                    pause(.1)
                end
            end
            
            %check if it is at the end of the sequence.  If so put it in a
            %pause mode
            if  str2double(get(txtCurrentFrame,'String')) == framesToProcess(end)
                set(btnPause,'String','Play')
            end
            
        case 'updateFrame'
            updateFrameNumber=round(get(sldrCurrentFrame,'Value'));
            if ~isempty(axisToMarkPositionOn) && ishghandle(axisToMarkPositionOn)
                if ~isempty(markPositionLine) && ishghandle(markPositionLine)
                    delete(markPositionLine);
                else
                    %do nothing
                end
                saveNextPlot=get(axisToMarkPositionOn,'NextPlot');
                set(axisToMarkPositionOn,'NextPlot','add');
                y=get(axisToMarkPositionOn,'ylim');
                markPositionLine=plot(axisToMarkPositionOn,[updateFrameNumber updateFrameNumber],y,'y');
                set(axisToMarkPositionOn,'NextPlot',saveNextPlot);
            else
                %do nothing
            end
            paintImage(updateFrameNumber);
        otherwise
            error(['Unsupported command of: ' command]);
    end
    
    %wait for the next command
    uiwait(figControls);
    
    %must have been closed
    if ~ishandle(figControls)
        quitGUI=true;
        if ~isempty(axisToMarkPositionOn) && ishghandle(axisToMarkPositionOn)
            if ~isempty(markPositionLine) && ishghandle(markPositionLine)
                delete(markPositionLine);
            else
                %do nothing
            end
        else
            %do nothing
        end
        close(figDisplay);
    end
    
    
end


if ~isempty(movieFilename)
    vid=vclose(vid);
end

    function paintImage(frameNumber)
        [img] = uread(metadata.rfFilename,frameNumber-1,ureadParms{:});
        
        
        
        imagesc(lateralAxis,axialAxis(imgClip:end),displayFcn(img(imgClip:end,:)),'Parent',hBModeIm); colormap(hBModeIm,gray(256));
        set(hBModeIm,'NextPlot','add');
        
        if showSpline
            pointListLim_x=[min(samplingSkeleton(frameNumber).vertex.pointList_rc(2,:)); max(samplingSkeleton(frameNumber).vertex.pointList_rc(2,:))];
            xx=linspace(pointListLim_x(1), pointListLim_x(2),max(round(diff(pointListLim_x))*5,10));
            yy=spline(samplingSkeleton(frameNumber).vertex.pointList_rc(2,:),samplingSkeleton(frameNumber).vertex.pointList_rc(1,:),xx);
            plot(hBModeIm,xx*lateralLengthUnits_mm,(yy)*axialLengthUnits_mm,'y');
        end
        
        
        
        
        
        set(hBModeIm,'NextPlot','replace');
        xlabel(hBModeIm,'Laterial Distance (mm)')
        ylabel(hBModeIm,'Axial Depth (mm)')
        
        title(hBModeIm,['Case ' caseStr ' at frame ' num2str(frameNumber) ' of ' num2str(framesToProcess(end))],'interpreter','none')
        
        if ~isempty(sampleLattice)
            %remove the current
            if ~isempty(sampleLatticeCurrentFrameIndicator)
                delete(sampleLatticeCurrentFrameIndicator);
            end
            sampleLatticeCurrentFrameIndicator=plot(hSampleLattice,[frameNumber frameNumber],[1 size(sampleLattice,1)],'y','lineWidth',2);
            
        end
        
        
        set(txtCurrentFrame,'String',num2str(frameNumber));
        set(sldrCurrentFrame,'Value',frameNumber);
        
        drawnow
        if ~isempty(movieFilename)
            vid=vwrite(vid,gca,'handle');
        end
        
    end

    function pausePlot(hObj,event) %#ok<INUSD>
        if strcmp(get(hObj,'String'),'Pause')
            pausePlotRequest=true;
            set(hObj,'String','Play')
        else
            set(hObj,'String','Pause')
            command='playVideo';
            uiresume;
        end
        
    end

    function snapShot(hObj,event) %#ok<INUSD>
        [img] = uread(metadata.rfFilename,framesToProcess(ii),ureadParms{:});
        imOut=displayFcn(img);
        imOut=imOut/max(imOut(:));
        imwrite(imOut,['img_' num2str(framesToProcess(ii)) '.png'],'png')
    end

    function updateFrame(hObj,event) %#ok<INUSD>
        command='updateFrame';
        uiresume;
    end
end