%Loads a text file as a series of lines or elements in a cell array
function lines=loadtext(filename)
fid = fopen(filename);
if fid == -1
    error(['Unable to open the file ' filename]);
end
lines={};
lines{end+1} = fgetl(fid);
while ischar(lines{end})
    lines{end+1} = fgetl(fid);
end
lines(end)=[];
fclose(fid);