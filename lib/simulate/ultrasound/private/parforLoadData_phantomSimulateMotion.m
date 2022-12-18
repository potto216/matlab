function [objPhantom,objFieldII,matFilepath, fieldii,image]=parforLoadData_phantomSimulateRectusFemorisMotion( phantomFilename)
%PARFORSAVEDATA This function saves data sicne you can't in a parfor loop

load(phantomFilename,'objPhantom','objFieldII');
% image=load(fullfile(phantom.matFullFilepath,['phantom_' phantom.matFilepath.trialFolder  '_image']),'imBlock','matFilepath');
% fieldii=load('E:\Users\potto\ultraspeck\workingFolders\potto\data\phantom\phantom_18-50-32_fieldII.mat');
% warning('must fix rf load');

% if strcmp(objPhantom.phantomArguments{5},'DataBlockObj')
%     objPhantom.phantomArguments{6}=objPhantom.phantomArguments{6}.save([]);
%     warning('Please check the DataBlockObj in objPhantom is saved correctly');
% end

end

