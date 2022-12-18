% imRowColumnUnits_m - This is the dimensions of a pixel
function writeImageSequenceYaml(trialData, image, imBlock, imRowColumnUnits_m, fullFilepath,name, filenameMask,fmt,filenameMaskPython)
sequence=(1:size(imBlock,3));
fullImageFilepath=fullfile(fullFilepath, name);
if ~exist(fullImageFilepath,'dir')
    mkdir(fullImageFilepath)
end
imwriteblk(imBlock,fullImageFilepath,filenameMask,fmt);
fid=fopen(fullfile(fullFilepath, [name '.yaml']),'w');
fprintf(fid,'source:\n');
fprintf(fid,'  #type can be dir or file\n');
fprintf(fid,'  type: "dir"\n');
fprintf(fid,'  name: %s\n',name);
fprintf(fid,'  sequence:\n');
fprintf(fid,'    start: %d\n',sequence(1));
fprintf(fid,'    end: %d\n',sequence(end));

if ~all(diff(diff(sequence))==0) || ((sequence(2)-sequence(1))~=1)
    error('Assumed the sequence increment would always be 1');
end

fprintf(fid,'    increment: %d\n',(sequence(2)-sequence(1)));
fprintf(fid,'    mask: "%s"\n',filenameMaskPython); %include the file extension: {:04d}.png
fprintf(fid,'\n');
fprintf(fid,'\n');

if ~isempty(imRowColumnUnits_m)
    fprintf(fid,'pixelParameters:\n');
    fprintf(fid,'  scale:\n');
    fprintf(fid,'    lateral:\n');
    fprintf(fid,'      value: %0.9f\n',imRowColumnUnits_m(2)*1000);
    fprintf(fid,'      units: "mm"\n');
    fprintf(fid,'    axial:\n');
    fprintf(fid,'      value: %0.9f\n',imRowColumnUnits_m(1)*1000);
    fprintf(fid,'      units: "mm"\n');
    fprintf(fid,'\n');
    
else
    fprintf(fid,'pixelParameters:\n');
    fprintf(fid,'  scale:\n');
    fprintf(fid,'    lateral:\n');
    fprintf(fid,'      value: %0.9f\n',trialData.collection.projection.bmode.scale.lateral.value);
    fprintf(fid,'      units: "%s"\n',trialData.collection.projection.bmode.scale.lateral.units);
    fprintf(fid,'    axial:\n');
    fprintf(fid,'      value: %0.9f\n',trialData.collection.projection.bmode.scale.axial.value);
    fprintf(fid,'      units: "%s"\n',trialData.collection.projection.bmode.scale.axial.units);
    fprintf(fid,'\n');
end
fprintf(fid,'image:\n');
fprintf(fid,'  # This relates the ultrasound image axis to the phantom axis, such as the phantoms x axis is the ultrasound image lateral axis for the column\n');
fprintf(fid,'  # The default row relationship is ultrasound axial to phantom z\n');
fprintf(fid,'  row:\n');
fprintf(fid,'    ultrasound:"%s"\n',image.axis.row.ultrasound);
fprintf(fid,'    phantom:"%s"\n',image.axis.row.phantom);
fprintf(fid,'  column:\n');
fprintf(fid,'    ultrasound:"%s"\n',image.axis.column.ultrasound);
fprintf(fid,'    phantom:"%s"\n',image.axis.column.phantom);
fprintf(fid,'\n');

fprintf(fid,'ultrasoundParameters:\n');
fprintf(fid,'  transmitFrequency_Hz: %f\n',trialData.collection.ultrasound.rf.header.txf);
fprintf(fid,'  # 0 means it is not saved, such as for b-mode\n');
fprintf(fid,'  samplingFrequency_Hz: %d\n',trialData.collection.ultrasound.rf.header.sf);
fprintf(fid,'  frameRate_fps: %d\n',trialData.collection.ultrasound.rf.header.dr);
fprintf(fid,'  probeInfo:\n');
fprintf(fid,'  # type of -1 means it is not defined\n');
fprintf(fid,'    type: -1\n');
fprintf(fid,'    name: "%s"\n',trialData.collection.ultrasound.rf.header.probeInfo.name);
fprintf(fid,'    elementPitch_mm: %f\n',trialData.collection.ultrasound.rf.header.probeInfo.elementPitch_mm);
fprintf(fid,'    elementCount: %d\n',trialData.collection.ultrasound.rf.header.probeInfo.elementCount);
fprintf(fid,'  # Possibly add in the future\n');
fprintf(fid,'  # prp in Doppler modes\n');
fprintf(fid,'  # line density (can be used to calculate element spacing if pitch and native # elements is known)');

fclose(fid);
end

