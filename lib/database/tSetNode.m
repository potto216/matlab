%Sets new node data for a unique node.  The node must exist or it will be
%assigned an empty value.
function trialData=tSetNode(trialData,nodeName,newNode)
idx=find(arrayfun(@(x) strcmp(x.name,nodeName),trialData.track.node));
if isempty(idx)
    error(['Could not find the node ' nodeName]);
elseif length(idx)~=1
    error(['More than one node of the same name: ' nodeName ' was found.']);
else
    trialData.track.node(idx)=newNode;
end

end