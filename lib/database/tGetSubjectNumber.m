%This function will return the subject number either as a number or a
%string including the visit number for a trialData structure.
%
%INPUT
%returnStringWithVisitNumber - do we include visit information when extracting
%the subject id.  This will always be a string.  If false then it will the
%number.  Default is false.
%
%OUTPUT
%subjectId - will be the subject number if returnStringWithVisitNumber is
%false, otherwise it will return a number.
function [subjectId]=tGetSubjectNumber(trialData,returnStringWithVisitNumber)
switch(nargin)
    case 1
        returnStringWithVisitNumber=false;
    otherwise
        %do nothing
end
if ~returnStringWithVisitNumber
    %% Extract the correct MRI information for the subject
    if strcmpi('MRUS',trialData.subject.name(1:4))
        subjectId=str2double(trialData.subject.name(5:7));
    elseif strcmpi('rectusFemoris_phantom',trialData.subject.name(1:length('rectusFemoris_phantom')))
        subjectId=str2double(trialData.subject.phantom.parameter.motionModel(5:7));
    else
        warning('fail.  Expected MRUS subject name prefix');
        subjectId=1;
    end
    
else
    
    %% Extract the correct MRI information for the subject
    if strcmpi('MRUS',trialData.subject.name(1:4))        
        subjectId=regexp(trialData.subject.name,'MRUS\d+_V\d+','match');  %this will return the matching string
        
        if isempty(subjectId)
            error('Unable to decode MRUS');
        end
    elseif strcmpi('rectusFemoris_phantom',trialData.subject.name(1:length('rectusFemoris_phantom')))
        subjectId=regexp(trialData.subject.phantom.parameter.motionModel,'MRUS\d+_V\d+','match');  %this will return the matching string
         if isempty(subjectId)
            error('Unable to decode MRUS');
        end
    else
        warning('fail.  Expected MRUS subject name prefix');
        subjectId='';
    end
end
end