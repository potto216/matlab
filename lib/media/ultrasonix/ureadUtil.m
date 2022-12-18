%This function performs common functions on the header to hide its
%structure.  The available functions are:
%calcInvalidBorderRectangle - will calculate a rectangle border from the valid image
%dimensions and return it in the form:
%[left(colmin) right(colmax) bottom(rowmax) top(rowmin)]
function border_rc=ureadUtil(header,ureadFunction)
switch(ureadFunction)
    case 'calcInvalidBorderRectangle'
        % top(row min) bottom(row max) left(col min) right(col xmax)
        border_rc=zeros(1,4);
        border_rc(1)=max(header.ul(2),header.ur(2));
        border_rc(2)=min((header.h-header.br(2)),(header.h-header.bl(2)));
        
        border_rc(3)=max(header.ul(1),header.bl(1));
        border_rc(4)=min((header.w-header.ur(1)),(header.w-header.br(1)));
        
                
%crop.border is the amount to remove from each of the sides
%metadata.collection.ultrasound.bmode.region.crop.border=[max(tmp.file.header.ul(1) (tmp.file.header.w-tmp.file.header.ur(1))]

    otherwise
        error(['Unsupported function of ' ureadFunction]);
end
end