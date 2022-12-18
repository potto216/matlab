function [ imOut1 imOut2] = corrMask( im, imMask )
%CONVMASK Correlates a mask with an image using a function to generate an output image
%   This function finds the bounds of a mask and sweeps it across an image
%   applying a function to the mask region data and the data from the area
%   in the image selected by the mask.  The center point of the mask (floor
%   if even width height) is the location in the output image that is the
%   result of func(mask1,imagearea mask).  NaN is the result when no
%   correlation is given.
%   The comapring function must be in the form of
%   @(imMasterMask,imCompareMask) and return a scalar.
%INPUT
%im - an image the same size as the mask
%
%imMask - the template to correlate
imFunc = @(reg1,reg2)  kullbackLeibler( reg1,reg2 );

if ~all(size(im)==size(imMask))
    error('The imMask size and im size must be equal');
end

imTemplateMaster=im(imMask);

[maskMasterRow,maskMasterColumn]=ind2sub(size(imMask),find(imMask));

rowBounds=[min(maskMasterRow) max(maskMasterRow)];
rowHeight=diff(rowBounds)+1;

columnBounds=[min(maskMasterColumn) max(maskMasterColumn)];
columnWidth=diff(columnBounds)+1;

columnCenterOffset_base0=floor((columnWidth+1)/2);
rowCenterOffset_base0=floor((rowHeight+1)/2);

maskRow=maskMasterRow-rowBounds(1)+1;
maskColumn=maskMasterColumn-columnBounds(1)+1;

imOut1=nan(size(im));
imOut2=nan(size(im));
%evaluate everything that is the correct size
for rr=1:(size(im,1)-rowHeight+1)
    for cc=1:(size(im,2)-columnWidth+1)
        imCompareMask=im(sub2ind(size(im),maskRow+rr-1,maskColumn+cc-1));
        [imOut1(rr+rowCenterOffset_base0,cc+columnCenterOffset_base0), imOut2(rr+rowCenterOffset_base0,cc+columnCenterOffset_base0)]=imFunc(imTemplateMaster,imCompareMask);       
    end
end
        
    





end

