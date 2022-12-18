function varargout = grabSWCineColorDoppler(varargin)
% GRABSWCINECOLORDOPPLER MATLAB code for grabSWCineColorDoppler.fig
%      GRABSWCINECOLORDOPPLER, by itself, creates a new GRABSWCINECOLORDOPPLER or raises the existing
%      singleton*.
%
%      H = GRABSWCINECOLORDOPPLER returns the handle to a new GRABSWCINECOLORDOPPLER or the handle to
%      the existing singleton*.
%
%      GRABSWCINECOLORDOPPLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRABSWCINECOLORDOPPLER.M with the given input arguments.
%
%      GRABSWCINECOLORDOPPLER('Property','Value',...) creates a new GRABSWCINECOLORDOPPLER or raises the
%      existing singleton*.  Starting from +the left, property value pairs are
%      applied to the GUI before grabSWCineColorDoppler_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to grabSWCineColorDoppler_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%This program collects data
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help grabSWCineColorDoppler

% Last Modified by GUIDE v2.5 23-Mar-2012 12:41:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @grabSWCineColorDoppler_OpeningFcn, ...
    'gui_OutputFcn',  @grabSWCineColorDoppler_OutputFcn, ...
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

% --- Executes just before grabSWCineColorDoppler is made visible.
function grabSWCineColorDoppler_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to grabSWCineColorDoppler (see VARARGIN)

% Choose default command line output for grabSWCineColorDoppler
handles.output = hObject;

%set(handles.btnInitializeOnly,'Enable','off')

handles.uObj=UlteriusObject();
set(handles.edtConnectName,'String','ultrasonix')
set(handles.edttxtLineDensity,'String','64');
set(handles.edttxtDepth_cm,'String','2.5')
set(handles.edttxtSector_percent,'String','50')
handles.settings.colorDoppler.rectangle=[];
handles.settings.bmodeRF.gain=[];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes grabSWCineColorDoppler w0ait for user response (see UIRESUME)
% uiwait(handles.figGrabSWCineColorDoppler);
end

% --- Outputs from this function are returned to the command line.
function varargout = grabSWCineColorDoppler_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in btnCollectData.
function btnCollectData_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to btnCollectData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%First see if the dll exists in the local path.  If so use that.  If not
%look for it in the reposity  If not given an error message
%check local
set(hObject,'Enable','off')
btnString=get(hObject,'String');
set(hObject,'String','Collecting Data Please Wait...');
savedPointer=get(handles.figGrabSWCineColorDoppler,'Pointer');
set(handles.figGrabSWCineColorDoppler,'Pointer','watch');
refresh(handles.figGrabSWCineColorDoppler);
drawnow;

defaultValues.sampleRate_Hz=40e6;
defaultValues.lineDensity=64;


disp('___Initializing____(need to do this)')

connectIfNeeded(handles);



%Check to make sure the probe is okay
activeProbeName=setProbe(handles,{'L14-5/38','L14-5W/60'});

set(handles.txtActiveProbe,'String',activeProbeName);
drawnow


setupOkayForAll=true;

handles.uObj.setFreezeState('image')
pause(1)

setupOkay=setSonixRP(@() handles.uObj.selectMode(12), @() 12==handles.uObj.getActiveImagingMode, 15,.3);
setupOkayForAll=setupOkayForAll & setupOkay;
if ~setupOkay
    disp('active image mode failed')
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
parmBLDensity=str2double(get(handles.edttxtLineDensity,'String'));
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
parmBDepth_mm=str2double(get(handles.edttxtDepth_cm,'String'))*10;
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
parmSector_percent=str2double(get(handles.edttxtSector_percent,'String'));
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




%% run collect
type=int32(16);
maxFramesToCapture=1000;
timeToCapture_sec=maxFramesToCapture/fps;

maxCineFrames=0;
tries=0;

while( tries<3 && maxCineFrames<maxFramesToCapture)
    maxCineFrames=handles.uObj.getMaxCineFrames(type);
    
    if (maxCineFrames<maxFramesToCapture)
        if tries < 3
            warning('GUI:getMaxCineFramesFail','getMaxCineFrames does not have enough frames trying again');
            tries=tries+1;
        else
            shutdownObj(handles.uObj);
            errorOverride(['Not enough space in the cine buffer.  Want to capture ' num2str(maxFramesToCapture) ' but only room for '  num2str(maxCineFrames)])
        end
    end
end

%capture the data
handles.uObj.setFreezeState('freeze');
sound(0.125*sin(2*pi*1000*linspace(0,0.25,8000*0.25)),8000)
handles.uObj.setFreezeState('image');

pause(timeToCapture_sec*2);

handles.uObj.setFreezeState('freeze');

%make sure enough frames have been captured
cineDataCount = handles.uObj.getCineDataCount(type);

set(handles.txtFramesCollected,'String',num2str(cineDataCount));
drawnow
disp([ num2str(cineDataCount) ' frames captured.']);
if cineDataCount<maxFramesToCapture
    shutdownObj(handles.uObj);
    errorOverride(['Not enough frames captured.  Min number ' num2str(maxFramesToCapture) ' but only '  num2str(cineDataCount) ' frames captured.']);
end
%% run the processing loop
fp=figure;

type=16;
%[returnCode, typeReturn, dataWidth, dataHeight, dataWordSize_bits] = calllib(libAlias, 'ulterius_int_getDataDescriptor_int_int_int_int_int',type, typeReturn, dataWidth, dataHeight, dataWordSize_bits);
[dataWidth, dataHeight, dataWordSize_bits, typeReturn, isSuccessful]=handles.uObj.getDataDescriptor(type);

if (dataWordSize_bits/8)~=2
    errorOverride('Unsupported value of dataWordSize_bits')
end

if type~=typeReturn
    shutdownObj(handles.uObj);
    errorOverride('Return type is not equal to the requested type');
end

if ~isSuccessful
    shutdownObj(handles.uObj);
    errorOverride('getDataDescriptor call failed');
end

sizeInBytes=int32(dataWidth*dataHeight*(dataWordSize_bits/8));
%img=zeros(dataHeight,dataWidth,1,'int16');



debugData=[];
for blockOffset=1:100:301
    disp(['*********Processing at Block Start ' num2str(blockOffset) ' ******************' ])
    
    disp('Transfering the data')
    
    
    framesCollected=120;
    imgBlock=zeros(dataHeight,dataWidth,framesCollected);
    for ii=1:(framesCollected)
        %[bufferFrameNumber,img,sz,type,cine,frmnum] = calllib(libAlias, 'getFrame',img,ii+blockOffset,sizeInBytes,sz,type,cine,frmnum);
        frmnum=ii+blockOffset;
        [img, isSuccessful]=handles.uObj.getCineDataINT16(type, dataHeight,dataWidth,frmnum, sizeInBytes);
        %         [returnCode, img] = calllib(libAlias, 'ulterius_int_getCineDataNoCallBack_int_int_INT16_int', ...
        %             type, frmnum, img, sizeInBytes);
        if ~isSuccessful
            errorOverride(['Unable to aquire frame ' num2str(frmnum)])
        end
        
        imgBlock(:,:,ii)=hilbert(double(reshape(img,dataHeight,dataWidth)));
        imgBlockInfo(ii).type=type; %#ok<AGROW>
        imgBlockInfo(ii).frmnum=double(frmnum); %#ok<AGROW>
    end
    disp('Transfer complete')
    
    
    if ~all(diff([imgBlockInfo(:).type])==0) || (imgBlockInfo(1).type~=16)
        shutdownObj(handles.uObj);
        errorOverride('Not all frames are the rf type')
    end
    debugData(end+1).droppedFrames=(diff([imgBlockInfo(:).frmnum])); %#ok<AGROW>
    
    
    imgBlock=imgBlock(:,1:2:end,:);
    
    
    
    imgAngleFilt_rad=angle(imgBlock(:,1:end,1:(end-1)).*conj(imgBlock(:,1:end,2:end)));
    
    for k = 1:size(imgAngleFilt_rad,3)
        imgAngleFilt_rad(:,:,k) = medfilt2(imgAngleFilt_rad(:,:,k),[5,3]);
        imgAngleFilt_rad(:,:,k) = conv2(imgAngleFilt_rad(:,:,k),ones(10,1)/10,'same');
        
    end
    
    
    
    
    fft_phase = zeros(size(imgAngleFilt_rad,1),size(imgAngleFilt_rad,2));
    
    fftBinFreqToRealFreq=make_f(size(imgAngleFilt_rad,3),fps);
    
    sig=imgAngleFilt_rad-repmat(mean(imgAngleFilt_rad,3),[1, 1, size(imgAngleFilt_rad,3)]);
    sig=sig.*repmat(permute(hanning(size(imgAngleFilt_rad,3)),[3 2 1]),[size(imgAngleFilt_rad,1) size(imgAngleFilt_rad,2) 1]);
    sig=fft(sig,size(sig,3),3);
    [fund_peak_val,fund_peak]=max(abs(sig(:,:,1:floor(end/2))),[],3); %#ok<ASGLU>
    
    for k=1:size(sig,1);
        for l=1:size(sig,2)
            fft_phase(k,l) = angle(sig(k,l,fund_peak(k,l)));
        end;
    end
    fft_frequency = fund_peak;
    
    commonFreqBin=mode(fft_frequency(:));
    badFreqIdx=find(commonFreqBin~=fft_frequency(:));
    freqsNoMatch=length(badFreqIdx)/(size(fft_frequency,1)*size(fft_frequency,2));
    
    debugData(end).maxFrequency_Hz=fftBinFreqToRealFreq(fft_frequency);
    
    disp(['The most common frequency found is ' num2str(fftBinFreqToRealFreq(commonFreqBin)) 'Hz.'])
    disp([num2str(freqsNoMatch*100) '% of the freqs do not match']);
    
    
    
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
    
    
    
    debugData(end).bmodeImg=abs(imgBlock(:,:,1)).^0.5; %#ok<AGROW>
    
    
    figure(fp);
    set(fp,'Name',['Frame Rate ' num2str(fps) 'Hz'])
    axesh=subplot(2,2,mod(length(debugData)-1,4)+1);
    %hold on
    %axial_mm=linspace(0,str2double(get(handles.edttxtDepth_cm,'String'))*10,size(fft_phase,1));
    lateralDist_mm=linspace(0,str2double(get(handles.edttxtSector_percent,'String'))/100*handles.swCase.lateralStep_mm*(defaultValues.lineDensity-1),size(fft_phase,2));
    axial_mm=linspace(0,(handles.swCase.axialStep_mm*size(fft_phase,1)),size(fft_phase,1));
    
    %     switch(get(handles.txtActiveProbe,'String'))
    %         case 'L14-5/38'
    %
    %
    %         otherwise
    %             lateralDist_mm=(1:size(fft_phase,2));
    %             axial_mm=(1:size(fft_phase,1));
    %             warning(['Please add distance measure for ' handles.txtActiveProbe]);
    %     end
    
    debugData(end).lateralDist_mm=lateralDist_mm;
    debugData(end).axial_mm=axial_mm;
    
    imh=imagesc(lateralDist_mm,axial_mm,fft_phase); caxis([-pi pi])
    xlabel('Lateral  Distance (mm)')
    ylabel('Axial Depth (mm)')
    title(['Block Start ' num2str(blockOffset)  ' freq = ' num2str(fftBinFreqToRealFreq(commonFreqBin)) 'Hz'],'interpreter','none')
    set(imh, 'HitTest', 'off')
    %imagesc will clear the button function
    %See: http://www.mathworks.com/matlabcentral/newsreader/view_thread/165091#419072
    %http://www.mathworks.com/matlabcentral/newsreader/view_thread/160626
    set(axesh,'ButtonDownFcn',{@showDebugData,handles.figGrabSWCineColorDoppler,length(debugData),debugData(end).bmodeImg,debugData(end).droppedFrames});
    %hold off
    
    
    pause(.1)
    
end

set(hObject,'String',btnString);
set(hObject,'Enable','on')

set(handles.figGrabSWCineColorDoppler,'Pointer',savedPointer);
setappdata(handles.figGrabSWCineColorDoppler,'debugData',debugData)
disp('Finished!')
end

function showDebugData(src,eventdata,dataHandle,debugDataIndex,bmodeImg,droppedFrames) %#ok<INUSD,INUSL>
debugData=getappdata(dataHandle,'debugData');

figure

subplot(1,2,1)
imagesc(debugData(debugDataIndex).lateralDist_mm,debugData(debugDataIndex).axial_mm,abs(debugData(debugDataIndex).bmodeImg).^0.5); colormap(gray);hold on;
xlabel('Lateral  Distance (mm)')
ylabel('Axial Depth (mm)')
title(['Bmode image for index ' num2str(debugDataIndex)])


subplot(1,2,2)
hist(debugData(debugDataIndex).maxFrequency_Hz(:),111)
xlabel('Frequency (Hz)');
ylabel('Count');
title('Histgram of max freq distribution.')


% droppedFrames=double(debugData(debugDataIndex).droppedFrames)-1;
% edges=[ceil(linspace(0,max(droppedFrames),13))];
% n_el= histc(droppedFrames,edges);
% showCenter=[edges(1) (edges(2:end)+ceil(diff(edges(2:3))/2))];
% subplot(1,2,2)
% bar(showCenter,n_el,'BarWidth',1);
% %hist(double(debugData(debugDataIndex).droppedFrames),13)
% xlabel('# Dropped')
% ylabel('Frequency')
% title('Histogram of dropped frames')


end


% --- Executes on button press in btnInitializeOnly.
function btnInitializeOnly_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to btnInitializeOnly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'String',btnString);
set(hObject,'Enable','on')

set(handles.figGrabSWCineColorDoppler,'Pointer',savedPointer);
disp('Finished!')


end

% --- Executes on key press with focus on figGrabSWCineColorDoppler and none of its controls.
function figGrabSWCineColorDoppler_KeyPressFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to figGrabSWCineColorDoppler (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if strcmp(eventdata.Character,' ') && strcmp(eventdata.Key,'space')
    btnCollectData_Callback(handles.btnCollectData, [], handles)
end

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


% --------------------------------------------------------------------
function mnuDisplayVelocityMap_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to mnuDisplayVelocityMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


% --- Executes on button press in btnColorDoppler.
function btnColorDoppler_Callback(hObject, eventdata, handles)
% hObject    handle to btnColorDoppler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
connectIfNeeded(handles);
activeProbeName=setProbe(handles,{'L14-5/38','L14-5W/60'});
set(handles.txtActiveProbe,'String',activeProbeName);
drawnow

handles.uObj.selectPreset('SWColorD')
pause(2)
handles.uObj.selectMode(handles.uObj.imagingMode_ColourMode)
pause(1)

if ~isempty(handles.settings.colorDoppler.rectangle)
    [isSuccessful]=handles.uObj.setColorDopplerRectangle(handles.settings.colorDoppler.rectangle);
    warningIfFail(isSuccessful,'Unable to set Color Doppler rectangle.')
end





end


% --- Executes on button press in btnBModeRF.
function btnBModeRF_Callback(hObject, eventdata, handles)
% hObject    handle to btnBModeRF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
connectIfNeeded(handles);
activeProbeName=setProbe(handles,{'L14-5/38','L14-5W/60'});
set(handles.txtActiveProbe,'String',activeProbeName);
drawnow

handles.uObj.selectPreset('SWRF')
pause(2)

if ~isempty(handles.settings.bmodeRF.gain)
    
    %sector, old: 1116
    %The sector used for the B image. This is a percentage of the line density.
    %Sector 1116 = 50 (%)
    parmBGain=handles.settings.bmodeRF.gain;
    isSuccessful=setSonixRP(@() handles.uObj.setParamValue(handles.uObj.parmBGain,parmBGain), ...
        @() (parmBGain==handles.uObj.getParamValue(handles.uObj.parmBGain)), ...
        15,.3);
    
    warningIfFail(isSuccessful,'Unable to set BMode RF Gain.  try setting it manually')
end




end

function activeProbeName=setProbe(handles,validProbeToUse)
activeProbeName=handles.uObj.getActiveProbe();
if ~any(strcmp(activeProbeName,validProbeToUse))
    %let's switch to the correct probe
    
    probeList=handles.uObj.getProbes;
    
    validProbesFound=0;
    for ii=1:length(validProbeToUse)
        validProbeIndex=find(strcmp(validProbeToUse{ii},probeList));
        if ~isempty(validProbeIndex)
            probeNumber=validProbeIndex-1;
            validProbesFound=validProbesFound+1;
        else
            %do nothing
        end
        
    end
    
    if validProbesFound==0
        shutdownObj(handles.uObj);
        errorOverride('No valid probes were found.')
    elseif validProbesFound~=1
        warning(['More than 1 valid probe was found so using' probeList{probeNumber+1}]);
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


% --- Executes when user attempts to close figGrabSWCineColorDoppler.
function figGrabSWCineColorDoppler_CloseRequestFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to figGrabSWCineColorDoppler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
shutdownObj(handles.uObj)
delete(hObject);
end

% --- Executes on button press in btnColorDopplerSave.
function btnColorDopplerSave_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to btnColorDopplerSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.settings.colorDoppler.rectangle,isSuccessful]=handles.uObj.getColorDopplerRectangle;
warningIfFail(isSuccessful,'Unable to get Color Doppler rectangle.');
guidata(hObject, handles);
end


% --- Executes on button press in btnBModeRFSave.
function btnBModeRFSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnBModeRFSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Here we wish to save only the user adjustable features which right now are
%the gain.


[handles.settings.bmodeRF.gain,isSuccessful]=handles.uObj.getParamValue(handles.uObj.parmBGain);

warningIfFail(isSuccessful,'Unable to save BMode RF Gain.  try setting it manually');
guidata(hObject, handles);
end

function warningIfFail(isSuccessful,textMessage)
if ~isSuccessful
    
    disp(textMessage);
    msgbox(textMessage);
else
    %do nothing
end
end