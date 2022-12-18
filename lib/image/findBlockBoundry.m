%By default this function will look for black borders around the image
%cube.  The output is used to trim images in the form
%blockData=blockData(border_rc(1):(end-border_rc(2)+1),border_rc(3):(end-border_rc(4)+1),:);
%See the output section for exclusions when an empty is returned instead of
%a four vector border.  this will handle asymmetric borders
%
%
%OUTPUT
% Is the indication of where the valid border is
%   border_rc=[row_start row_end, col_start, col_end] an empty is returned if
%   either:
%  1. No black rows are found
%  2. Either the first or last row is not black
%  3. No black columns are found
%  4. Either the first or last column is not black
%  5. All of the columns or rows are black, of course if all the columns
%  are black then all of the rows will be also.
% row_end and col_end are number of pixels back from the end
function border_rc=findBlockBoundry(blockData)
    border_rc=zeros(1,4);

    
    blackRows=all(blockData==0,2);
    blackRows=permute(blackRows,[1 3 2]);
    blackRows=all(blackRows,2);
    
    %make sure found a black column and the start and end and there was a
    %nonblack pixel
    if blackRows(1)~=true || blackRows(end)~=true || all(blackRows)
        border_rc=[];
        return
    else       
        border_rc(1)=find(blackRows==0,1)-1;
        border_rc(2)=find(flipud(blackRows)==0,1)-1;       
    end
    
    blackColumns=all(blockData==0,1);
    blackColumns=permute(blackColumns,[2 3 1]);
    blackColumns=all(blackColumns,2);
    %no need to check all(blackColumns) becaus all(blackRows) does the same
    %thing
    if blackColumns(1)~=true || blackColumns(end)~=true 
        border_rc=[];
        return
    else       
        border_rc(3)=find(blackColumns==0,1)-1;
        border_rc(4)=find(flipud(blackColumns)==0,1)-1;    
    end
end