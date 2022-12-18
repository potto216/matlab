function draw_scatterers(scatterers)
%DRAW_SCATTERERS Draw some scatterers

nscatterers = length(scatterers);

figure();
for i = 1:nscatterers
    x = scatterers(i).x;
    y = scatterers(i).y;
    z = scatterers(i).z;
    scatter3(x,y,z);
    hold on;
end
xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');
end
