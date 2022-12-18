%splinedbDelete Removes a spline in a database
%
%This function will remove a spline in a database when given an index
%
%splinedbSelect(metadata, idx)
%
%metadata - This is a valid metadata structure that has been loaded and
%it will specify the names and locations of the database.  This can also be a
%chracter string of the full path name of the file that has the metadata.
%
%idx - The index of the spline to remove
%SEE ALSO: splinedbView, splinedbUpdate, splinedbDelete, splinedbInsert
function splinedbDelete(metadata,idx)
switch(nargin)
    case 2
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
    return;
end

if idx<1 || idx>length(splineData) %#ok<NODEF>
    disp(['The index ' num2str(idx) ' was not valid.'])
end

disp([ 'Deleted ' num2str(idx) '> '  splineData(idx).name '  |  ' splineData(idx).tag])

splineData(idx)=[]; %#ok<NASGU>

save(metadata.splineFilename,'splineData')

end