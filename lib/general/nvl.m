%This function will return a value in place of a null
function expOut=nvl(exp1,replaceNullWith)

if isempty(exp1)
    expOut=replaceNullWith;
else
    expOut=exp1;
end