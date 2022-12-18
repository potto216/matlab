%This function imitates the sed command and allows you to generate a new
%file that is a modified version of the orignal
function sed(originalFilename, modifiedFilename,patternMap)
originalFid=fopen(originalFilename,'r');
modifedFid=fopen(modifiedFilename,'w');

if originalFid<0
    error(['Unable to open ' originalFilename]);
end

if modifedFid<0
    error(['Unable to open ' modifiedFilename]);
end
if ~isvector(patternMap)
    error('patternMap must be a vector in the form {{pattern1,replace1},...,{patternN,replaceN}}');
end

while ~feof(originalFid)
    originalStr=fgets(originalFid);
    modifiedStr=originalStr;
    for ii=1:length(patternMap)
        %Make sure the values are properly escaped otherwise they coulld
        %cause issues with regexprep because for the replace argument it
        %does not have an interpret as literal arguement.
        argExpression = regexptranslate('escape', patternMap{ii}{1});
        argReplace = regexptranslate('escape', patternMap{ii}{2});
        modifiedStr = regexprep(modifiedStr,argExpression,argReplace);
    end
    fprintf(modifedFid,'%s',modifiedStr);
end

fclose(originalFid);
fclose(modifedFid);



end