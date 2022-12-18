%% This function finds the translational motion of a 1-D image slice over time.
%Each image slice is stored as a column in mmodeImg.  Time is assumed to
%increase with increasing column number. The function finds the shift value
%with the highest correlation between adjacent columns.
%
%mmodeImg - a matrix whose columns are snapshots of the 1-D image over
%time.  the columns represent the frame number.
%
%frame - is the frame number that will be matched to its adjacent value.
%This corresponds to the column index of mmodeImg.
%
%roiTemplate - the region of interest template is the template from
%(frame-1) which will be compared to the roiSearch in frame.  These are the
%index values.
%
%roiSearch - This two valued vector is the region in frame to try and match
%roiTemplate.
%
%corrInterpMethod - The method used for interpolation of the correlation result.  This can be any of the
%methods used by the interp1 function or if 'interp' it will call the
%signal processing function interp which uses since interpolation. Default
%is interp1's nearest neighbor function.
%
%corrInterpFactor - The interpolation factor which is a default of 100.
%
%signalInterpMethod - The method used for interpolation of the correlation result.  This can be any of the
%methods used by the interp1 function or if 'interp' it will call the
%signal processing function interp which uses since interpolation. Default
%is interp1's nearest neighbor function.
%
%signalInterpFactor - The interpolation factor which is a default of 1
%which means interpolation is not used
%
%templateFrameOffset - is the offset of the template in relation to the
%search frame.  The default is -1 which means that the search frame uses
%the previous frame as a template.  The correlation match is scaled by the
%shift to account for the fact there is a larger seperation distance.
%Output
%The values returned are:
%
%corrMatch - This value is the amount of movement of frame in relation to frame-1.
%A positive value means that a point in a frame moved right while a
%negative value means it moved left.  A value of 0 means no movement.  So
%for example:
% corrMatch=0 would mean no movement.
% row index  1           11
% frame k-1  [-----*-----]
% frame k    [-----*-----]
%
% corrMatch=-3 would mean movement to the left in relation to frame k-1.
% frame k-1  [-----*-----]
% frame k    [--*--------]
%
% corrMatch=3 would mean movement to the right in relation to frame k-1.
% frame k-1  [-----*-----]
% frame k    [--------*--]
%
%corrMaxVal - The value of the correlation at corrMatch.
%
%corr - The actual correlation values as the template is correlated over the
%search interval. corrMatch does not correspond to the index values here.
%corr(1) maps to the index roiSearch(1) where the first target is cut out.
%corr is a column vector
%
%hitRail - a logical valued scalar which says if the rail was hit by the max correlation value.
%
%validCorr - this says if the correlation value is valid.  This is useful
%at the start (boundaries) when the first several shifts may not have data
%to process.
function [corrMatch, corrMaxVal, corr, hitRail,validCorr] = compute1DSpeckleTrack(mmodeImg, frame,roiTemplate,roiSearch,varargin)
%%
%% Load the data and setup the default regions
p = inputParser;   % Create an instance of the class.
p.addRequired('mmodeImg', @(x) (ndims(x)==2) && isnumeric(x));
p.addRequired('frame', @(x) isnumeric(x) && isscalar(x) && (x>0)  && isNoFraction(x));
p.addRequired('roiTemplate', @(x) isnumeric(x) && isvector(x));
p.addRequired('roiSearch', @(x) isnumeric(x) && isvector(x));
p.addParamValue('corrInterpMethod','nearest',  @(x) any(strcmp(x,{'interp','nearest','linear','spline','pchip','cubic','v5cubic'})));
p.addParamValue('corrInterpFactor',100,  @(x) isnumeric(x) && isscalar(x) && (x>0)  && isNoFraction(x));
p.addParamValue('signalInterpMethod','nearest',  @(x) any(strcmp(x,{'interp','nearest','linear','spline','pchip','cubic','v5cubic'})));
p.addParamValue('signalInterpFactor',1,  @(x) isnumeric(x) && isscalar(x) && (x>0)  && isNoFraction(x));
p.addParamValue('templateFrameOffset',-1,  @(x) isnumeric(x) && isscalar(x) && isNoFraction(x));



p.parse(mmodeImg, frame,roiTemplate,roiSearch, varargin{:});

corrInterpMethod=p.Results.corrInterpMethod;
corrInterpFactor=p.Results.corrInterpFactor;
templateFrameOffset=p.Results.templateFrameOffset;

skip =1;    %how many samples to skip when matching the template to the target.

%we need to make sure that the frame exceeds the offset value so 
if (((frame+templateFrameOffset)<1) || ((frame+templateFrameOffset)>size(mmodeImg,2)) )
    corrMatch = 0;
    corrMaxVal = 0;
    corr=zeros((roiSearch(end)-length(roiTemplate))-roiSearch(1)+1,1);
    hitRail=false;
    validCorr=false;
    return;
else
    validCorr = true;
    template = mmodeImg(roiTemplate,frame+templateFrameOffset);
    template = template; % .* hanning(length(template));
    
    
    template=template-mean(template);
    %The roiSearch(end)-length(roiTemplate) prevents the search from going
    %past the end of the roiSearch region.
    for k = roiSearch(1):skip:roiSearch(end)-length(roiTemplate)
        target = mmodeImg(k:k+length(roiTemplate)-1,frame);
        
        target=target-mean(target);
        %target = target .* hanning(length(target));
        %corr(1) maps to the index roiSearch(1) where the first target is
        %cut out
        crossCorrelationEnergy=sqrt(abs((template'*template)*(target'*target)));
        if crossCorrelationEnergy<1e-4
            corr(k-roiSearch(1)+1) = 0;
        else
            corr(k-roiSearch(1)+1) = (template'*target)/crossCorrelationEnergy;
        end
        
        
    end
    
    
    
    switch(corrInterpMethod)
        case 'interp'
            %perform a peak search with oversampling if requested.
            %the final range is (0,length(corr)].  Note it is no longer [1,length(corr)]
            %this is because the interp function inserts zeros inbetween the
            %samples which adjusts the offset to the left
            [corrMaxVal,corrMatch] = max(interp(corr,corrInterpFactor));
            
            corrMatch = corrMatch/corrInterpFactor;
            
           
            %To find the offset moved we find the different between the start of the search region where
            %the template is in the previous frame.
            %Ordinarly we would to map the first index 1 to roiSearch(1) so we need
            %subtract 1.  However because we used interp corrMatch can now take
            %on the values (0,length(corr)]            
        case {'nearest','linear','spline','pchip','cubic','v5cubic'}
            %The points here are quantization points that the data can be
            %aligned with.  We can just divide since the value will range from
            %[1,length(corr)]
            xi=linspace(0,length(corr)-1,corrInterpFactor*length(corr));
            corrInterp1=interp1((0:(length(corr)-1)),corr,xi,corrInterpMethod);
            [corrMaxVal,corrMatchIdx] = max(corrInterp1);
            corrMatch = xi(corrMatchIdx);
  
            %To find the offset moved we find the different between the start of the search region where
            %the template is in the previous frame.
            %Ordinarly we would to map the first index 1 to roiSearch(1) so we need
            %subtract 1.  However because we used interp corrMatch can now take
            %on the values (0,length(corr)]
            
        otherwise
            error(['Invalid interp method of ' corrInterpMethod]);
    end
    
    
    
    if any(repmat(round(corrMatch),1,2)==[0 length(corr)])
        hitRail=true;
    else
        hitRail=false;
    end
    corrMatch = ((corrMatch)+(roiSearch(1)-roiTemplate(1)))/abs(templateFrameOffset);
    corr=reshape(corr,[],1);
    
    
end
