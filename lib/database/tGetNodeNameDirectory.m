function [dataDirectory, dataFiles]=tGetNodeNameDirectory(trialData,nodeName,processStreamIndex)

switch(nargin)
    case 2
        processStreamIndex=1;
    case 3
        %do nothing
    otherwise
        error('Invalid number of input arguments');
end
        


filepath=trialData.track.processStream(processStreamIndex).filepath;

directoryName=fullfile(filepath.pathToRoot,filepath.root,filepath.relative,filepath.relativeBranch);

if ~exist(directoryName,'dir')
    error(['Unable to find the directory ' directoryName]);
end

nodeDirectoryList=flattenCell(dirPlus(directoryName,'recursive',true,'dirOnly',true,'relativePath',false));

dataDirectory=nodeDirectoryList(cellfun(@(x) ~isempty(x), regexp(nodeDirectoryList,[nodeName '(\\|)$'])));

if length(dataDirectory)~=1
    error('Can only be one data directory')
else
    dataDirectory=dataDirectory{1};
end



dataFiles=dirPlus(fullfile(dataDirectory,'*.mat'),'recursive',false,'fileOnly',true,'relativePath',false);

end
