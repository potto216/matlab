%This function copies fields of a structure out for the fields fieldList.
%If srcStruct is empty it will make an empty struct
function dstStruct=structCopyFields(fieldList,dstStruct,srcStruct)

if isempty(srcStruct)
    
    initValue=repmat({[]},1,length(fieldList));
    newFields={fieldList{:}; initValue{:}};
    dstStruct=struct(newFields{:});
else
    
    for ff=1:length(fieldList)
        dstStruct.(fieldList{ff})=srcStruct.(fieldList{ff});
    end
end

end