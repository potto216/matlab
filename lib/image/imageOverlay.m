%Need to resolve if the range of the plot is 0,max size so there is an extra point to handle
%the border conditions
function imageOverlay( im,imMask,scaleFactor_cr )
switch(nargin)
    case 2
        scaleFactor_cr=[1 1];
    case 3
    otherwise
        error('Invalid number of input arguments.');
end
%convert everything to uint8
switch(class(im))
    case 'double'
      %  im=abs(im).^0.4;
        im = im-min(im(:));
        im = uint8((im/max(im(:)))*255);        
    case 'uint8'        
        %do nothing
    otherwise
        error(['Unsupported class of ' class(im)]);
end
pixelIdxList=find(imMask);

im(pixelIdxList)=uint8(double(im(pixelIdxList)*2));
im=repmat(im,[1 1 3]);
im(pixelIdxList+size(im,1)*size(im,2)*2)=0;



figure; image([0:(size(im,2)-1)]*scaleFactor_cr(1),[0:(size(im,1)-1)]*scaleFactor_cr(2),im);
xlabel('mm');
ylabel('mm');

end

