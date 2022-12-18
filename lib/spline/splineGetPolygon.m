%This assumed
function [tendonPolygon,figTendonPosition]=splineGetPolygon(metadata,showPlot)

switch(nargin)
    case 1
        showPlot=true;
    case 2
        %do nothing
    otherwise
        error('Invalid numbe rof input arguments.');
end

figTendonPosition=[];
[metadata]=loadCaseData(metadata);


isLateralDecimated=isCaseLateralDecimated(metadata);

dataReader={'uread',{'decimateLaterial',isLateralDecimated,'frameFormatComplex',true}};

load(metadata.splineFilename,'splineData');

lateral_mm=getCaseRFUnits(metadata,'lateral','mm');
axial_mm=getCaseRFUnits(metadata,'axial','mm');

axialScale=axial_mm/axial_mm;
lateralScale=lateral_mm/axial_mm;
%axialLengthUnits_mm=axial_mm;



%% Setup the sampling points which will be used
%plot image incase need to get new values
switch(dataReader{1})
    case 'ultrasonixGetFrame'
        error('ultrasonixGetFrame is not supported');
    case 'uread'
        [img] = uread(metadata.rfFilename,1,dataReader{2}{:});  %load image first so you know how big the frames are
    case 'mat'
        data=load(dataReader{2});
        img=data.imBlock(:,:,1);
    otherwise
        error(['Unsupported datatype of ' dataReader{1}]);
end

imageWidth_pel=size(img,2);

%activeSplineIndex=getCaseActiveSpline(metadata);
% controlpt.x=splineData(activeSplineIndex).controlpt.x;
% controlpt.y=splineData(activeSplineIndex).controlpt.y;

allSplineData=splinedbSelect(metadata);
topSpline=splineData(strcmp('topSpline',{allSplineData.name}));
if length(topSpline)~=1
    warning('splineGetPolygon:DuplicateTop','Duplicate topSpline found.  Using the last one for case = %s', metadata.sourceMetaFilename);
    topSpline=topSpline(end);
end
bottomSpline=splineData(strcmp('bottomSpline',{allSplineData.name}));
if length(bottomSpline)~=1
    warning('splineGetPolygon:DuplicateBottom','Duplicate bottomSpline found.  Using the last one for case = %s', metadata.sourceMetaFilename);
    bottomSpline=bottomSpline(end);
end
    
    activeSpline=splineData(getCaseActiveSpline(metadata));

samplePointsActive_rc=splineSample(activeSpline.controlpt.x,activeSpline.controlpt.y,imageWidth_pel,lateralScale,axialScale, ...
    'imageWidth_pel',imageWidth_pel,'forceEqualSpace',true);
    
    
samplePointsTop_rc=splineSample(topSpline.controlpt.x,topSpline.controlpt.y,imageWidth_pel,lateralScale,axialScale, ...
    'imageWidth_pel',imageWidth_pel,'forceEqualSpace',true);

samplePointsBottom_rc=splineSample(bottomSpline.controlpt.x,bottomSpline.controlpt.y,imageWidth_pel,lateralScale,axialScale, ...
    'imageWidth_pel',imageWidth_pel,'forceEqualSpace',true);

tendonPolygon.x=[samplePointsTop_rc(2,:) fliplr(samplePointsBottom_rc(2,:))];
tendonPolygon.y=[samplePointsTop_rc(1,:) fliplr(samplePointsBottom_rc(1,:))];




if showPlot
    %% plot the polygon
    
    figTendonPosition=figure;
    
    imagesc(abs(img).^0.5); colormap(gray(256));
    hold on;
    plot([tendonPolygon.x tendonPolygon.x(1)],[tendonPolygon.y tendonPolygon.y(1)],'r','linewidth',2)
    plot(samplePointsActive_rc(2,:),samplePointsActive_rc(1,:),'g','linewidth',2)
    title([getCaseName(metadata)  ' tendon position'],'interpreter','none')
    legend('tendon outline','sampling spline')

    
end

end