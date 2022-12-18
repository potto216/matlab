%This function maps a set of string tokens to another value
%{token,value} token=>value
%All values are processed sequentially so make sure the empty is last
function [valueList]=ltokenmap(list,map)
valueList=nan(size(list));

for ii=1:length(map)
    if ~isempty(map{ii}{1})
        isValue=cellfun(@(x) ~isempty(x),regexp(list,map{ii}{1}));
        valueList(isValue)=map{ii}{2};
    else
        valueList(isnan(valueList))=map{ii}{2};
    end

end