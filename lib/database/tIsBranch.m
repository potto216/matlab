%More useful than isfield because will transverse the node 
%and return if the entire path is defined
%Example: to check if "trialData.subject.phantom.reference.rfFilename" exists and
%you know trialData.subject.phantom exists use:
%tIsBranch(trialData.subject.phantom,'reference.rfFilename')
function [isBranch]=tIsBranch(dataStruct,branch)

[fieldToCheck,remainingBranch]=strtok(branch,'.');

if isfield(dataStruct,fieldToCheck)
    
    if isempty(remainingBranch)
        isBranch=true;
    else
        isBranch=checkBranch(dataStruct.(fieldToCheck),remainingBranch(2:end));        
    end 
else
    isBranch=false;   
end
end

%we assume all error checking has been done so this function can be
%streamlined
function isBranch=checkBranch(dataStruct,branch)

[fieldToCheck,remainingBranch]=strtok(branch,'.');


if isfield(dataStruct,fieldToCheck)
    
    if isempty(remainingBranch)
        isBranch=true;
    else
        isBranch=checkBranch(dataStruct.(fieldToCheck),remainingBranch(2:end));        
    end 
else
    isBranch=false;   
end

end