%function im = ReadImage(filename,image_type,...)
%
%read image according to its type
%output has been converted to double precision
%Written by Hailin Jin
%Copyright (c) Washington University
%All rights are reserved
%Last updated 10/21/2000

function [im,size_im] = ReadImage(filename,image_type,width,height)

if nargin==1,
  %try without hesitation
  im = double(imread(filename));
end;

if image_type=='ras',
  im = readras(filename);
elseif image_type=='raw',
  im = readraw(filename);
elseif image_type=='pgm',
  im = readpqm(filename);
elseif image_type=='ppm',
  im = readppm(filename);
elseif image_type=='dat',
  fid = fopen(filename,'r','ieee-le');
  im = zeros(height,width);
  im = fread(fid,[height,width],'double');
  fclose(fid);
else,
  %try standard image reading routines
  im = double(imread(filename));
end;

if nargout==2,
  %size_im is set to be a column vector
  size_im = size(im)';
end;
