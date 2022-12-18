%This function copies fields of a structure out for the fields fieldList.
%If srcStruct is empty it will make an empty struct
%If structSearchArray is empty and empty will be returned
function foundIndexList=structArrayFind(fieldList,structSearchArray,structToFind)

%fieldsAreAllEqual = @(pStruct,sStruct) all(cellfun(@(fieldname) pStruct.(fieldname)==sStruct.(fieldname),fieldList,'UniformOutput',true));
%foundIndexList=find(arrayfun(@(searchStruct) fieldsAreAllEqual(searchStruct,structToFind),structSearchArray));

if isempty(structSearchArray)
    foundIndexList=[];
else
    
    %modify to work with function call
    foundIndexList=find(arrayfun(@(searchStruct) fieldsAreAllEqual(searchStruct,structToFind,fieldList),structSearchArray));
end


end

function isAllEqual=fieldsAreAllEqual(pStruct,sStruct,fieldList)

isAllEqual=true;
for ff=1:length(fieldList)
    if pStruct.(fieldList{ff})~=sStruct.(fieldList{ff})
        isAllEqual=false;
        break;
    end
end
end