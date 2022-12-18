function scatterers = fill_with_scatterers(xcoords, ycoords, zcoords)
%FILL_WITH_SCATTERERS Return a vector of scatterers located at every point
%in x, y, and z

xsize = length(xcoords);
ysize = length(ycoords);
zsize = length(zcoords);

nscatterers = xsize * ysize * zsize;
scatterers(nscatterers) = get_scatterer(0,0,0);

for i = 1:xsize
    for j = 1:ysize
        for k = 1:zsize
            index = (i-1) + (j-1)*xsize + (k-1)*xsize*ysize + 1;
            scatterers(index) = get_scatterer(xcoords(i),ycoords(j),zcoords(k));
        end
    end
end
end

