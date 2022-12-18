%This function uses an activeProcessStreamIdentifier to search for the
%active stream index and return it.
%
%activeProcessStreamIdentifier - can be an index which will be just passed
%through, or the name of the process stream which will be mapped to the
%correct index and then returned.
function activeProcessStreamIndex=tFindProcessStreamIndex(trialData,activeProcessStreamIdentifier)
if iscell(activeProcessStreamIdentifier)
    activeProcessStreamIdentifier=activeProcessStreamIdentifier{1};
    if ischar(activeProcessStreamIdentifier)
        psIndex=find(arrayfun(@(ps) strcmp(ps.name,activeProcessStreamIdentifier), trialData.track.processStream));
        if isempty(psIndex)
            error(['Unable to find the process stream ' activeProcessStreamIdentifier]);
        else
            if length(psIndex)==1
                activeProcessStreamIndex=psIndex;
            else
                error(['Matched to the indexes ' num2str(psIndex)]);
            end
            
        end
        
    elseif isnumeric(activeProcessStreamIdentifier)
        activeProcessStreamIndex=activeProcessStreamIdentifier;
    else
        error(['Unsupported type of ' class(activeProcessStreamIdentifier)]);
    end
elseif isnumeric(activeProcessStreamIdentifier)
    activeProcessStreamIndex=activeProcessStreamIdentifier;
elseif ischar(activeProcessStreamIdentifier)
    psIndex=find(arrayfun(@(ps) strcmp(ps.name,activeProcessStreamIdentifier), trialData.track.processStream));
    if isempty(psIndex)
        error(['Unable to find the process stream ' activeProcessStreamIdentifier]);
    else
        if length(psIndex)==1
            activeProcessStreamIndex=psIndex;
        else
            error(['Matched to the indexes ' num2str(psIndex) ' when looking for the process stream ' activeProcessStreamIdentifier '. Should have only matched to one index. Check that there are not duplicate processtream names in the file that specifies the metadata.track.processStream such as libmtrack_processstream.m' ]);
        end
        
    end
    
else
    error('Unsupportedmethod of identifiying the process stream.');
end
end