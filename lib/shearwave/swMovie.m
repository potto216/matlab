%This function will generate a movie of the shearwave based on the user selected input.
%The function will also save a Matlab file with the same name that contains the
%meta information used to create the movie.  The movie files can take a
%long time to generate so running on the server is not a bad idea.
%INPUT
%dataSource - The input can be [] which is user selectable, a character
%based data filename or a swCase object.
%
%maxMemoryForArrayInSamples - the amount of memory the system has 
%
%startBlockSampleIndex_base1 - this is the sample where the first black
%starts and uses blockLength
%
%blockLength - the length of each block in the processing.
%
%vopen - the arguments for vopen.
%
%shearwaveLim_mPerSec - lower and upper bound for the shear wave speed
%[min max] in meters per second


function swMovie(dataSource, varargin)

p = inputParser;   % Create an instance of the class.
p.addRequired('dataSource', @(x) ischar(x) | isa(x,'swCase') | isempty(x));
p.addParamValue('maxMemoryForArrayInSamples',1500*32*128,  @(x) x>0); %this is the max value to prevent an out of memory error for an array that is too large
p.addParamValue('startBlockSampleIndex_base1',1,@(x) x>=1);
p.addParamValue('blockLength',100,@(x) x>=10);
p.addParamValue('shearwaveGeneratorPosition','none',@(x) any(strcmp(x,{'left','right','none'})));
p.addParamValue('vopen',{}, @(x) iscell(x));
p.addParamValue('shearwaveLim_mPerSec',[-10 10], @(x) isvector(x) && length(x)==2);


p.parse(dataSource,varargin{:});

dataSource=p.Results.dataSource;
maxMemoryForArrayInSamples=p.Results.maxMemoryForArrayInSamples;
startBlockSampleIndex_base1=p.Results.startBlockSampleIndex_base1;
blockLength=p.Results.blockLength;
vopenArgs=p.Results.vopen;
shearwaveLim_mPerSec=p.Results.shearwaveLim_mPerSec;
shearwaveGeneratorPosition=p.Results.shearwaveGeneratorPosition;

figShearwaveSpeed=figure;


if isempty(dataSource)
    swObj=shearwaveObject(swCase([]));    
elseif ischar(dataSource)
    swObj=shearwaveObject(swCase(dataSource));    
elseif isa(dataSource,'swCase')
    swObj=shearwaveObject(dataSource);
else
    error(['dataSource''s datatype is unsupported.  Class = ' class(dataSource)]);    
end


switch(shearwaveGeneratorPosition)
    case 'left'
        swObj.useShearwaveCorrection=true;
        swObj.shearwaveGeneratorPosition='left';
        
    case 'right'
        swObj.useShearwaveCorrection=true;
        swObj.shearwaveGeneratorPosition='right';
        
    case 'none'
        swObj.shearwaveGeneratorPosition='left';
        swObj.useShearwaveCorrection=false;
        
    otherwise
        error(['Unsupport direction of ' shearwaveGeneratorPosition]);
end


%% Setup the sampling points which will be used

blockLength=min(swObj.caseObj.caseData.rf.header.nframes-(startBlockSampleIndex_base1-1),blockLength);


% handles.hShearwaveSpeed=[];
% handles.hShearwaveRsq=[];
% handles.bModeImage=[];
% 
% set(handles.txtMaxBlock,'String',num2str(swObj.caseObj.caseData.rf.header.nframes));
% set(handles.txtMinBlock,'String',num2str(1));
% set(handles.sldrStartBlock,'Min',1);
% set(handles.sldrStartBlock,'Max',max(1,swObj.caseObj.caseData.rf.header.nframes-handles.data.maxFramesToProcess));
% set(handles.sldrStartBlock,'Value',p.Results.startBlock);
% %setup max info
% set(handles.edttxtCurrentStartBlock,'String',num2str(floor(get(handles.sldrStartBlock,'Value'))));
% set(handles.figShearWaveAnalysis,'Position',	[6.4000   34.4615   96.4000   38.0769])
% 
% set(handles.edtRsqThreshold,'String','0.7')
% 
% set(handles.edttxtTemporalFrequency,'Enable','off');

currentStartBlockSampleIndex_base1=startBlockSampleIndex_base1;

requestedDatablock_base0=(0:blockLength+currentStartBlockSampleIndex_base1-1);
 
if max(requestedDatablock_base0)>swObj.caseObj.caseData.rf.header.nframes
    error(['Requested datablock is too large.']);
end

swObj.loadBlock(requestedDatablock_base0);
percentOfImageUsed=swObj.analyze;

imgToShow=swObj.imBmode(1);
shearwaveSpeed_mPerSec=swObj.imShearSpeed_mPerSec;
selectedFrequency_Hz=swObj.temporalFrequency_Hz;


set(handles.edttxtCurrentStartBlock,'String',num2str(requestedDatablock(1)+1));
set(handles.edttxtTemporalFrequency,'String', num2str(swObj.temporalFrequency_Hz))

figure(figShearwaveSpeed);
hShearwaveSpeed=[];
shearwaveSpeed_mPerSec(and(~isinf(shearwaveSpeed_mPerSec),shearwaveSpeed_mPerSec<shearwaveLim(1)))=shearwaveLim(1);

if isempty(hShearwaveSpeed)
    hShearwaveSpeed=imagesc(swObj.lateralAxis_mm,swObj.axialAxis_mm,shearwaveSpeed_mPerSec); c1=colorbar;
    %make -inf a black line
    m=(shearwaveLim(2)-shearwaveLim(1))/(256-2);
    newLow=shearwaveLim(1)-m;
    caxis([newLow shearwaveLim(2)])
    cm=colormap(jet(256));
    cm(1,:)=0;
    
    %make all negative speeds except -inf white
    firstNegativeColorIndex = (fix((0-shearwaveLim(1))/(shearwaveLim(2)-shearwaveLim(1))*size(cm,1))+1)-1;
    if firstNegativeColorIndex<=1
        error('Negative color index is too small')
    end
    cm(2:firstNegativeColorIndex,:)=1;
    
    colormap(cm);
    set(get(c1,'ylabel'),'string','speed (m/sec)','Rotation',270,'interpreter','none');
    
    xlabel('Lateral  Distance (mm)')
    ylabel('Axial Depth (mm)')
else
    set(hShearwaveSpeed,'CData',shearwaveSpeed_mPerSec);
end

title(['Shearwave temporal frequency is ' num2str(selectedFrequency_Hz) 'Hz.' 10  'Valid image: ' num2str(round(percentOfImageUsed*100)) '%. (r)ectangle (e)llipse.'],'interpreter','none');
set(handles.figShearwaveSpeed,'KeyPressFcn',{@plotShearwaveSpeed,get(handles.hShearwaveSpeed,'Parent'),handles.axesBMode,get(handles.axesBMode,'Parent')});



end