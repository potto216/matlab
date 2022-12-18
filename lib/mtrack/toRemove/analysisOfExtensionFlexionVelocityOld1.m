fileListBMode={{'MRUS004_V1_S1_T1_09-59-11_b8','MRUS004_V1_S1_T2_10-00-45_b8'}, ...
    {'MRUS005_V1_S1_T1_11-48-19_b8','MRUS005_V1_S1_T2_11-50-03_b8'}, ...
    {'MRUS006_V1_S1_T1_13-12-02_b8'}};


fileListRf={{'MRUS004_V1_S1_T1_09-59-11_rf','MRUS004_V1_S1_T2_10-00-45_rf'},...
    {'MRUS005_V1_S1_T1_11-48-19_rf','MRUS005_V1_S1_T2_11-50-03_rf'},...
    {'MRUS006_V1_S1_T1_13-12-02_rf'}};

subject=struct('meanAverageFelexionVelocity',[],'stdAverageFlexionVelocity',[],'meanAverageExtensionVelocity',[],'stdAverageExtensionVelocity',[]);


%We want tables for each patient, mode(rf/bmode), method
outputPath='E:\Users\potto\data\IUS2014Results\velocityBound';
resultFilenameList=dirPlus(fullfile(outputPath,'*.mat'));

[validMatches] = regexp(resultFilenameList,[strrep([outputPath filesep],'\','\\') 'MRUS(?<patientNumber>\d{3,3})' ...
    '_V\d_S\d_T\d_[\d-]{8,8}_(?<mode>(rf|b8))_(?<functionName>(all|fpt_[a-zA-Z0-9_]+))\.mat'],'names');

badMatches=cellfun(@(x) isempty(x),validMatches);
resultFilenameList(badMatches)=[];
validMatches(badMatches)=[];
validMatches=cell2mat(validMatches);

for ii=1:length(validMatches)
    validMatches(ii).filename=resultFilenameList{ii};
    validMatches(ii).patientNumber=str2num(validMatches(ii).patientNumber);
end

patientNumberList=sort(unique([validMatches.patientNumber]));
modeList=unique({validMatches.mode});
functionNameList=sort(unique({validMatches.functionName}));


dataTable=zeros(length(functionNameList), 4, length(patientNumberList),length(modeList));



findFileList=@(patientNumber,mode,functionName) validMatches(arrayfun(@(x) x.patientNumber==patientNumber && strcmp(x.mode,mode) && strcmp(x.functionName,functionName) ,validMatches));

for pp=1:length(patientNumberList)
    for mm=1:length(modeList)
        for ff=1:length(functionNameList)
            fileListStruct=findFileList(patientNumberList(pp),modeList{mm},functionNameList{ff});
            fileListToProcess={fileListStruct.filename};
            flexionVelocityList=[];
            extensionVelocityList=[];
            for dd=1:length(fileListToProcess)
                fileToLoad=[fileListToProcess{dd} ];
                disp(['Loading ' fileToLoad]);
                data=load(fileToLoad);
                flexionVelocityList=[flexionVelocityList data.flexionVelocity_mmPerSec];
                extensionVelocityList=[extensionVelocityList data.extensionVelocity_mmPerSec];
            end
%             dataTable(ff,1,pp,mm).meanAverageFelexionVelocity=mean(flexionVelocityList);
%             dataTable(ff,1,pp,mm).stdAverageFlexionVelocity=std(flexionVelocityList);
%             dataTable(ff,1,pp,mm).meanAverageExtensionVelocity=mean(extensionVelocityList);
%             dataTable(ff,1,pp,mm).stdAverageExtensionVelocity=std(extensionVelocityList);
            dataTable(ff,1,pp,mm)=mean(flexionVelocityList);
            dataTable(ff,2,pp,mm)=std(flexionVelocityList);
            dataTable(ff,3,pp,mm)=mean(extensionVelocityList);
            dataTable(ff,4,pp,mm)=std(extensionVelocityList);
            
        end
    end
end


%% Write out the tables 

for pp=1:length(patientNumberList)
    for mm=1:length(modeList)
        outputTable={'Function','Mean Flexion Velocity','STD Flexion Velocity','Mean Extension Velocity','STD Extension Velocity'};
        outputTable(2:(length(functionNameList)+1),1)=functionNameList';
        outputTable(2:(length(functionNameList)+1),2:5)=num2cell(dataTable(:,:,pp,mm));
        sheetName=['Patient ' num2str(patientNumberList(pp)) ' ' modeList{mm}];
        xlswrite(fullfile(outputPath,'flexionExtensionResults.xls'),outputTable,sheetName);
        disp(['Wrote out sheet '  sheetName])
    end
end
        
