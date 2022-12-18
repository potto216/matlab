function parforSaveData_phantomProjection( matFullFilepath,phantomObjectFilename,objFieldII,objPhantom,trialData)
%PARFORSAVEDATA This function saves data sicne you can't in a parfor loop

%if objPhantom.phantomArguments{6}.getUnitsValue( 'axialSampleRate','samplePerSec')
[ keyIdx ] = findKeyInPairList( objPhantom.phantomArguments,'DataBlockObj' );
if length(keyIdx)==1 
    if ~isempty(objPhantom.phantomArguments{keyIdx+1})
        objPhantom.phantomArguments{keyIdx+1}=objPhantom.phantomArguments{keyIdx+1}.save([]);
    else
        %if the structure is empty then ignore it, the information should
        %be given in the trialdata
    end
elseif length(keyIdx)==0
    %do nothing
else
    error('Too many finds for keyIdx, it should only be one');
end

save(fullfile(matFullFilepath,phantomObjectFilename),'objPhantom','objFieldII','trialData');
end

