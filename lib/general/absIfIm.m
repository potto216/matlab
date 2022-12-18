
function [image]=absIfIm(image)
if ~isreal(image)
    image=abs(image);
else
    %do nothing
end
end