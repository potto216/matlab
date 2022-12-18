function [rowFoundList,locationInRowList]=strregexp(parseStr, matchExpr)

locationFoundReg=regexp(parseStr, matchExpr);
isValid=cellfun(@(x) ~isempty(x),locationFoundReg);
rowFoundList=find(isValid);
locationInRowList=cell2mat(locationFoundReg);
end