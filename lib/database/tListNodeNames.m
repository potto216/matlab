%This function will list all of the nodenames for all of the process streams
function nodeNameList=tListNodeNames(trialData)
nodeNameList=arrayfun(@(x) x.name,trialData.track.node,'UniformOutput',false); 
switch(nargout)
    case 0
        disp('---Node Names---')
        for ii=1:length(nodeNameList)
            disp(nodeNameList{ii})
        end
    case 1
        %do nothing
    otherwise
        error('Invalid number of output arguments.');
end
        
end