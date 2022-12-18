function [scale, fps] = readImageBlockMetadata(filename,method)
if ~strcmp(method,'usImageFileMethod1')
    error(['Error: method' method ' not supported.']);
end
f = fopen(filename, 'r');

sz = fread(f, 3, 'uint32=>double');
zData = fread(f, sz(1), 'double');
xData = fread(f, sz(2), 'double');
fclose(f);

if ~all(diff(diff(xData))<1e-11)
    error('the xData spacing is not the same')
end

if ~all(diff(diff(zData))<1e-11)
    error('the zData spacing is not the same')
end

scale.lateral.value=mean(diff(xData));
scale.lateral.units='mm';
scale.axial.value=mean(diff(zData));
scale.axial.units='mm';
fps=1000;
end

