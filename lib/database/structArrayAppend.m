%By default this will copy the source structure to the destination array of
%structures.  By default it will copy all source structure fields to the
%end of the destination array.
function dstArray=structArrayAppend(dstArray,srcStruct)

%make sure there is something to do
if isempty(srcStruct)
    return
end

if numel(srcStruct)~=1
    error('srcStruct cannot be an array of structures');
end

%first check if dstArray is empty.  If so set it equal to the src structure
if isempty(dstArray)
    dstArray=srcStruct;
    return;
else
    %otherwise append the src to the end by copying out all the fields
    nameList = fieldnames(srcStruct);
    newIdx=numel(dstArray)+1;
    for name = reshape(nameList,1,[])
        name=name{1};
        %I don't know of a way other than this to dynamically add a field
        %to an array of struct.  This method will not work well as the
        %array size grows.
        if ~isfield(dstArray,name)
            dstArray = arrayfun(@(x) setfield(x, name, []), dstArray);
        end
        dstArray(newIdx).(name)=srcStruct.(name);
    end
end

end
