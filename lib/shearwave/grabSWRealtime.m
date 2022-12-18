function varargout = grabSWRealtime(varargin)
% GRABSWREALTIME MATLAB code for grabSWRealtime.fig
%      GRABSWREALTIME, by itself, creates a new GRABSWREALTIME or raises the existing
%      singleton*.
%
%      H = GRABSWREALTIME returns the handle to a new GRABSWREALTIME or the handle to
%      the existing singleton*.
%
%      GRABSWREALTIME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRABSWREALTIME.M with the given input arguments.
%
%      GRABSWREALTIME('Property','Value',...) creates a new GRABSWREALTIME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before grabSWRealtime_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to grabSWRealtime_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help grabSWRealtime

% Last Modified by GUIDE v2.5 05-Jul-2012 18:33:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @grabSWRealtime_OpeningFcn, ...
                   'gui_OutputFcn',  @grabSWRealtime_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before grabSWRealtime is made visible.
function grabSWRealtime_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to grabSWRealtime (see VARARGIN)

% Choose default command line output for grabSWRealtime
handles.output = hObject;


handles.uObj=UlteriusObject();
set(handles.edtConnectName,'String','ultrasonix')
handles.f1=figure;
handles.f2=figure;

% Update handles structure
guidata(hObject, handles);



% UIWAIT makes grabSWRealtime wait for user response (see UIRESUME)
% uiwait(handles.figGrabSWRealtime);
end

% --- Outputs from this function are returned to the command line.
function varargout = grabSWRealtime_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in btnStartCollect.
function btnStartCollect_Callback(hObject, eventdata, handles)
% hObject    handle to btnStartCollect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% hObject    handle to btnCollectData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%First see if the dll exists in the local path.  If so use that.  If not
%look for it in the reposity  If not given an error message
%check local
defaultValues.sampleRate_Hz=40e6;
defaultValues.lineDensity=64;


disp('___Initializing____(need to do this)')

connectIfNeeded(handles);



%Check to make sure the probe is okay
activeProbeName=setProbe(handles);

set(handles.txtActiveProbe,'String',activeProbeName);
drawnow


setupOkayForAll=true;

handles.uObj.setFreezeState('image')
pause(1)

setupOkay=setSonixRP(@() handles.uObj.selectMode(handles.uObj.imagingMode_RfMode), @() handles.uObj.imagingMode_RfMode==handles.uObj.getActiveImagingMode, 15,.3);
setupOkayForAll=setupOkayForAll & setupOkay;
if ~setupOkay
    disp('active image mode failed')
end



isSuccessful=handles.uObj.setDataToAcquire(handles.uObj.uData_udtNone);
if (~isSuccessful)
    setupOkay=false;
    disp('Was not able to turn off data acquire.')
end

%rf-mode, old:857
%The active RF mode. 0=B only, 1=RF only, 2=B and RF, 3=ChRF, 4=B and ChRF
setupOkay=setSonixRP(@() handles.uObj.setParamValue(handles.uObj.parmRFMode,1), @() 1==handles.uObj.getParamValue(handles.uObj.parmRFMode), 15,.3);
setupOkayForAll=setupOkayForAll & setupOkay;
if ~setupOkay
    disp('parmrfmode failed')
end




if defaultValues.sampleRate_Hz==40e6
    %rf-rf decimation, old:1259
    %The decimation applied to the color RF data returned. 0=40MHz, 1=20MHz,2=10MHz,3=5MHz.
    setupOkay=setSonixRP(@() handles.uObj.setParamValue(handles.uObj.parmRFDecimation, 0), @() (0==handles.uObj.getParamValue(handles.uObj.parmRFDecimation)), 15,.3);
    setupOkayForAll=setupOkayForAll & setupOkay;
    if ~setupOkay
        disp('rf decimation failed')
    end
else
    error('Unsupported sample rate')
end

%b-ldensity, old: 32
%LDensity(B) 32 = 64
parmBLDensity=64;
setupOkay=setSonixRP(@() handles.uObj.setParamValue(handles.uObj.parmBLDensity, parmBLDensity), @() (defaultValues.lineDensity==handles.uObj.getParamValue(handles.uObj.parmBLDensity)), 15,.3);
setupOkayForAll=setupOkayForAll & setupOkay;
if ~setupOkay
    disp(' bldensity failed')
end

%b-focus count, old: 157
%Number of focus markers on the B image. 0=auto-focus.
%focus Count (B) 157 = 1
setupOkay=setSonixRP(@() handles.uObj.setParamValue(handles.uObj.parmbFocusCount, 1), @() (1==handles.uObj.getParamValue(handles.uObj.parmbFocusCount)), 15,.3);
setupOkayForAll=setupOkayForAll & setupOkay;
if ~setupOkay
    disp(' bldensity failed')
end


%b-depth, old: 206
%The imaging depth
%Depth(B) 206=25 2.5cm
parmBDepth_mm=25;
setupOkay=setSonixRP(@() handles.uObj.setParamValue(handles.uObj.parmBDepth, parmBDepth_mm), ...
    @() (25==handles.uObj.getParamValue(handles.uObj.parmBDepth)), ...
    15,.3);
setupOkayForAll=setupOkayForAll & setupOkay;
if ~setupOkay
    disp('bdepth failed')
end

%sector, old: 1116
%The sector used for the B image. This is a percentage of the line density.
%Sector 1116 = 50 (%)
parmSector_percent=50;
setupOkay=setSonixRP(@() handles.uObj.setParamValue(handles.uObj.parmSector,parmSector_percent), ...
    @() (50==handles.uObj.getParamValue(handles.uObj.parmSector)), ...
    15,.3);
setupOkayForAll=setupOkayForAll & setupOkay;
if ~setupOkay
    disp('sector size set failed')
end


fps=0;
%TODO: This statement could fail if the line density/depth is selected to
%be very large.  Get what the correct frame rate should be.
while fps<500
    fps=double(handles.uObj.getParamValue(handles.uObj.parmFrameRate));
    disp(['Frame rate detected to be: ' num2str(fps) 'Hz']);
    pause(1);
end

 
handles.swCase=swCase([],'emptyCase',true,'overrideSettings',{'probeName',get(handles.txtActiveProbe,'String'), 'sampleRate_Hz',defaultValues.sampleRate_Hz, 'frameRate_Hz',fps,'lineDensity',defaultValues.lineDensity});

if ~setupOkayForAll
    shutdownObj(handles.uObj);
    errorOverride('Setup Failed')
end
disp('Initializing complete')

%% Setup for the streaming
isSuccessful=false;
while ~isSuccessful
    [dataWidth, dataHeight, dataWordSize_bits, typeReturn, isSuccessful]=handles.uObj.getDataDescriptor(handles.uObj.uData_udtRF);
    if ~isSuccessful
        disp('getDataDescriptor failed')
        
    end
end
f1=handles.f1;
f2=handles.f2;

fs=532;
maxBlocks=3;
maxFramesPerBlock=100;
frameSize_bytes=dataWidth*dataHeight*(dataWordSize_bits/8);
testFrame=int16(mod(reshape((1:(dataHeight*dataWidth))',dataHeight,dataWidth),2^15));
testFrameOut=zeros(size(testFrame,1),size(testFrame,2),'int16');

testFrameRead=zeros(dataHeight*dataWidth*maxFramesPerBlock,1,'int16');
frameNumberList=zeros(maxFramesPerBlock,1,'int32');
frameTypeList=zeros(maxFramesPerBlock,1,'int32');


[didStreamSetup] = calllib(handles.uObj.libDLLAlias, 'ulteriusStreamingDataNew',int32(maxBlocks),int32(maxFramesPerBlock),int32(frameSize_bytes));
[didStreamStart] = calllib(handles.uObj.libDLLAlias, 'ulteriusStreamingDataStart',handles.uObj.uData_udtRF);

for i=1:10
    [activeBlockIndex] = calllib(handles.uObj.libDLLAlias, 'ulteriusStreamingDataGetActiveBlockIndex');
    [activeFrameIndex] = calllib(handles.uObj.libDLLAlias, 'ulteriusStreamingDataGetActiveFrameIndex');
    disp(['The active block/frame is: ' num2str(activeBlockIndex) '/' num2str(activeFrameIndex)])
    
    while(activeBlockIndex == calllib(handles.uObj.libDLLAlias, 'ulteriusStreamingDataGetActiveBlockIndex'))
        pause(.1);
    end
    [didCopyBack,testFrameRead,frameNumberList,frameTypeList] = calllib(handles.uObj.libDLLAlias, 'ulteriusStreamingDataTransferBlock',int32(activeBlockIndex), testFrameRead,frameNumberList,frameTypeList,int32(maxFramesPerBlock), int32(frameSize_bytes));
    if didCopyBack==0
        testFrameReadO=double(reshape(testFrameRead(1:(dataHeight*dataWidth*maxFramesPerBlock)),dataHeight,dataWidth,maxFramesPerBlock));
        testFrameReadO=testFrameReadO(200:1000,:,1:50);
        for ii=1:size(testFrameReadO,3)
            testFrameReadO(:,:,ii)=hilbert(testFrameReadO(:,:,ii));
        end
        figure(f1)
        lateralAxis=linspace(0,18,size(testFrameReadO,2));
        axialAxis=linspace(0,25,size(testFrameReadO,1));
        
        imagesc(lateralAxis,axialAxis,abs(testFrameReadO(:,:,30)).^0.5); colormap(gray);
        xlabel('Lateral (mm)');
        ylabel('Axial (mm)');
        title('BMode');
        
        [phaseImg, selectedFrequency]=swPhaseMap(testFrameReadO,'time',fs,[]);
        
        figure(f2)
        imagesc(lateralAxis,axialAxis,phaseImg); caxis([-pi pi]);
        xlabel('Lateral (mm)');
        ylabel('Axial (mm)');
        title('BMode');
        colorbar
        
        
        title(['The active block is: ' num2str(activeBlockIndex) ' the selected freq is ' num2str(selectedFrequency) 'Hz.'])
    end
    
    
end





[didStreamStart] = calllib(handles.uObj.libDLLAlias, 'ulteriusStreamingDataStop');
[didStreamStart] = calllib(handles.uObj.libDLLAlias, 'ulteriusStreamingDataDelete');


handles.uObj.disconnect
pause(1)
handles.uObj.unloadDLL
disp('Disconnected');

disp('**All runs are finished.**')
return


end



% --- Executes on button press in btnStopCollect.
function btnStopCollect_Callback(hObject, eventdata, handles)
% hObject    handle to btnStopCollect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end



function shutdownObj(uObj)
uObj.disconnect();
uObj.unloadDLL();
end

function errorOverride(errorMessage)

if isdeployed
    msgbox(['Error!' errorMessage])
else
    %do nothing
end

error(errorMessage)

end
%setFunction - Is the function to run to cause an action
%testCondition - The condition that must
%maxTries - Will try this many times to set the function
%timeout_sec - If try does not work then will timeout for this long
function isSet=setSonixRP(setFunction,testCondition,maxTries,timeout_sec)


setFunction();  tryToSet=1;

while (~(testCondition()) && tryToSet<=maxTries )
    pause(timeout_sec)
    tryToSet=tryToSet+1;
    setFunction();
end


if (tryToSet<=maxTries)
    isSet=true;
else
    isSet=false;
end
end

function activeProbeName=setProbe(handles)
activeProbeName=handles.uObj.getActiveProbe();
if ~any(strcmp(activeProbeName,{'L14-5/38','L14-5W/60'}))
    %let's switch to the correct probe
    
    probeList=handles.uObj.getProbes;
    
    
    probeNumber=find(strcmp(activeProbeName,probeList))-1;
    
    if length(probeNumber)~=1
        shutdownObj(handles.uObj);
        errorOverride('probeNumber must be a scalar.  Either could not find probe or found multiple probes')
    end
    isSuccessful=handles.uObj.selectProbe(probeNumber);
    %[isSuccessful]=selectPreset(obj,preset)
    if ~isSuccessful
        shutdownObj(handles.uObj);
        errorOverride(['Setup Failed the probe ' activeProbeName ' is not supported.'])
    end
    pause(3)  %wait a few seconds for the probe to switch
else
    %do nothing
end

end


function connectIfNeeded(handles)
strConnectName=get(handles.edtConnectName,'String');
if ~handles.uObj.isConnected
    
    disp(['Connecting to ' strConnectName]);
    handles.uObj.connect(strConnectName);
else
    %do nothing
end

if ~handles.uObj.isConnected
    msgbox(['Unable to connect to ' strConnectName])
    error(['Unable to connect to ' strConnectName])
end
end
