%getCaseMotionTrackDorsiflexPlantarFlexDB returns the MotionTrackDorsiflexPlantarFlexDBFilename
%This function will get the database associated with the case name you give
%it.  The database will be for all files so if you wish to receive all
%files then just request one or pass an empty parameter.  The data is in
%the form of column vectors of point1_start, point1_end, ..., pointk_start, pointk_end 
%where each point is [time_sec; motion_capture_location(deg)];
%
%
%INPUT
%onlyCaseName - is a boolean to only return the case name.
function motionTrackDorsiflexPlantarFlexDB=getCaseMotionTrackDorsiflexPlantarFlexDB(caseData,onlyCaseName)

if isempty(caseData)
    %we can use any case name since we are only interested in returning all
    %of the data
   caseData=fullfile(getenv('ULTRASPECK_ROOT'),'workingFolders\potto\data\caseFiles','ZH2Trial34.m');
else
    %do nothing
end

caseData=loadCaseData(caseData);
if ~isfield(caseData,'motionTrackDorsiflexPlantarFlexDBFilename')
    error('motionTrackDorsiflexPlantarFlexDBFilename needs to exist.');
else
    
    motionTrackDorsiflexPlantarFlexDB=struct('default',[]);
    if ~exist(caseData.motionTrackDorsiflexPlantarFlexDBFilename,'file')
        %do nothing
    else
        load(caseData.motionTrackDorsiflexPlantarFlexDBFilename)
    end
    
    switch(nargin)
        case 1
            %do nothing
        case 2 
            %return only the case name trial
            if onlyCaseName
                if isfield(motionTrackDorsiflexPlantarFlexDB,getCaseName(caseData))
                    motionTrackDorsiflexPlantarFlexDB=motionTrackDorsiflexPlantarFlexDB.(getCaseName(caseData));
                else
                    motionTrackDorsiflexPlantarFlexDB=[];
                end
            end
        otherwise
            error('Invalid number of input arguments')
    end
end