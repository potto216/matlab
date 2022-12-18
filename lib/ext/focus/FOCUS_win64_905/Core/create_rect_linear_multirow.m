function xdcr = create_rect_linear_multirow (nelex, neley, element_width,element_heights, kerf_x, kerf_y, center)
%  Parameters:   nelex    -  Number of physical elements in x-direction.
%                neley    -  Number of physical elements in y-direction.
%                element_width       -  element_width in x-direction of elements.
%                element_heights     -  Heights of the element rows in the y-direction. 
%                               Vector with no_elem_y values.  
%                kerf_x      -  element_width in x-direction between elements.
%                kerf_y      -  element_width in y-direction between elements.
%                center[]     -  Fixed center for array (x,y,z). Vector with three elements.

if nargin==0
	disp('Please enter the following arguments:')
	disp('nelex, neley, element width, element heights(an neleyx1 array), x kerf, y kerf, center(a 3x1 array)')
	nelex=input('nelex:');
	neley=input('neley:');
    element_width=input('element_width:');
	element_heights=input('element_heights:');
	if nelex~=1
        kerf_x=input('x kerf:');
    else 
        kerf_x=element_width*0.1;
    end
    if neley~=1
        kerf_y=input('y kerf:');
    else
        kerf_y=element_heights*0.1;
    end
	center=[0 0 0];
end
if nargin()==6
    center=[0 0 0];
end
if length(center)~=3
    center=[ 0 0 0];
end
if length(element_heights) ~= neley
    disp('Warning: length of heights vector does not equal number of elements in the y direction.')
    disp('Setting all heights to length 1')
    element_heights = ones(1,neley);
end
if mod(nelex,2)==1 
    xf=0;
else
    xf=.5;
end
h_sum = 0;
spacing_x = kerf_x + element_width;
spacing_y = zeros(1,neley);
y_coords = zeros(1,neley);
for k = 1:neley   

    spacing_y(k) = kerf_y + element_heights(k);
    if k > 1
        h_sum = h_sum + spacing_y(k);
    end
    if k == 1
        y_coords(k) = 0;
    else
        y_coords(k) = y_coords(k-1) + spacing_y(k-1)/2 + spacing_y(k)/2;
    end
end
x_coords = floor(-(nelex-1)/2):floor((nelex-1)/2);
center(2) = center(2) - h_sum/2;

for i=1:nelex
    for j=1:neley
        x = x_coords(i)*spacing_x+xf*spacing_x+center(1);
        y = y_coords(j)+center(2);%+spacing_y(j)+yf*spacing_y(j)+center(2); 
        z = center(3);
        xdcr(i,j)=get_rect(element_width,element_heights(j),[x y z],[0 0 0]);
    end
end

end


