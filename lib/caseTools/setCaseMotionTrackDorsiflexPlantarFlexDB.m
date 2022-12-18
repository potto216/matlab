%getCaseMotionTrackDorsiflexPlantarFlexDB returns the MotionTrackDorsiflexPlantarFlexDBFilename
function setCaseMotionTrackDorsiflexPlantarFlexDB(caseData,motionTrackDorsiflexPlantarFlexDB) %#ok<INUSD>
caseData=loadCaseData(caseData);
if ~isfield(caseData,'motionTrackDorsiflexPlantarFlexDBFilename')
    error('motionTrackDorsiflexPlantarFlexDBFilename needs to exist.');
else
    
    save(caseData.motionTrackDorsiflexPlantarFlexDBFilename,'motionTrackDorsiflexPlantarFlexDB');
    
end