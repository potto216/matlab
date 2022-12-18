function parforSaveData_phantomSimulateTendonMotion( matFilepath,phantomObjectFilename,objFieldII,imBlock,objPhantom)
%PARFORSAVEDATA This function saves data sicne you can't in a parfor loop

matFullFilepath=fullfile(matFilepath.root, matFilepath.relative,matFilepath.trialFolder);



save(fullfile(matFullFilepath,phantomObjectFilename),'objPhantom','objFieldII','matFilepath');
save(fullfile(matFullFilepath,['phantom_' matFilepath.trialFolder  '_image']),'imBlock','matFilepath');

end

