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
    '_V(?<visit>\d)_S(?<site>\d)_T(?<trial>\d)_[\d-]{8,8}_(?<mode>(rf|b8))\.mat'],'names');

%Keep only the valid files
badMatches=cellfun(@(x) isempty(x),validMatches);
resultFilenameList(badMatches)=[];
validMatches(badMatches)=[];
validMatches=cell2mat(validMatches);

%
for ii=1:length(validMatches)
    validMatches(ii).filename=resultFilenameList{ii};
    validMatches(ii).patientNumber=str2num(validMatches(ii).patientNumber);
end

patientNumberList=sort(unique([validMatches.patientNumber]));
modeList=unique({validMatches.mode});

findFileList=@(patientNumber,mode) validMatches(arrayfun(@(x) x.patientNumber==patientNumber && strcmp(x.mode,mode) ,validMatches));

for pp=1:length(patientNumberList)
    for mm=1:length(modeList)
        
        fileListStruct=findFileList(patientNumberList(pp),modeList{mm});
        fileListToProcess={fileListStruct.filename};
        flexionVelocityList=[];
        extensionVelocityList=[];
        for dd=1:length(fileListToProcess)
            fileToLoad=[fileListToProcess{dd} ];
            disp(['Loading ' fileToLoad]);
            data=load(fileToLoad);
            forwardTrackPositionMarked_sec_mm=data.results.ultrasound.forwardTrackPositionMarked_sec_mm;
            backwardTrackPositionMarked_sec_mm=data.results.ultrasound.backwardTrackPositionMarked_sec_mm;
            
            %The analysis section are measurements that have been taken from the actual data.
            
            switch(modeList{mm})
                case 'rf'
                    sourceType='ultrasound.rf';
                case 'b8'
                    sourceType='ultrasound.bmode';
                otherwise
                    error(['Unsupported mode of ' modeList(mm)]);
            end
            disp('--------------------------------------------------');
            disp(fileListStruct(dd))
            
            disp(['idx=1;']);
            disp(['metadata.analysis.track.cyclePeaks(idx).time_sec=[' num2str(forwardTrackPositionMarked_sec_mm(1,:),'%f ') '];']);
            disp(['metadata.analysis.track.cyclePeaks(end).displacement_mm=[' num2str(forwardTrackPositionMarked_sec_mm(2,:),'%f ') '];']);
            disp(['metadata.analysis.track.cyclePeaks(end).source=''' sourceType ''';']);
            disp(['metadata.analysis.track.cyclePeaks(end).name=''forwardTrackPositionMarked_sec_mm'';']);
            disp(['metadata.analysis.track.cyclePeaks(end).description=''Forward track of smoothed muscle displacement peaks'';']);
            
            
            disp(['idx=1;']);
            disp(['metadata.analysis.track.cyclePeaks(end+1).time_sec=[' num2str(backwardTrackPositionMarked_sec_mm(1,:),'%f ') '];']);
            disp(['metadata.analysis.track.cyclePeaks(end).displacement_mm=[' num2str(backwardTrackPositionMarked_sec_mm(2,:),'%f ') '];']);
            disp(['metadata.analysis.track.cyclePeaks(end).source=''' sourceType ''';']);
            disp(['metadata.analysis.track.cyclePeaks(end).name=''backwardTrackPositionMarked_sec_mm'';']);
            disp(['metadata.analysis.track.cyclePeaks(end).description=''Backward track of smoothed muscle displacement peaks'';']);
            
        end
        
    end
end




