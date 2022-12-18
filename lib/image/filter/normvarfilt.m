function [ im ] = normvarfilt( imBlock )
%NORMVARFILT This filter forms the normalized variance image from a block
%of frames assuming the frame index is the third dimension.
 im=std(abs(imBlock)./repmat((sum(abs(imBlock).^2,3)).^0.5,[1 1 size(imBlock,3)]),[],3);

end

