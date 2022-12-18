%Searches for a unique node.  Will return the node or empty if the node was
%not found.
function node=tFindNode(trialData,nodeName)
idx=find(arrayfun(@(x) strcmp(x.name,nodeName),trialData.track.node));
if isempty(idx)
    node=[];    
elseif length(idx)~=1
    error(['More than one node of the same name: ' nodeName ' was found.']);
else
    node=trialData.track.node(idx);
end

end