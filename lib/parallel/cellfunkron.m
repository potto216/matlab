%b and c must be vectors
function A=cellfunkron(fun,b,c)

if ~isvector(b) || ~isvector(c)
    error('b and c must be vectors');
end

A=cellfun(fun,repmat(reshape(b,[],1),1,length(c)),repmat(reshape(c,1,[]),length(b),1),'UniformOutput', false);
end
