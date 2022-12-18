function parforSaveData_phantomProjection( matFullFilepath,phantomProjectionFilename,imBlock,trialData)

save(fullfile(matFullFilepath,phantomProjectionFilename),'imBlock','matFullFilepath','trialData');

end

