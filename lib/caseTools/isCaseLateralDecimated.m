function isCaseLateralDecimatedFlag=isCaseLateralDecimated(metadata)

p = inputParser;   % Create an instance of the class.
p.addRequired('metadata', @(x) ischar(x) || isstruct(x) || isempty(x));

p.parse(metadata);

metadata=loadCaseData(metadata);


if metadata.decimateFactor==1 || metadata.decimateFactor==2
    isCaseLateralDecimatedFlag=metadata.decimateFactor~=1;
else
    error('Only decimations of 1 or 2 are supported');
end




end