%INPUTS
%   imTemplate - the image is what you are looking for in the target so it
%   is smaller;
%	roiRow - if a vector assumes that this specifies the row elements
%on a rectangular lattice.  The offset starts at 1.
%
%	roiColumn - if a vector assumes that this specifies the column elements
%on a rectangular lattice.  The offset starts at 1.
%	
%OUTPUTS
%	mvImg-Is the motion of the template.  Only the values that are valid are where roiRow and roiColumn are given.
function [mvImg]=computeLatticeMotion( imTemplate, imTarget, templateSize_rc,searchSize_rc,roiRow,roiColumn)

if ~all(size(imTemplate)==size(imTarget)) || length(size(imTemplate))~=2 || length(size(imTarget))~=2
  error('The target and template must be the same image size and only a two dimensional image')
end

%Validate the input data
if ~isvector(templateSize_rc) || length(templateSize_rc)~=2 || ~isnumeric(templateSize_rc) || any(templateSize_rc<=0) || ~isNoFraction(templateSize_rc)
 error(['templateSize_rc must be a vector of length 2 and an integer and its values must be greater than 0'])
end

if ~isvector(searchSize_rc) || length(searchSize_rc)~=2 || ~isnumeric(searchSize_rc) || any(searchSize_rc<=0) || ~isNoFraction(searchSize_rc)
 error(['searchSize_rc must be a vector of length 2 and an integer and its values must be greater than 0'])
end

if ~isvector(roiRow) || ~isnumeric(roiRow) || any(roiRow<=0) || ~isNoFraction(roiRow)
 error(['roiRow must be a vector and an integer and its values must be greater than 0'])
end

if ~isvector(roiColumn) || ~isnumeric(roiColumn) || any(roiColumn<=0) || ~isNoFraction(roiColumn)
 error(['roiColumn must be a vector and an integer and its values must be greater than 0'])
end


mvImg = zeros(size(imTemplate));

for rowIdx = roiRow
     disp(sprintf('processing depth %d',rowIdx));
    for colIdx = roiColumn
        search_x = rowIdx:rowIdx+searchSize_rc(1)-1;
		search_y = colIdx:colIdx+searchSize_rc(2)-1;
		template_x = rowIdx+round(searchSize_rc(1)/2-templateSize_rc(1)/2):rowIdx+round(searchSize_rc(1)/2+templateSize_rc(1)/2)-1;
		template_y = colIdx+round(searchSize_rc(2)/2-templateSize_rc(2)/2):colIdx+round(searchSize_rc(2)/2+templateSize_rc(2)/2)-1;

		mv = computeMotion(imTemplate(template_x,template_y), imTarget(search_x,search_y), [template_x(1); template_y(1)], [search_x(1); search_y(1)]);
		mvImg(rowIdx,colIdx) = 1j*mv(1) + mv(2);
	end
end



