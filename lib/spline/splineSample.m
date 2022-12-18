%splineSample - produces sample points on a spline of uniform distance.  It
%assumes that the pixels are square.  totalSamplePoints samples points are
%evenly distributed along the spline.  This function assumes that the
%control points are based on an image where 1 is the start and
%totalSamplePoints is the total number of horizontal pixels.
%
%INPUT
%controlptX - the spline's X control points in pixel values by default
%
%controlptY - the spline's Y control points in pixel values by default
%
%totalSamplePoints - The number of sample points used to create the
%lattice.  This is the maximum number of horizontal pixels.  If this is
%empty then distanceDelta needs to be specified.  It is important to
%remember the assumption is that the image is totalSamplePoints long
%horizontally if imageWidth_pel is not specified, therefore it is
%important to make sure totalSamplePoints is less than or equal to the
%image width
%
%xptScale - The amount to scale the x coordinate.  Normally either the
%xptScale or the yptScale will be 1.
%
%yptScale - The amount to scale the y coordinate.
%
%overSampleFactorArcLengthCalc - The amount of oversampling applied to
%totalSamplePoints times to improve the arc distance measurement.
%
%distanceDelta - The distance between
%
%forceEqualSpace - This forces the samples points to be equal spaced along
%the spline.  If false then 1:totalSamples is returned for the X coordinte.
%
%samplePointsOutputFormat - This defines the output format of samplePoints_rc.
%The values are:
%'pixel' - The screen pixels.
%'scale' - measured in the  scale units passed in.
%
%imageWidth_pel - The horizontal image width in pels.  If it is not
%specified it will default to totalSamplePoints.
%OUTPUT
%samplePoints_rc is a 2 by totalSamplePoints length matrix with the number
%of sample points.
%
%totalSplineLength - This is the total length of the spline which was
%computed.
%
function [samplePoints_rc,totalSplineLength,samplePointsDerivative_rc]=splineSample(controlptX,controlptY,totalSamplePoints,xptScale,yptScale,varargin)
%% compute spline sample area.

p = inputParser;   % Create an instance of the class.
p.addRequired('controlptX', @(x) isvector(x) && isnumeric(x));
p.addRequired('controlptY', @(x) isvector(x) && isnumeric(x));
p.addRequired('totalSamplePoints', @(x) isvector(x) && isnumeric(x));
p.addRequired('xptScale', @(x) isscalar(x) && isnumeric(x));
p.addRequired('yptScale', @(x) isscalar(x) && isnumeric(x));
p.addParamValue('overSampleFactorArcLengthCalc', 100,@(x) isscalar(x) && isnumeric(x));
p.addParamValue('distanceDelta', [], @(x) (isscalar(x) && isnumeric(x)) || (isempty(x)));
p.addParamValue('forceEqualSpace', true, @(x) (isscalar(x) && islogical(x)));
p.addParamValue('imageWidth_pel', [], @(x) (isscalar(x) && isnumeric(x) && x>0));
p.addParamValue('samplePointsOutputFormat','pixel',@(x) any(strcmp(x,{'pixel','scale'})))

p.parse(controlptX,controlptY,totalSamplePoints,xptScale,yptScale,varargin{:});

overSampleFactorArcLengthCalc=p.Results.overSampleFactorArcLengthCalc;
distanceDelta=p.Results.distanceDelta; %#ok<NASGU>
forceEqualSpace=p.Results.forceEqualSpace;
samplePointsOutputFormat=p.Results.samplePointsOutputFormat;
imageWidth_pel=p.Results.imageWidth_pel;

if isempty(imageWidth_pel)
    imageWidth_pel=totalSamplePoints;
else
    %do nothing
end

samplePoints_rc=zeros(2,totalSamplePoints);
samplePointsDerivative_rc=zeros(2,totalSamplePoints);

splineH = spline(controlptX,controlptY);




%     if forceEqualSpace
%     else
%     xos=1:imageWidth_pel;
%     yos = ppval(splineH,xos);
%     samplePoints_rc(:,:)=[yos; xos];
%     yos = ppval(splineH,xos);
% end


if forceEqualSpace
    %Oversample the number of points and then integerate the length to
    xos=((1*overSampleFactorArcLengthCalc):(imageWidth_pel*overSampleFactorArcLengthCalc))/overSampleFactorArcLengthCalc;
    %yos = spline(controlptX,controlptY,xos);
    yos = ppval(splineH,xos);
    
    %Here we are interested in arc length (BTW - this is not the integral of
    %the spline which is the area under the spline)
    d=sqrt((xptScale*diff(xos)).^2+(yptScale*diff(yos)).^2);
    sd=cumsum([ 0 d]); % add zero for start
    
    totalSplineLength=sd(end);
    
    if false
        %% Verify that the integration produces a resonable measure of distance
        figure; %#ok<UNRCH>
        subplot(1,2,1)
        plot(d); title('Delta Distance');
        subplot(1,2,2)
        plot(sd); title('Sum Distance');
        
    end
    
    %Scale the cumsum so that it will scale the sample points
    asd=reshape(sd,1,[]);
    %find the closest value to the ideal sample point which is equal
    %spaced along the spline
    idealsamplePoints=linspace(0,totalSplineLength,size(samplePoints_rc,2));
    
    if false
        %% Plot the actual distance between oversampled points and the ideal distance
        figure; %#ok<UNRCH>
        plot(linspace(1,length(idealsamplePoints),length(asd)),asd,'b');
        hold on;
        plot(idealsamplePoints,'rd');
        legend('actual distance','ideal distance')
        ylabel('distance')
    end
    
    for ii=1:size(samplePoints_rc,2)
        [minVal, minIdx]=min(abs(repmat(idealsamplePoints(ii),1,size(asd,2))-asd)); %#ok<ASGLU>
        samplePoints_rc(:,ii)=[yos(minIdx); xos(minIdx)];
    end
else %just use the totalsample points to determine the width
    samplePoints_rc(2,:)=linspace(1,imageWidth_pel,totalSamplePoints);
    samplePoints_rc(1,:)=ppval(splineH,samplePoints_rc(2,:));
end

samplePointsDerivative_rc(1,:)= ppval(fnder(splineH),samplePoints_rc(2,:));
samplePointsDerivative_rc(2,:)=1;  %The slope is one


%%See how good the equal sampling is:
if false
    %%
    figure;
    plot(sqrt(sum(diff([yptScale 0; 0 xptScale]*samplePoints_rc,1,2).^2,1)),'b')
    title('With scaling')
end




switch(samplePointsOutputFormat)
    case 'pixel'
        %         %Scale the cumsum so that it will scale the sample points
        %         asd=reshape(sd/(max(sd))*size(samplePoints_rc,2),1,[]);
        %         %find the closest value to the sample point
        %         for ii=1:size(samplePoints_rc,2)
        %
        %             [minVal, minIdx]=min(abs(repmat(ii,1,size(asd,2))-asd)); %#ok<ASGLU>
        %             samplePoints_rc(:,ii)=[yos(minIdx); xos(minIdx)];
        %         end
        
        
    case 'scale'
        samplePoints_rc=[yptScale 0; 0 xptScale]*samplePoints_rc;
        samplePointsDerivative_rc=[yptScale 0; 0 xptScale]*samplePointsDerivative_rc;
    otherwise
        error(['Unsupported samplePointsOutputFormat of ' samplePointsOutputFormat])
end


end