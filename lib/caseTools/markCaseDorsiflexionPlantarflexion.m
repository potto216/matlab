function markCaseDorsiflexionPlantarflexion(fullPathCaseFiles)

%fullPathCaseFiles=loadCaseFilesSet('allValidCaseFiles');


%% The for loop

for ii=1:length(fullPathCaseFiles)
    caseFile=fullPathCaseFiles{ii}; %fullfile(caseFilePath, [caseFiles(ii).name]);
    disp(['************Processing ' caseFile ])
    
    
    [motionTrack.data, motionTrack.fps,motionTrack.t_sec]=getCaseDataIR(caseFile);
    
    %% a new file
    if ~isempty(motionTrack.data) && isempty(getCaseMotionTrackDorsiflexPlantarFlexDB(caseFile,true))
        f1=figure('KeyPressFcn',{@guiMarkMotionTrackDorPlant,caseFile});
        
        plot(motionTrack.t_sec,motionTrack.data,'b');
        hold on
        
        xlabel('time (sec)')
        ylabel('degrees')
                
        title(['Motion capture data for case ' getCaseName(caseFile) ' slopes are in deg/sec'],'interpreter','none')
        uiwait(f1);          
    elseif isempty(motionTrack.data) 
        disp(['Skipping ' getCaseName(caseFile) ' because motion data was not found'])
    elseif ~isempty(getCaseMotionTrackDorsiflexPlantarFlexDB(caseFile,true))
        disp(['Skipping ' getCaseName(caseFile) ' because dorsiflexion and plantarflexion already selected'])
    else
        error('Unknown error');
    end
end