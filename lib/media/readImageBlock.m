function [Images, xData, zData] = readImageBlock(filename,method)
% f = fopen(filename, 'r');
% 
% sz = fread(f, 3, 'uint32=>double');
% zData = fread(f, sz(1), 'double');
% xData = fread(f, sz(2), 'double');
% Images = zeros(sz');
% for fr = 1:sz(3),
%     Images(:,:,fr) = fread(f, sz(1:2)', 'double');
% end
% 
% fclose(f);

if strcmp(method,'usImageFileMethod1')
  f = fopen(filename, 'r');
  
  sz = fread(f, 3, 'uint32=>double');
  zData = fread(f, sz(1), 'double');
  xData = fread(f, sz(2), 'double');
  Images = zeros(sz');
  
  if((getfield(dir(filename),'bytes')-28)/prod(sz) - 4 < 1) type = 'single=>double';
  else type = 'double'; end
  for fr = 1:sz(3),
    Images(:,:,fr) = fread(f, sz(1:2)', type);
  end
  
  fclose(f);

elseif strcmp(method,'usImageFileMethod2')
  tt=load(filename);
  Images=tt.Images_lc;
else
        error(['Error: method' method ' not supported.']);
end


end

