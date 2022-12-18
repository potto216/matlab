%This treats the Motion Path as a table and the files as rows.  The
%function will display the rows sorted by time stamp.  The filenames
%are in the following format: <name tag>_<time stamp>.mat
%
%caseData - can be the full path and name of the case file or it can be a
%data structure that has already been loaded in memory.
%
%rowNameCriteria - The criteria used to select valid rows.  This string is
%a valid filename expression (using ?,*, etc) for the <name tag>
%
%Note: right now the function assumes there is only one valid name tag
%called Speckle1DTrack.
function selectMotionPath(caseData,rowNameCriteria)

caseData=loadCaseData(caseData);

%pull in all the files
fileList=dir(fullfile(getCasePathField(caseData,'motionPath'),[rowNameCriteria '_*.mat']));

validNameTag='Speckle1DTrack';

if ~isempty(fileList)
    timeStampStr=regexp({fileList.name},[validNameTag '_(?<stamp>\d{14})\.mat'],'tokens');
    timeStampNum=cellfun(@(x) str2num(x{1}{1}),timeStampStr,'UniformOutput',true);    
    [timeStampNumSortVal,timeStampNumSortIdx]=sort(reshape(timeStampNum,[],1),1,'descend');
    
    disp(['-----------Motion Path (' validNameTag ')----------------------']);
    for ii=1:length(timeStampNumSortIdx)
        idx=timeStampNumSortIdx(ii);
        disp(timeStampStr{idx}{1}{1})
    end
    
      
end

end






