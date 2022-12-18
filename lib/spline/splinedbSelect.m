%splinedbSelect Shows the splines in a database matched against a criteria
%
%This function will list the splines in a database when matched against a
%criteria.  If no criteria is given it will show all of the splines for
%that case.
%
%splinedbSelect(metadata)
%
%metadata - This is a valid metadata structure that has been loaded and
%it will specify the names and locations of the database. This can also be a
%chracter string of the full path name of the file that has the metadata.
%
%OUTPUT
%splineData - returns the spline data that matched the criteria
%
%SEE ALSO: splinedbView, splinedbUpdate, splinedbDelete, splinedbInsert
function splineData=splinedbSelect(metadata)
switch(nargin)
    case 0
        metadata=[]; %let the user select
    case 1
        %do nothing

    otherwise
        error('Invalid number of input arguments.')
end


[metadata]=loadCaseData(metadata);


if ~isfield(metadata,'splineFilename')
    error('The field splineFilename must be given in the metadata data structure.');
end


if exist(metadata.splineFilename,'file')
    load(metadata.splineFilename,'splineData')
    
else
    disp([metadata.splineFilename ' does not exist.'])
    splineData=[];
end

disp('Index> Name  |  Tag')
disp('--------------------------------------')
for ii=1:length(splineData)
    disp([ num2str(ii) '> '  splineData(ii).name '  |  ' splineData(ii).tag])
end

end