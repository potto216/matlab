% [samplePoints_rc]=createHypothesisSetSpline(caseFile,varargin)
%This function builds a hypothesis set from a set of splines and outputs a
%set of sample points.  The function will assume the spline covers the
%entire horizontal length of the image.  If it does not then it will be
%extended.  However the extrapolated points maybe outside the image area.
%If so the entire row is removed.  Trimming is not done
%
%INPUT
%caseFile - The name of the input file to process.
%
%spline set - This is a cell array that specifies a spline and the sample
%points around it to sample.  The cell array takes the form:
%1. {[splineID | splineStruct], translationVector_rc, spacingVector} where:
%
%    splineID - is the method of iding the spline in the spline database.  Currently only an integer
%index is supported.  If the value is empty then the active spline is used.
%translationVector_rc - This optional argument isa translation vector assumed to be a unit vector
%which allows multiple copies of the spline to be created.  If this is
%given then spacingVector must be given.
%
%  splineStruct - are the x/y control points for the spline.  This will
%  skip trying to load the spline from  the file and just use the passed in
%  spline.
%
%   spacingVector - a vector that contains scalar values which are multiplied by the
%translation vector to get the spline copies.  This must be specified if
%the translation vector is specified.
%
%2. {splineID} - creates one spline
%3. {splineID,{'topBottom',{'totalSplines',number}} uses
%As a final note the splineID can be an index of the spline to use or a
%cell which will have the "x" control points as the first element and the
%"y" control points as the second element
%
%dataReader  - This is the type of data reader.  This is a cell array.  
% Below are the following valid values:
%  'ultrasonixGetFrame' - default and uses the ultrasonixGetFrame function to
%    read the data.  Parameters are given by: ultrasonixGetFrameParms
%  {'uread', {parms}} - uses the uread function and the parms cell array
%  {'mat','filename'} - loads the image block from a mat file.
%
%ultrasonixGetFrameParms - The parameters to configure the ultrasonix get
%frame function.  This could be the uread parms if useUread is true.
%
%displayFcn - this is the function used to display the results on the
%screen for the user.  Its default is @(x) = abs(x).^0.5 which reduces the dynamic
%range of the image, but to see the full range of the RF (+-) you could
%pass in a function @(x) absIfIM(x).  The key point is this should be an
%anonymous function.
%
%axialScale - The scale factor between the axial and lateral physical
%measurements.  One of the two should be 1.  If not given it will default
%to 1.
%lateralScale - The scale factor between the axial and lateral physical
%measurements.  One of the two should be 1.  If not given it will default
%to 1.
%
%axialLengthUnits_mm - This is the actual length of an axial pixel and it
%is assumed to be in millimeters.  This assumes your axialScale is 1.
%
%totalSamplePoints - total sample points for the spline
%
%showGraphics - If the graphics should be displayed or not.
%
%OUTPUT
%
%samplePoints_rc - will be a 2 by M by N matrix where the first element of the
%row corresponds to the row of the image and the second element corresponds
%to the column of the image.  The "_rc" means that it is using row,column
%notation with the 1,1 point being in the upper left instead of the
%traditional image processing method of a (column,row) notation. M is the
%length of the hypothesis set and N is the number of hypothesis sets.  Note
%the start index is 1,1 not 0,0.
%
function [samplePoints_rc]=createHypothesisSetSpline(caseFile,splineInformation,varargin)
%% Check the input


p = inputParser;   % Create an instance of the class.
p.addRequired('caseFile', @(x) ischar(x) || isstruct(x));
p.addRequired('splineInformation', @iscell);
p.addParamValue('ultrasonixGetFrameParms',{},@iscell);
p.addParamValue('dataReader',{'ultrasonixGetFrame'},@iscell);
p.addParamValue('displayFcn',@(x) abs(x).^0.5,@(x) isa(x,'function_handle'));
p.addParamValue('axialScale',[],@(x) (isscalar(x) && isnumeric(x) && x>0));
p.addParamValue('lateralScale',[],@(x) (isscalar(x) && isnumeric(x) && x>0));
p.addParamValue('axialLengthUnits_mm',[],@(x) (isscalar(x) && isnumeric(x) && x>0));
p.addParamValue('totalSamplePoints',[],@(x) (isscalar(x) && isnumeric(x) && x>0));
p.addParamValue('showGraphics',true,@(x) islogical(x));



p.parse(caseFile,splineInformation,varargin{:});

ultrasonixGetFrameParms=p.Results.ultrasonixGetFrameParms;
dataReader=p.Results.dataReader;
displayFcn = p.Results.displayFcn;
lateralScale = p.Results.lateralScale;
axialScale = p.Results.axialScale;
axialLengthUnits_mm=p.Results.axialLengthUnits_mm;
totalSamplePoints=p.Results.totalSamplePoints;
showGraphics=p.Results.showGraphics;


% if length(splineInformation)~=1
%     error(['Currently only one spline set is supported.'])
% end

%% load the metadata
[metadata]=loadCaseData(caseFile);
caseStr=getCaseName(metadata);


lateral_mm=getCaseRFUnits(metadata,'lateral','mm');
axial_mm=getCaseRFUnits(metadata,'axial','mm');

if isempty(axialScale)
    axialScale=axial_mm/axial_mm;
end

if isempty(lateralScale)
    lateralScale=lateral_mm/axial_mm;
end

if isempty(axialLengthUnits_mm)
    axialLengthUnits_mm=axial_mm;
end

if isfield(metadata,'splineFilename') && ~isempty(metadata.splineFilename)
    load(metadata.splineFilename,'splineData');
else
    %This better be setup else where such as being passed in by the struct
    %handle
    splineData.controlpt.x=[];
    splineData.controlpt.y=[];
end

%axisRange=metadata.axisRange;

%framesToProcess=getCaseFramesToProcess(metadata);


%% Setup the sampling points which will be used
%plot image incase need to get new values
switch(dataReader{1})
    case 'ultrasonixGetFrame'
        [img] = ultrasonixGetFrame(metadata.rfFilename,1,ultrasonixGetFrameParms{:});  %load image first so you know how big the frames are
    case 'uread'
        [img] = uread(metadata.rfFilename,1,dataReader{2}{:});  %load image first so you know how big the frames are
    case 'mat'
        data=load(dataReader{2});
        img=data.imBlock(:,:,1);        
    otherwise
        error(['Unsupported datatype of ' dataReader{1}]);
end

imageWidth_pel=size(img,2);
if isempty(totalSamplePoints)
    totalSamplePoints=imageWidth_pel;
end

if length(splineInformation)<1
    error('splineInformation must atleast have the spline index of empty')
else
    if isstruct(splineInformation{1})
        activeSplineIndex=1;  %if the struct has been given then 
        splineData.controlpt.x=splineInformation{1}.x;
        splineData.controlpt.y=splineInformation{1}.y;
    else         
        activeSplineIndex=splineInformation{1};
    end
end


if isempty(activeSplineIndex)
    activeSplineIndex=getCaseActiveSpline(metadata);
    controlpt.x=splineData(activeSplineIndex).controlpt.x;
    controlpt.y=splineData(activeSplineIndex).controlpt.y;
elseif iscell(activeSplineIndex)
    controlpt.x=activeSplineIndex{1};
    controlpt.y=activeSplineIndex{2};
else
    controlpt.x=splineData(activeSplineIndex).controlpt.x;
    controlpt.y=splineData(activeSplineIndex).controlpt.y;
end

switch(length(splineInformation))
    case 1
        
        translationVector_rc=[0; 0];
        spacingVector=0;
    case 2 %we must find the top/bottom
        totalSplines=splineInformation{2}{2}{2};
        allSplineData=splinedbSelect(metadata);
        topSpline=splineData(strcmp('topSpline',{allSplineData.name}));
        if length(topSpline)~=1
            warning(['Duplicate topSpline found.  Using the last one for case = ' caseFile.sourceMetaFilename]);
            topSpline=topSpline(end);
        end
        bottomSpline=splineData(strcmp('bottomSpline',{allSplineData.name}));
        if length(bottomSpline)~=1
            warning(['Duplicate bottomSpline found.  Using the last one for case = ' caseFile.sourceMetaFilename]);
            bottomSpline=bottomSpline(end);
        end        
        %Have the middle spline match the middle distance of 
        matchPtX=imageWidth_pel/2;
        topMatchPtY=spline(topSpline.controlpt.x,topSpline.controlpt.y,matchPtX);
        bottomMatchPtY=spline(bottomSpline.controlpt.x,bottomSpline.controlpt.y,matchPtX);
        activeMatchPtY=spline(controlpt.x,controlpt.y,matchPtX);
        controlpt.y=controlpt.y+(topMatchPtY-activeMatchPtY);
        translationVector_rc=[1; 0];
        spacingVector=((bottomMatchPtY-topMatchPtY)/totalSplines)*[0:(totalSplines-1)];
    case 3
        translationVector_rc=splineInformation{2};
        spacingVector=splineInformation{3};
    otherwise
        error('Invalid number of spline arguments');
end



if ~all(size(translationVector_rc)==[2,1])
    error('translationVector_rc must be a column vector of length 2')
end

samplePointsBase_rc=splineSample(controlpt.x,controlpt.y,totalSamplePoints,lateralScale,axialScale, ...
    'imageWidth_pel',imageWidth_pel,'forceEqualSpace',true);

%okay we will build up the the sample point matrix  The keys here to get
%the correct dimensions are that the needed for the matrix
samplePoints_rc=repmat(reshape(kron(translationVector_rc,reshape(spacingVector,1,[])),2,1,[]),[1 size(samplePointsBase_rc,2) 1]);
if false
    %%
    figure;
    for dd=1:size(samplePoints_rc,3)
    plot(samplePoints_rc(2,:,dd),samplePoints_rc(1,:,dd),'bo')
    hold on;
    end
    title(caseStr,'interpreter','none')
    
end

samplePoints_rc=samplePoints_rc+repmat(samplePointsBase_rc,[1,1,size(samplePoints_rc,3)]);
%Currently the code looks for tpoints that are outside the image.  If a
%single point is outside the image then the entire spline is removed.  It
%is not trimmed to fit a shape
[d1 d2 badRowIndex]=ind2sub([1 size(samplePoints_rc,2) size(samplePoints_rc,3)],find((samplePoints_rc(1,:,:)<1) | (samplePoints_rc(1,:,:)>size(img,1))));
if ~isempty(badRowIndex)
    badRowsToRemove=unique(badRowIndex);
    disp(['createHypothesisSetSpline--Removing the rows ' num2str(reshape(badRowsToRemove,1,[]))])
    samplePoints_rc(:,:,badRowIndex)=[];
else
    %do nothing
end

if showGraphics
    %%
    figure;
    if isempty(axialLengthUnits_mm)
        imagesc(displayFcn(img)); colormap(gray);
        hold on; plot(samplePointsBase_rc(2,:),samplePointsBase_rc(1,:),'r');
        flatSamplePoints_rc=reshape(samplePoints_rc,2,[],1);
        plot(flatSamplePoints_rc(2,:),flatSamplePoints_rc(1,:),'go')
        legend('spline','selected sample points');
        hold off;
        title(caseStr,'interpreter','none')
    else
        axialAxis=linspace(0,(size(img,1)*axialLengthUnits_mm),size(img,1));
        lateralAxis=linspace(0,(size(img,2)*axialLengthUnits_mm*lateralScale),size(img,2));
        imagesc(lateralAxis,axialAxis,displayFcn(img)); colormap(gray);
        hold on; plot(samplePointsBase_rc(2,:)*max(lateralAxis)/size(img,2),samplePointsBase_rc(1,:)*max(axialAxis)/size(img,1),'r');
        flatSamplePoints_rc=reshape(samplePoints_rc,2,[],1);
        plot(flatSamplePoints_rc(2,:)*max(lateralAxis)/size(img,2),flatSamplePoints_rc(1,:)*max(axialAxis)/size(img,1),'go')
        legend('spline','selected sample points');
        hold off;
        title(caseStr,'interpreter','none')
        xlabel('mm');
        ylabel('mm');
    end
    
    
    
    
end



end