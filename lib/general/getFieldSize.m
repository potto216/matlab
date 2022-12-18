%This fucntion returns the field size for a structure.
function [fieldNameList,fieldSize_bytes]=getFieldSize(x,showOutput)
    fieldNameList=fieldnames(x);
    fieldSize_bytes=zeros(size(fieldNameList));
    for ii=1:length(fieldNameList)
        fullFieldName=['x.' fieldNameList{ii}];
        tmp=x.(fieldNameList{ii});
        xInfo=whos('tmp');
        fieldSize_bytes(ii)=xInfo.bytes;
        if showOutput
            disp([fullFieldName ' = ' num2str(fieldSize_bytes(ii)) ' bytes.']);
        else
            %do nothing
        end
    end
    
end