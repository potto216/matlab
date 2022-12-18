function [ output_args ] = plotBox( newBox,color )
%DRAWBOX Summary of this function goes here
%   Detailed explanation goes here
%(xmin,ymax) (xmax, ymax) (xmax, ymin) (xmin, ymin) (xmin, ymax)
%  1    4       2     4     2      3     1     3      1      4
boxIndex=[ 1    4;       2     4 ;    2      3 ;    1     3 ;     1      4];
newBoxLine=[newBox(boxIndex(:,1)); newBox(boxIndex(:,2))];
plot(newBoxLine(1,:),newBoxLine(2,:),color);
end

