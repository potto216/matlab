%unitAmount=getCaseRFUnits(caseData,unitDimension,unitMeasure) returns the unit amount for the requested dimension and measure.
%
%DESCRIPTION
%Returns the unit amount for the requested dimension and measure.  The facetors that effect 
%The code
%looks at the line density
%Measurements come from Transducer Specification Sheet.pdf Ultrasonix Medical Corporation
%Last Updated: August 2009
%
%INPUT
%metadata - The casename is the filename without the extension or the raw metadata.
%unitDimension - can be either axial or lateral.
%unitMeasure - can be:
%   mm - the amount of millimeters.
%   scale - the scale in relation to the other dimension.  So if axial was
%   chosen it would be the ratio (axial in mm)/(lateral in mm)
%lateralPixelCount - If the unitDimension is lateral then the pixel count
%for the image you are computing needs to be passed in.  If not the header.w (width)
% divided by the decimation factor will be used from the rf file which will not be correct if you are not
%interpolating the lines.  This value can also be a cell containg the
%arguments for the ultrasound frame reader function.
%
%OUTPUT
%unitAmount - the amount of the unit being measured.
%
function unitAmount=getCaseRFUnits(metadata,unitDimension,unitMeasure, lateralPixelCount)
metadata=loadCaseData(metadata);

switch(nargin)
    case 3
        lateralPixelCount=getCaseLateralPixelCount(metadata); 
    case 4
        %do nothing
    otherwise
        error('Invalid number of input arguments.');
end

if iscell(lateralPixelCount)
    p = inputParser;   % Create an instance of the class.
    p.KeepUnmatched=true;  %prevents matlab from throwing an error when other arguments are evaluated
    p.addParamValue('skipEvenRows',false,@islogical);
    p.parse(lateralPixelCount{:});
    
    if (p.Results.skipEvenRows)
        lateralPixelCount=metadata.rf.header.w/2;
    else
        lateralPixelCount=metadata.rf.header.w;
    end    
    
end





switch(metadata.rf.probeModel)
    case 'L14-5/38'
        elementPitch_mm=0.3048;
        elementCount=128;
    case 'L14-5W/60'
        elementPitch_mm=0.4720;
        elementCount=128;   
    otherwise
        error(['Unsupported probe model of ' metadata.rf.probeModel]);
end

%The axial pixel length can be computed by dividing the speed of sound in
%tissue by the sample rate and dividing all of that by 2 because of the
%time needed to hit the target and return.
%average speed of sound in soft tissue 1540 m/s everywhere in body
%so 1540*1000mm
%metadata.rf.header.sf is assumed to be in samples/sec so that final units are
% m     mm     s             mm
%---- -----  --------  =  --------
% s      m     sample      sample
axial_mm=1540*1000/(metadata.rf.header.sf*2);

%The lateral size in relation to the header is the total elements times
%each pitch then divided by the header size listed
lateralDistancePerWidthUnit_mm=elementPitch_mm*elementCount/metadata.rf.header.ld;

switch(unitDimension)
    case 'axial'
        switch(unitMeasure)
            case 'mm'
                unitAmount=axial_mm;
            case 'scale'
                error('not supported')
            otherwise
                error(['Invalid unit measure of ' unitMeasure]);
        end
    case 'lateral'
        switch(unitMeasure)
            case 'mm'
                
                unitAmount=lateralDistancePerWidthUnit_mm*metadata.rf.header.w/lateralPixelCount;
            case 'scale'
                unitAmount=((lateralDistancePerWidthUnit_mm*metadata.rf.header.w)/lateralPixelCount)/axial_mm;
            otherwise
                error(['Invalid unit measure of ' unitMeasure]);
        end
    otherwise
        error(['Invalid unit dimension of ' unitDimension]);
end


%Old notes to be removed
%metadata.rf.axialScale=1;
%metadata.rf.lateralScale=7.9169*(60/38); % the 60/38 is to account for the difference between the lab ultrasound equipment and NIH's equipment
%This is not in millimeters.  To convert multiply by 0.0385 mm

end