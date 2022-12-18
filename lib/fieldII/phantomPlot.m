function [im, zWorldAxis_m, xWorldAxis_m] = phantomPlot(objPhantom,pointSet,imageSize_rc,rfAxialUnitsValue_mmPerPel,rfLateralUnitsValue_mmPerPel,oversampleFactor,imresizeFilter )

%PHANTOMPLOT This function plots a projected view of the phantom onto an image plane
%for 3D views the image can be constrained in width to generate slices
%sliceWidth_m - i
%The way the  volume is sliced is to start at the min y value and step in
%sliceWidth incs across.  This means that the last slice may go over the
%yLim max value.  to avoid counting points twice that fall exactly at the
%slice boundry use a < without equality at end boundary
%
%All coordiantes are in world coordinates and it is assumed the transducer
%is centered at 0,0,0


imOversampleSize_rc=imageSize_rc*oversampleFactor;  %This will be downsampled later
imOversample=zeros(imOversampleSize_rc);

%get the new sampled spacing

% im(ii).imresize.filter=imOutputFormatList(ii).imresize.filter;
% im(ii).oversample_rc=[im(ii).finalHeight_pel*im(ii).oversampleFactor im(ii).finalWidth_pel*im(ii).oversampleFactor];  %This will be downsampled later
% im(ii).imresize.filter=imOutputFormatList(ii).imresize.filter;

%sliceCount=ceil((objPhantom.yLim_m(2)-objPhantom.yLim_m(1))/sliceWidth_m);
%sliceBoundaryY_m=sliceWidth_m*[(0:(sliceCount-1));(1:(sliceCount))]+objPhantom.yLim_m(1);
rfOversampleAxialUnitsValue_mmPerPel = rfAxialUnitsValue_mmPerPel/oversampleFactor;
rfOversampleLateralUnitsValue_mmPerPel = rfLateralUnitsValue_mmPerPel/oversampleFactor;

%Convert the world space x/z to column/row. This is down by scaling the
%x and z by dividing by a pixel width. the x coordinate (column) needs to be
%uncentered by adding half the image width.
bColumn=round(pointSet.x_m/(rfOversampleLateralUnitsValue_mmPerPel/1000)) + imOversampleSize_rc(2)/2;
bRow=round(pointSet.z_m/(rfOversampleAxialUnitsValue_mmPerPel/1000));

%The may be a 1 off issues, but oversampling reduces it to 1/oversample
%off
badIndexList = (bColumn < 1) | (bColumn > imOversampleSize_rc(2)) | (bRow < 1) | (bRow > imOversampleSize_rc(1));
if false
    %%
    figure; subplot(1,2,1); hist(bColumn(:),1111);
     subplot(1,2,2); hist(bRow(:),1111);
end


bInd=sub2ind(imOversampleSize_rc,bRow(~badIndexList),bColumn(~badIndexList));
%The leading one and ending size^2 make sure the array is the full
%image size.
imOversample=reshape(accumarray([1; bInd; imOversampleSize_rc(1)*imOversampleSize_rc(2)],[0; pointSet.amplitude(~badIndexList); 0]).',imOversampleSize_rc);

if false
    %%
    figure; imagesc((abs(imOversample)).^0.5); colormap(gray(256)); colorbar
    figure; hist(imOversample(:),1111)
end

im=imresize(imfilter(imOversample,imresizeFilter(),'replicate'),imageSize_rc,'bicubic');
%row space
zWorldAxis_m = linspace(0,rfAxialUnitsValue_mmPerPel/1000*(size(im,1)-1),size(im,1));
%column space
xWorldAxis_m = linspace(0,rfLateralUnitsValue_mmPerPel/1000*(size(im,2)-1),size(im,2))-rfLateralUnitsValue_mmPerPel/1000*(size(im,2))/2;

if false
    %%
    figure; imagesc(xWorldAxis_m,zWorldAxis_m,(abs(im)).^0.5); colormap(gray(256)); colorbar

end

end