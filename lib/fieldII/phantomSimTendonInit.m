%Create a computer model of a tendon phantom. The phantom is designed
%by using a user defined spline for the center of the tendon which is then
%populated with random point scatters.  These sctters can then be applied
%to parallel curves in a different pseudo random pattern.  The model
%removes any background points from the tendon
%
%The basic tendon images
%start 6mm/0mm
%min tendon depth 8mm/2mm
%max tendon depth 15mm/9mm
%max image depth 20mm/14mm
%width 60mm
%
%INPUTS
%totalBackgroundScatters - the total number of background scatters used
%totalTendonScattersPerBand - the total number of tendon scatters used per band.
%caseFilename - This file will configure the phantom to model a collect
%geometry.
%totalBandsPerTendon - The total bands per tendon

function phantomData = phantomSimTendonInit(varargin)

fid=1;
caseFilenameNotUsed=-1;

p = inputParser;   % Create an instance of the class.
p.addParamValue('totalBackgroundScatters',10000, @(x) (isnumeric(x) && isscalar(x)));
p.addParamValue('totalTendonScattersPerBand',300, @(x) (isnumeric(x) && isscalar(x)));
p.addParamValue('totalBandsPerTendon',12, @(x) (isnumeric(x) && isscalar(x)));
p.addParamValue('caseFilename',caseFilenameNotUsed,  @(x) ischar(x) || isempty(x));
p.addParamValue('verbose',true,  @(x) islogical(x));

p.parse(varargin{:});



totalBackgroundScatters = p.Results.totalBackgroundScatters;
totalTendonScattersPerBand = p.Results.totalTendonScattersPerBand;
totalBandsPerTendon=p.Results.totalBandsPerTendon;
caseFilename=p.Results.caseFilename;
verbose=p.Results.verbose;

tendonAmplitude=15;
%% First load the spline info
%
if caseFilename==caseFilenameNotUsed
    disp('Using prestored values for phantom')
    xSize_m = 60/1000;   %  Width of phantom [mm]
    ySize_m = 5/1000;   %  Transverse width of phantom [mm]
    zSize_m = 20/1000;   %  Height of phantom [mm]
    
    
else
    [metadata]=loadCaseData(caseFilename);
    
    
    imageWidth_pel=getCaseLateralPixelCount(metadata);
    totalSplines=totalBandsPerTendon;
    load(metadata.splineFilename,'splineData');
    
    activeSplineData=splinedbSelectActive(metadata);
    allSplineData=splinedbSelect(metadata);
    topSpline=splineData(strcmp('topSpline',{allSplineData.name}));
    
    if length(topSpline)~=1
        warning(['Duplicate topSpline found.  Using the last one for case = ' metadata.sourceMetaFilename]);
        topSpline=topSpline(end);
    end
    
    bottomSpline=splineData(strcmp('bottomSpline',{allSplineData.name}));
    if length(bottomSpline)~=1
        warning(['Duplicate bottomSpline found.  Using the last one for case = ' metadata.sourceMetaFilename]);
        bottomSpline=bottomSpline(end);
    end
    
    
    
    
    %match the middle distance
    matchPtX=imageWidth_pel/2;
    topMatchPtY=spline(topSpline.controlpt.x,topSpline.controlpt.y,matchPtX);
    bottomMatchPtY=spline(bottomSpline.controlpt.x,bottomSpline.controlpt.y,matchPtX);
    activeMatchPtY=spline(activeSplineData.controlpt.x,activeSplineData.controlpt.y,matchPtX);
    %Put the active spline at the top of the image
    activeSplineData.controlpt.y=activeSplineData.controlpt.y+(topMatchPtY-activeMatchPtY);
    
    
    lateral_mm=getCaseRFUnits(metadata,'lateral','mm');
    axial_mm=getCaseRFUnits(metadata,'axial','mm');
    xSize_m=getCaseLateralPixelCount(metadata)*lateral_mm/1000;
    ySize_m = 5/1000;   %  Transverse width of phantom [mm]
    zSize_m=metadata.rf.header.h*axial_mm/1000;
    phantomData.caseData.caseFilename=caseFilename;
    phantomData.caseData.metadata=metadata;
    axialSpacing_m=((bottomMatchPtY-topMatchPtY)/totalSplines)*(0:(totalSplines-1))*(axial_mm/1000);
    
end

if verbose
    fprintf(fid,'The phantom x,y,z dimensions are: (%0.2f, %0.2f, %0.2f) mm.\n', xSize_m*1000,ySize_m*1000,zSize_m*1000);
end

%  Create the general scatterers
N=totalBackgroundScatters; %-size(samplePoints_mm,2);
x_m = (rand (N,1)-0.5)*xSize_m;
y_m = (rand (N,1)-0.5)*ySize_m;
z_m = rand (N,1)*zSize_m;

phantomData.xLim_m =[-(xSize_m/2) (xSize_m/2)];   %  Width of phantom
phantomData.yLim_m =[-(ySize_m/2) (ySize_m/2)];   %  Lateral
phantomData.zLim_m =[0  zSize_m];   %   Height of phantom

%



%  Generate the amplitudes with a Gaussian distribution
if caseFilename~=caseFilenameNotUsed
    
    
    samplePointsContinuous_rc_mm=splineSample(activeSplineData.controlpt.x,activeSplineData.controlpt.y, ...
        totalTendonScattersPerBand, ... %getCaseLateralPixelCount(metadata), ...
        lateral_mm,axial_mm,'forceEqualSpace',true,'samplePointsOutputFormat','scale','imageWidth_pel',getCaseLateralPixelCount(metadata));
    
    samplePointsContinuous_rc_m=(samplePointsContinuous_rc_mm+repmat([0; phantomData.xLim_m(1)*1000],1,size(samplePointsContinuous_rc_mm,2)))/1000;
    
    sx_m=activeSplineData.controlpt.x*lateral_mm/1000+phantomData.xLim_m(1);
    sz_m=activeSplineData.controlpt.y*axial_mm/1000+phantomData.zLim_m(1);
    
    
    sxx_m = samplePointsContinuous_rc_m(2,:);
    szz_m = samplePointsContinuous_rc_m(1,:);
else
    if false
        %create a spline
        figure; %#ok<UNRCH>
        plot(x_m,z_m,'b.')
        axis([-(xSize_m/2) (xSize_m/2) 0 (zSize_m)])
        xlabel('m');
        ylabel('m');
        a1=gca;
        set(a1,'YDir','reverse')
        [sx_m,sz_m]=ginput;
    end
    sx_m = [ 0.0288 0.0214  0.0075   -0.0055   -0.0165   -0.0292];
    sz_m =[ 0.0101    0.0122    0.0145    0.0143    0.0134    0.0121];
    sxx_m = linspace(phantomData.xLim_m(1),phantomData.xLim_m(2),totalTendonScattersPerBand);
    szz_m = spline(sx_m,sz_m,sxx_m);
end



amp=randn(totalBackgroundScatters,1);
%  Return the variables
phantomData.background.x_m=x_m;
phantomData.background.y_m=y_m;
phantomData.background.z_m=z_m;
phantomData.background.amplitude=amp(:);

%This must step from closest laterial position to farthest so the removal
%code will work
for ii=1:totalBandsPerTendon
    phantomData.tendon.band(ii).x_m=sxx_m(:);
    phantomData.tendon.band(ii).y_m=(rand (length(sxx_m),1)-0.5)*4/1000;
    %phantomData.tendon.band(ii).z_m=szz_m(:)+((ii-5)/4)/1000-1.1174/1000;
    phantomData.tendon.band(ii).z_m=szz_m(:)+axialSpacing_m(ii);
    phantomData.tendon.band(ii).amplitude=tendonAmplitude*randn(length(sxx_m),1);
    phantomData.tendon.band(ii).spline.controlpt.x_m=sx_m;
    phantomData.tendon.band(ii).spline.controlpt.z_m=sz_m;
end




if false
    %%
    figure; %#ok<UNRCH>
    plot(phantomData.background.x_m,phantomData.background.z_m,'b.')
    hold on;
    for ii=1:3
        plot(phantomData.tendon.band(ii).x_m,phantomData.tendon.band(ii).z_m,'r.')
    end
    axis([-(xSize_m/2) (xSize_m/2) 0 (zSize_m)])
    xlabel('m');
    ylabel('m');
    a1=gca;
    set(a1,'YDir','reverse')
    title('Scatter placement.')
    legend('background','tendon')
end

%% Now we want to remove the background scatters from the tendon image
chkDistTopx=[phantomData.tendon.band(1).x_m(1:end-1).';phantomData.tendon.band(1).x_m(2:end).'];
chkDistTopz=[phantomData.tendon.band(1).z_m(1:end-1).';phantomData.tendon.band(1).z_m(2:end).'];
chkDistBottomx=[phantomData.tendon.band(end).x_m(1:end-1).';phantomData.tendon.band(end).x_m(2:end).'];
chkDistBottomz=[phantomData.tendon.band(end).z_m(1:end-1).';phantomData.tendon.band(end).z_m(2:end).'];

dprodTop=zeros(length(phantomData.background.x_m),1);
dprodBottom=zeros(length(phantomData.background.x_m),1);

%We remove the points by seeing if they fall in the range of top and bottom
%and then checking to see if dot

if verbose
    fprintf(fid,'Removing background points in the tendon boundary.  This may take a while.\n');
end
for tt=1:length(phantomData.background.x_m)
    topIndex=find((phantomData.background.x_m(tt)>=chkDistTopx(1,:)) &  (phantomData.background.x_m(tt)<chkDistTopx(2,:)));
    bottomIndex=find((phantomData.background.x_m(tt)>=chkDistBottomx(1,:)) &  (phantomData.background.x_m(tt)<chkDistBottomx(2,:)));
    
    if length(topIndex)~=1 || length(bottomIndex)~=1
        dprodTop(tt)=1;
        dprodBottom(tt)=1;
    else
        vt=diff([-chkDistTopz(:,topIndex) chkDistTopx(:,topIndex)]',1,2);
        vts=diff([chkDistTopx(1,topIndex) phantomData.background.x_m(tt); chkDistTopz(1,topIndex) phantomData.background.z_m(tt)],1,2);
        
        vb=diff([-chkDistBottomz(:,topIndex) chkDistBottomx(:,topIndex)]',1,2);
        vbs=diff([chkDistBottomx(1,topIndex) phantomData.background.x_m(tt); chkDistBottomz(1,topIndex) phantomData.background.z_m(tt)],1,2);
        
        %figure; plot([0 vt(1)],[0,vt(2)],'b'); hold on; plot([0 vts(1)],[0,vts(2)],'r:');
        dprodTop(tt)=vt'*vts/sqrt(vt'*vt*(vts'*vts));
        dprodBottom(tt)=vb'*vbs/sqrt(vb'*vb*(vbs'*vbs));
        %         if ~((dprodTop(tt)>0  & dprodBottom(tt)<0))
        %             disp('fail')
        %         end
        
    end
    
end


ptsInsideTendonIdx=(dprodTop>0  & dprodBottom<0);


%%
if false
    %%
    f1=figure; %#ok<UNRCH>
    plot3(phantomData.background.x_m(~ptsInsideTendonIdx),phantomData.background.y_m(~ptsInsideTendonIdx),phantomData.background.z_m(~ptsInsideTendonIdx),'r.')
    hold on
    plot3(phantomData.background.x_m(ptsInsideTendonIdx),phantomData.background.y_m(ptsInsideTendonIdx),phantomData.background.z_m(ptsInsideTendonIdx),'b.')
    
    plot3(phantomData.tendon.band(1).x_m,phantomData.tendon.band(1).x_m*0,phantomData.tendon.band(1).z_m,'g.')
    plot3(phantomData.tendon.band(end).x_m,phantomData.tendon.band(end).x_m*0,phantomData.tendon.band(end).z_m,'g.')
    
    xlabel('lateral distance (m)')
    zlabel('axial distance (m)')
end

% remove the background points
phantomData.background.x_m(ptsInsideTendonIdx)=[];
phantomData.background.y_m(ptsInsideTendonIdx)=[];
phantomData.background.z_m(ptsInsideTendonIdx)=[];
phantomData.background.amplitude(ptsInsideTendonIdx)=[];

if verbose
    fprintf(fid,'Background points removal complete.\n');
end