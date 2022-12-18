%getCaseActiveSpline returns the active spline index for a particular case.
% If the value is empty then it loads the first one.
% If no spline file is available then activeSpline is
% returned as an empty
function activeSpline=getCaseActiveSpline(caseData)

caseData=loadCaseData(caseData);

if isempty(caseData.activeSpline)
    if exist(caseData.splineFilename,'file')
        ld=load(caseData.splineFilename,'splineData');  
        activeSpline=1; %length(ld.splineData);     
    else
        warning([caseData.splineFilename ' does not exist.'])
        activeSpline=[];
    end
else
activeSpline=caseData.activeSpline;    
end



end