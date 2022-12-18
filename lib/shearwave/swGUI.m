function varargout = swGUI(varargin)
% SWGUI MATLAB code for swGUI.fig
%      SWGUI, by itself, creates a new SWGUI or raises the existing
%      singleton*.
%
%      H = SWGUI returns the handle to a new SWGUI or the handle to
%      the existing singleton*.
%
%      SWGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SWGUI.M with the given input arguments.
%
%      SWGUI('Property','Value',...) creates a new SWGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before swGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to swGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%previewData - Will show processed data at offsets of 100
%swGUIMatFile will load a saved file.  Only it or swGUI can be specified.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help swGUI

% Last Modified by GUIDE v2.5 23-Mar-2012 16:27:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @swGUI_OpeningFcn, ...
    'gui_OutputFcn',  @swGUI_OutputFcn, ...
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




% --- Executes just before swGUI is made visible.
function swGUI_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
global phaseLine
phaseLine=[];
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% varargin   command line arguments to swGUI (see VARARGIN)

% Choose default command line output for swGUI
handles.output = hObject;

% if nargin<3
%     error('Invalid number of arguments')
% elseif nargin==3
% loadRFData,'ultrasonixGetFrameParms', {'formIQWithHilbert',true}
%     case 0

p = inputParser;   % Create an instance of the class.
p.addOptional('swCaseObj',[], @(x) ischar(x) || isa(x,'swCase') || isempty(x));
%p.addParamValue('ultrasonixGetFrameParms',{},@iscell);
p.addParamValue('displayFcn',@(x) abs(x).^0.5,  @(x) isa(x,'function_handle'));
p.addParamValue('maxMemoryForArrayInSamples',1500*32*128,  @(x) x>0); %this is the max value to prevent an out of memory error for an array that is too large
p.addParamValue('commandLineOnly',false,@islogical);
p.addParamValue('previewData',false,@islogical);
p.addParamValue('startBlock',1,@(x) x>=1);
p.addParamValue('dataFileFullPath','',@ischar);
p.addParamValue('swGUIMatFile','',@ischar);  %can load the a previously saved mat file.  only this or swCaseObj can be loaded
p.addParamValue('swGUIMatFile_dataFileRootPath','',@ischar);  %used to load rf data where it is not given in the mat file.
p.addParamValue('shearwaveGeneratorPosition',[],@(x) any(strcmp(x,{'left','right','none'})) || isempty(x));

p.parse(varargin{:});

if ~isempty(p.Results.swCaseObj) && ~isempty(p.Results.swGUIMatFile)
    error('only swCaseObj or swGUIMatFile can be nonempty.  both cannot be specified.');
end

%first create the objects
if ~isempty(p.Results.swGUIMatFile)
    [handles,defaultShearwaveGeneratorPosition]=loadSwGUIMatFile(p.Results.swGUIMatFile,p.Results.swGUIMatFile_dataFileRootPath,p.Results.shearwaveGeneratorPosition,handles);
else
    
    dataFileFullPath=p.Results.dataFileFullPath;
    
    if isempty(p.Results.swCaseObj)
        handles.swObj=shearwaveObject(swCase([],'dataFileFullPath',dataFileFullPath));
    else
        handles.swObj=shearwaveObject(p.Results.swCaseObj);
    end
    defaultShearwaveGeneratorPosition=p.Results.shearwaveGeneratorPosition;
end


handles.data.displayFcn = p.Results.displayFcn;
handles.data.commandLineOnly = p.Results.commandLineOnly;
maxMemoryForArrayInSamples=p.Results.maxMemoryForArrayInSamples;
handles.data.previewData=p.Results.previewData;




handles.data.caseStr=handles.swObj.caseObj.caseName;
handles.data.activeDataBlock=[];




swGeneratorPositionList={'left','right','none'};


if isempty(defaultShearwaveGeneratorPosition)
    [selectionIndex,okSelected] = listdlg('ListString',swGeneratorPositionList, ...
        'InitialValue',1, ...
        'SelectionMode','single','Name','Vibrator Position', ...
        'PromptString','Select vibrator position relative to the triggerpoint');
    
    if okSelected
        selectedShearwaveGeneratorPosition=swGeneratorPositionList{selectionIndex};
    else
        selectedShearwaveGeneratorPosition='none';
    end
else
    selectedShearwaveGeneratorPosition=defaultShearwaveGeneratorPosition;
    
end




switch(selectedShearwaveGeneratorPosition)
    case 'left'
        set(handles.mnuOptionsVibratorPositionLeft,'Checked','on')
        set(handles.mnuOptionsVibratorPositionRight,'Checked','off')
        handles.swObj.useShearwaveCorrection=true;
        handles.swObj.shearwaveGeneratorPosition='left';
        set(handles.mnuOptionsUseShearwaveCorrection,'Checked','on');
        
    case 'right'
        set(handles.mnuOptionsVibratorPositionLeft,'Checked','off')
        set(handles.mnuOptionsVibratorPositionRight,'Checked','on')
        handles.swObj.useShearwaveCorrection=true;
        handles.swObj.shearwaveGeneratorPosition='right';
        set(handles.mnuOptionsUseShearwaveCorrection,'Checked','on');
        
    case 'none'
        
        set(handles.mnuOptionsVibratorPositionLeft,'Checked','on')
        set(handles.mnuOptionsVibratorPositionRight,'Checked','off')
        handles.swObj.shearwaveGeneratorPosition='left';
        handles.swObj.useShearwaveCorrection=false;
        set(handles.mnuOptionsUseShearwaveCorrection,'Checked','off');
        
    otherwise
        error(['Unsupport direction of ' selectedShearwaveGeneratorPosition]);
end


%% Setup the sampling points which will be used

maxFrames=floor(maxMemoryForArrayInSamples/(handles.swObj.caseObj.caseData.rf.header.w*handles.swObj.caseObj.caseData.rf.header.h));
maxFramesToProcess=min(handles.swObj.caseObj.caseData.rf.header.nframes,maxFrames);

handles.data.maxFramesToProcess=maxFramesToProcess;
if handles.data.previewData
    showPreview(handles);
end

handles.hShearwaveSpeed=[];
handles.hShearwaveRsq=[];
handles.hImPhaseRaw_rad=[];
handles.bModeImage=[];

set(handles.txtMaxBlock,'String',num2str(handles.swObj.caseObj.caseData.rf.header.nframes));
set(handles.txtMinBlock,'String',num2str(1));
set(handles.sldrStartBlock,'Min',1);
set(handles.sldrStartBlock,'Max',max(1,handles.swObj.caseObj.caseData.rf.header.nframes-handles.data.maxFramesToProcess));
set(handles.sldrStartBlock,'Value',p.Results.startBlock);
%setup max info
set(handles.edttxtCurrentStartBlock,'String',num2str(floor(get(handles.sldrStartBlock,'Value'))));
set(handles.figShearWaveAnalysis,'Position',	[6.4000   34.4615   96.4000   38.0769])

set(handles.edtRsqThreshold,'String','0.7')

set(handles.edttxtTemporalFrequency,'Enable','off');

handles.figShearwaveSpeed=figure;



handles=loadDatablock(handles);


handles.guiAreaManager=guiAreaManager;

guiAreaManager('addAxes',guidata(handles.guiAreaManager),get(handles.hShearwaveSpeed,'Parent')); %#ok<GFLD>
guiAreaManager('addAxes',guidata(handles.guiAreaManager),handles.axesBMode); %#ok<GFLD>


% Update handles structure
guidata(hObject, handles);


end

% UIWAIT makes swGUI wait for user response (see UIRESUME)
% uiwait(handles.figShearWaveAnalysis);


% --- Outputs from this function are returned to the command line.
function varargout = swGUI_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on slider movement.
function sldrStartBlock_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to sldrStartBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%setup max info
set(handles.edttxtCurrentStartBlock,'String',num2str(floor(get(handles.sldrStartBlock,'Value'))));


handles=loadDatablock(handles);
% Update handles structure
guidata(hObject, handles);

end


%This function loads a new block and updates the GUI
function handles=loadDatablock(handles)
savedPointer=get(handles.figShearWaveAnalysis,'Pointer');
set(handles.figShearWaveAnalysis,'Pointer','watch');
refresh(handles.figShearWaveAnalysis);
drawnow;
%pause(.1)



if get(handles.chkAdjustTemporalFrequency,'Value')==0
elseif get(handles.chkAdjustTemporalFrequency,'Value')==1
    temporalFrequency=str2double(get(handles.edttxtTemporalFrequency,'String')); %#ok<NASGU>
    error('Need to fix override')
else
    error('chkAdjustTemporalFrequency Value selection is not supported.')
end




set(handles.sldrStartBlock,'Enable','off') %turn off when processing
set(handles.edttxtCurrentStartBlock,'Enable','off') %turn off when processing
set(handles.btnUpdateBlock,'Enable','off') %turn off when processing

requestedDatablock=(0:(handles.data.maxFramesToProcess-1))+(floor(get(handles.sldrStartBlock,'Value'))-1);


handles.swObj.loadBlock(requestedDatablock);
percentOfImageUsed=handles.swObj.analyze;

% [imgBlock] = uread(handles.swObj.caseObj.caseData.rfFilename,requestedDatablock,handles.data.ultrasonixGetFrameParms{:});
imgToShow=handles.swObj.imBmode(1);
shearwaveSpeed_mPerSec=handles.swObj.imShearSpeed_mPerSec;
selectedFrequency_Hz=handles.swObj.temporalFrequency_Hz;

set(handles.edttxtCurrentStartBlock,'String',num2str(requestedDatablock(1)+1));

set(handles.edttxtTemporalFrequency,'String', num2str(handles.swObj.temporalFrequency_Hz))

%The first time through or if the handles are empty we want to  create the
%plots.  this will remove any roi object.  Otherwise we want to just set the CData


%figure(handles.figShearwaveSpeed); imagesc(phaseImg_rad*180/pi); c1=colorbar('ylim',[-180 180],'ytick',(-180:45:180));
figure(handles.figShearwaveSpeed);

shearwaveLim=[-10 10];
shearwaveSpeed_mPerSec(and(~isinf(shearwaveSpeed_mPerSec),shearwaveSpeed_mPerSec<shearwaveLim(1)))=shearwaveLim(1);

if isempty(handles.hShearwaveSpeed)
    handles.hShearwaveSpeed=imagesc(handles.swObj.lateralAxis_mm,handles.swObj.axialAxis_mm,shearwaveSpeed_mPerSec); c1=colorbar;
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
    set(handles.hShearwaveSpeed,'CData',shearwaveSpeed_mPerSec);
end

title(['Shearwave Case ' handles.data.caseStr ' temporal frequency found is ' num2str(selectedFrequency_Hz) 'Hz.' 10  'Valid image: ' num2str(round(percentOfImageUsed*100)) '%. (r)ectangle (e)llipse.'],'interpreter','none');
set(handles.figShearwaveSpeed,'KeyPressFcn',{@plotShearwaveSpeed,get(handles.hShearwaveSpeed,'Parent'),handles.axesBMode,get(handles.axesBMode,'Parent')});



if ~isempty(handles.hShearwaveRsq)
    set(handles.hShearwaveRsq,'CData',handles.swObj.imRsq);
end

if ~isempty(handles.hImPhaseRaw_rad)
    set(handles.hImPhaseRaw_rad,'CData',handles.swObj.imPhaseRaw_rad);
end


axes(handles.axesBMode);  %#ok<MAXES>
if isempty(handles.bModeImage)
    handles.bModeImage=imagesc(handles.swObj.lateralAxis_mm,handles.swObj.axialAxis_mm,handles.data.displayFcn(imgToShow)); colormap(gray);hold on;
    xlabel('Lateral  Distance (mm)')
    ylabel('Axial Depth (mm)')
else
    set(handles.bModeImage,'CData',handles.data.displayFcn(imgToShow));
end
title(['Case ' handles.data.caseStr ' temporal frequency found is ' num2str(selectedFrequency_Hz) 'Hz.' ],'interpreter','none')
set(handles.figShearWaveAnalysis,'KeyPressFcn',{@plotShearwaveSpeed,handles.axesBMode,get(handles.hShearwaveSpeed,'Parent'),get(handles.axesBMode,'Parent')});

set(handles.sldrStartBlock,'Enable','on') %turn on when processing
set(handles.edttxtCurrentStartBlock,'Enable','on') %turn off when processing
set(handles.btnUpdateBlock,'Enable','on') %turn off when processing
set(handles.figShearWaveAnalysis,'Pointer',savedPointer);


%set(handles.figShearwaveSpeed,'KeyPressFcn',{@plotShearwaveSpeed,fft_phase,handles.data.caseStr,imgAngleFilt_rad,fftBinFreqToRealFreq,handles.axesBMode});
end

function plotShearwaveSpeed(src,evnt,primaryAxes,secondaryAxes,dataFigureHandle) %#ok<INUSL>

switch(lower(evnt.Character))
    case 'r'
        primaryRoiObj = imrect(primaryAxes);
        secondaryRoiObj = imrect(secondaryAxes,primaryRoiObj.getPosition);
        
        guiAreaManager('addAreaObject_Callback',-1,[], ...
            guidata(getfield(guidata(dataFigureHandle),'guiAreaManager')), ...
            {primaryRoiObj secondaryRoiObj}, ...
            dataFigureHandle); %#ok<GFLD>
        return;
    case 'e'
        primaryRoiObj = imellipse(primaryAxes);
        secondaryRoiObj = imellipse(secondaryAxes,primaryRoiObj.getPosition);
        
        guiAreaManager('addAreaObject_Callback',-1,[], ...
            guidata(getfield(guidata(dataFigureHandle),'guiAreaManager')), ...
            {primaryRoiObj secondaryRoiObj}, ...
            dataFigureHandle); %#ok<GFLD>
        return;
        
        
    otherwise
        return;
end

end


% --- Executes on button press in btnUpdateBlock.
function btnUpdateBlock_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to btnUpdateBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.sldrStartBlock,'Value',str2double(get(handles.edttxtCurrentStartBlock,'String')))
handles=loadDatablock(handles);
% Update handles structure
guidata(hObject, handles);

end


% --- Executes on button press in chkAdjustTemporalFrequency.
function chkAdjustTemporalFrequency_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to chkAdjustTemporalFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkAdjustTemporalFrequency
if get(hObject,'Value')==0
    set(handles.edttxtTemporalFrequency,'Enable','off')
elseif get(hObject,'Value')==1
    set(handles.edttxtTemporalFrequency,'Enable','on')
else
    error('Invalide setting for the property Value')
end

end


% --------------------------------------------------------------------
function mnuFileGenerateSpreadsheet_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
global phaseLine
% hObject    handle to mnuFileGenerateSpreadsheet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%output the phase line in mm
sheetData={};

for ii=1:length(phaseLine)
    sheetData{end+1,1}=phaseLine(ii).sOutputText; %#ok<AGROW>
    sheetData{end+1,1}='mm'; %#ok<AGROW>
    sheetData{end,2}='deg'; %#ok<AGROW>
    
    for jj=1:length(phaseLine(ii).run.x_mm)
        sheetData{end+1,1}=phaseLine(ii).run.x_mm(jj); %#ok<AGROW>
        sheetData{end,2}=phaseLine(ii).phase_deg(jj); %#ok<AGROW>
        
    end
    sheetData{end+1,1}=''; %#ok<AGROW>
    sheetData{end+1,1}=''; %#ok<AGROW>
end


[fileName,pathName] = uiputfile('*.xls',['Create worksheet ' phaseLine(end).caseStr ' in spreadsheet']);
xlswrite(fullfile(pathName,fileName),sheetData,phaseLine(end).caseStr)
disp(['Worksheet ' phaseLine(end).caseStr ' added'])
end

% --------------------------------------------------------------------
function mnuFileExit_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to mnuFileExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ishandle(handles.figShearwaveSpeed)
    close(handles.figShearwaveSpeed);
end
close(handles.figShearWaveAnalysis);
return
end



function edtRsqThreshold_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to edtRsqThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtRsqThreshold as text
%        str2double(get(hObject,'String')) returns contents of edtRsqThreshold as a double
end


% --------------------------------------------------------------------
function mnuViewShowRsq_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to mnuViewShowRsq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rRsq=handles.swObj.imRsq;

figure;
handles.hShearwaveRsq=imagesc(handles.swObj.lateralAxis_mm,handles.swObj.axialAxis_mm,rRsq); colorbar;
xlabel('Lateral  Distance (mm)')
ylabel('Axial Depth (mm)')
title(['R^2 values for ' handles.data.caseStr])
guidata(hObject, handles);
end

% --------------------------------------------------------------------
function mnuViewShowPhase_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to mnuViewShowPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imPhase_rad = handles.swObj.imPhase_rad;


figure;
handles.hImPhase_rad=imagesc(handles.swObj.lateralAxis_mm,handles.swObj.axialAxis_mm,imPhase_rad); colorbar;
xlabel('Lateral  Distance (mm)')
ylabel('Axial Depth (mm)')
title(['Unwrapped Phase for ' handles.data.caseStr])
guidata(hObject, handles);
end

% --------------------------------------------------------------------
function mnuViewShowRawPhase_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to mnuViewShowRawPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imPhaseRaw_rad = handles.swObj.imPhaseRaw_rad;


figure;
handles.hImPhaseRaw_rad=imagesc(handles.swObj.lateralAxis_mm,handles.swObj.axialAxis_mm,imPhaseRaw_rad); colorbar;
xlabel('Lateral  Distance (mm)')
ylabel('Axial Depth (mm)')
title(['Raw Phase for ' handles.data.caseStr],'interpreter','none')
guidata(hObject, handles);
end

% --------------------------------------------------------------------
function mnuViewShowMag_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to mnuViewShowMag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imPhase_mag = handles.swObj.imPhase_mag;

figure;
handles.hImPhase_mag=imagesc(handles.swObj.lateralAxis_mm,handles.swObj.axialAxis_mm,imPhase_mag); colorbar;
xlabel('Lateral  Distance (mm)')
ylabel('Axial Depth (mm)')
title(['Magnitude coefficients for ' handles.data.caseStr],'interpreter','none')
guidata(hObject, handles);

imgToShow=handles.swObj.imBmode(1);

%%
imgToShowdB=20*log10(imgToShow);
Reject = 30; % noise floor in dB
DynamicRange = 70; % dynamic range in dB
B = 255 * (imgToShowdB - Reject) / DynamicRange;
figure
Bl=imresize(B,4,'bicubic');
imagesc(Bl , [0 255]);
colormap(gray(256));

%%

% 1) Envlople detection
%
% If you have access to RF data you can use the following code to generate the envelope in matlab
% >> Envelop = abs(hilbert(RF));
% In case you have I/Q data use the following code
% >> Envelop = sqrt( I.^2 + Q.^2);
%
% 2) Compression table
%
% Log compression is the most commonly use method to compress the amplitude data
% >> Comp = 20*log10( Env );
%
% 3) Mapping and Displaying
%
% For linear mapping you can use the following code
% >>Reject = 20; % noise floor in dB
% >>DynamicRange = 60; % dynamic range in dB
% >>B = 255 * (Comp - Reject) / DynamicRange;
%
% The "DynamicRange (dB)" and "Reject (dB)" are two key parameters in generating your final B image.
%
% In Sonix systems, your RF data is 16bit signed data. Which means you have 15 bit resolution to show the amplitude. This means the maximum dynamic range that you can have is roughly 90dB. Thus if you reject the first 20dB, you are only left with 70dB signal to work with and setting the dynamic to be more than 70dB will just make your image look darker.
%
% 4) Display
%
% Finally for displaying you B mode image use the following code
% >> imagesc(B , [0 255]);
% >> colormap(gray(256));


end

function [handles,shearwaveGeneratorPosition,roiList]=loadSwGUIMatFile(swGUIMatFile,swGUIMatFile_dataFileRootPath,shearwaveGeneratorPosition,handles)

error('code not finished');
dIn=load(swGUIMatFile); %#ok<UNRCH>

rfBaseName=arrayfun(@(x) x((end-15):(end-8)),swGUIMatFile,'UniformOutput',true);
mtrpCase=arrayfun(@(x) x((end-26):(end-17)),swGUIMatFile,'UniformOutput',true);
rfFilenameList=cellfun(@(mtrpCase,rfBaseName) fullfile(swGUIMatFile_dataFileRootPath,mtrpCase,'shearwave',[rfBaseName '.rf']),mtrpCaseList,rfBaseNameList,'UniformOutput',false);

handles.swObj=shearwaveObject(swCase(rfFilenameList{ii}));

if isfield(dIn.dataStore.swObjSnapshot,'shearwaveGeneratorPosition')
    shearwaveGeneratorPosition=dIn.dataStore.swObjSnapshot.shearwaveGeneratorPosition;
else
    shearwaveGeneratorPosition=[];
end

if isfield(dIn.dataStore,'area')
roiList.type='noArea';
dIn.dataStore
roiList.type='noArea';

[imBackRow,imBackCol]=ind2sub(size(dIn.imBack),find(~isinf(dIn.imBack)));
backRowSz=[min(imBackRow) max(imBackRow)];
backColSz=[min(imBackCol) max(imBackCol)];

[imTriggerRow,imTriggerCol]=ind2sub(size(dIn.imTrigger),find(~isinf(dIn.imTrigger)));
triggerRowSz=[min(imTriggerRow) max(imTriggerRow)];
triggerColSz=[min(imTriggerCol) max(imTriggerCol)];
end

figure;
subplot(1,2,1);
imagesc(dIn.imBack)
%draw from upper left clockwise
hold on
plot(  [backColSz(1) backColSz(2) backColSz(2) backColSz(1) backColSz(1)], [backRowSz(1) backRowSz(1) backRowSz(2) backRowSz(2) backRowSz(1)],'r-');

subplot(1,2,2);
imagesc(dIn.imTrigger)
%draw from upper left clockwise
hold on
plot(  [triggerColSz(1) triggerColSz(2) triggerColSz(2) triggerColSz(1) triggerColSz(1)], [triggerRowSz(1) triggerRowSz(1) triggerRowSz(2) triggerRowSz(2) triggerRowSz(1)],'r-')


end


% --------------------------------------------------------------------
function mnuOptionsUseShearwaveCorrection_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to mnuOptionsUseShearwaveCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch(get(hObject,'Checked'))
    case 'on'
        set(hObject,'Checked','off')
        handles.swObj.useShearwaveCorrection=false;
    case 'off'
        set(hObject,'Checked','on')
        handles.swObj.useShearwaveCorrection=true;
    otherwise
        error(['Invalid checked state of ' get(hObject,'Checked')])
end

end


% --------------------------------------------------------------------
function mnuOptionsVibratorPosition_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to mnuOptionsVibratorPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

function position=getVibratorPosition(handles) %#ok<DEFNU>

if strcmp(get(handles.mnuOptionsVibratorPositionRight,'Checked'),'on') && strcmp(get(handles.mnuOptionsVibratorPositionLeft,'Checked'),'off')
    position='right';
    
elseif strcmp(get(handles.mnuOptionsVibratorPositionRight,'Checked'),'off') && strcmp(get(handles.mnuOptionsVibratorPositionLeft,'Checked'),'on')
    position='left';
    
else
    error('Invalid state of vibrator position.');
end

end

% --------------------------------------------------------------------
function mnuOptionsVibratorPositionLeft_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to mnuOptionsVibratorPositionLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on')
set(handles.mnuOptionsVibratorPositionRight,'Checked','off')
handles.swObj.shearwaveGeneratorPosition='left';
end

% --------------------------------------------------------------------
function mnuOptionsVibratorPositionRight_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to mnuOptionsVibratorPositionRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Checked','on')
set(handles.mnuOptionsVibratorPositionLeft,'Checked','off')
handles.swObj.shearwaveGeneratorPosition='right';
end


% --------------------------------------------------------------------
function mnuViewShowPeakFrequency_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to mnuViewShowPeakFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
peakFrequencyMap_Hz = handles.swObj.peakFrequencyMap_Hz;

figure;
subplot(1,3,[1 2]);
selectFreqH=imagesc(handles.swObj.lateralAxis_mm+(handles.swObj.caseObj.lateralStep_mm/2),handles.swObj.axialAxis_mm+(handles.swObj.caseObj.axialStep_mm/2),peakFrequencyMap_Hz); ylabel(colorbar,'Hz','Rotation',0);
xlabel('Lateral  Distance (mm)')
ylabel('Axial Depth (mm)')
title(['Peak Frequency Values for ' handles.data.caseStr],'interpreter','none')
set(selectFreqH,'ButtonDownFcn',{@plotFreqLine, handles.swObj})
%set(get(selectFreqH,'Parent'),'ButtonDownFcn',@(x) disp('hi'))

subplot(1,3,3)
hist(peakFrequencyMap_Hz(:),115);
xlabel('Frequency (Hz)')
ylabel('Count');
title('Histogram of freq values');
guidata(hObject, handles);

end

function plotFreqLine(src,event,swObj) %#ok<INUSL>
currentPoint=get(get(src,'Parent'),'CurrentPoint');
axialPosition=find(swObj.axialAxis_mm>currentPoint(1,2),1,'first')-1;
lateralPosition=find(swObj.lateralAxis_mm>currentPoint(1,1),1,'first')-1;
freqLine_Hz=swObj.imPhaseIndexFreqProfile_Hz(axialPosition,lateralPosition);
figure; plot(fftshift(swObj.phaseBlockFreqAxis_Hz),fftshift(20*log10(abs(freqLine_Hz)))); title(['Axial, Lateral (' num2str(currentPoint(1,2)) ',' num2str(currentPoint(1,1)) ')/(' num2str(axialPosition) ',' num2str(lateralPosition) ')'])

xlabel('Hz'); ylabel('dB')
end


% --------------------------------------------------------------------
function mnuViewShowBMode_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to mnuViewShowBMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

imgToShow=handles.swObj.imBmode(1);

figure
imagesc(handles.swObj.lateralAxis_mm,handles.swObj.axialAxis_mm,handles.data.displayFcn(imgToShow)); colormap(gray);hold on;
xlabel('Lateral  Distance (mm)')
ylabel('Axial Depth (mm)')
title(['Case ' handles.data.caseStr ],'interpreter','none')

end

