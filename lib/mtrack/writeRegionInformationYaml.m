function writeRegionInformationYaml(imBlock, fullFilepath, name, regions)

switch(nargin)
    case 3
        regions=[];
    case 4
        %do nothing
    otherwise
        error('Invalid number of input arguments.');
end


sequence=(1:size(imBlock,3));

fid=fopen(fullfile(fullFilepath,name, ['RegionInformation'  '.yaml']),'w');

if ~all(diff(diff(sequence))==0) || ((sequence(2)-sequence(1))~=1)
    error('Assumed the sequence increment would always be 1');
end

fprintf(fid,'Region:\n');
fprintf(fid,'- name: all\n');
fprintf(fid,'  sequence:\n');
fprintf(fid,'    start: %d\n',sequence(1));
fprintf(fid,'    end: %d\n',sequence(end));
fprintf(fid,'  units: pel\n');
fprintf(fid,'  #this is in the form of 2D (x,y) column vectors [[x coordinates], [y coordinates]]\n');
fprintf(fid,'  #The dimensions are [x (lateral), y (axial)]\n');
fprintf(fid,'  polygon:\n');
fprintf(fid,'    ptSerial:\n');
fprintf(fid,'      order: columnMajor\n');
fprintf(fid,'      dim: [2, -1]\n');
fprintf(fid,'      data: [1, 1, %d, 1, %d, %d, 1, %d]\n',size(imBlock,2),size(imBlock,2),size(imBlock,1),size(imBlock,1));


for ii=1:length(regions)
    polygonString=strtrim(num2str(fix(reshape(regions(ii).polygon_xy(:),1,[])),'%i, '));
    if polygonString(end)~=','
        error('Expected a comma');
    end
    
    polygonString=polygonString(1:(end-1)); %remove comma and string
    
    fprintf(fid,'- name: %s\n',regions(ii).name);
    fprintf(fid,'  sequence:\n');
    fprintf(fid,'    start: %d\n',sequence(1));
    fprintf(fid,'    end: %d\n',sequence(end));
    fprintf(fid,'  units: pel\n');
    fprintf(fid,'  #this is in the form of 2D (x,y) column vectors [[x coordinates], [y coordinates]]\n');
    fprintf(fid,'  #The dimensions are [x (lateral), y (axial)]\n');
    fprintf(fid,'  polygon:\n');
    fprintf(fid,'    ptSerial:\n');
    fprintf(fid,'      order: columnMajor\n');
    fprintf(fid,'      dim: [2, -1]\n');
    fprintf(fid,'      data: [%s]\n',polygonString);    
end
fclose(fid);
end

