%This function will load the ID information from either the new or old
%filename convention.  The two file formats are:
%OLD FORMAT: <patient><visit #>Trial<trial #>.m ex: WA2Trial32.m
%NEW FORMAT: <patient>_visit<visit #>_trial<trial #>.m ex: WAHV2_visit3_trial32.m
%for the new format the patient name 
%
%OUTPUT
%patientID - Is returned as a character array
%visitID - Is returned as a character array
%trialID - Is returned as a character array

function    [patientID, visitID, trialID]=getIDFromFilenameWA(filename)
    
%detemine 
if strfind(filename,'_')
     parsedFilename=regexp(filename,'(?<patientID>[A-Za-z0-9]+)_(?i)visit(?-i)(?<visitID>\d{1,2})_(?i)trial(?-i)(?<trialID>\d{1,2})','names');
else
     parsedFilename=regexp(filename,'(?<patientID>[A-Za-z]{1,2})(?<visitID>\d{1,2})(?i)Trial(?-i)(?<trialID>\d{1,2})','names');
end

patientID=parsedFilename.patientID;
visitID=parsedFilename.visitID;
trialID=parsedFilename.trialID;

end