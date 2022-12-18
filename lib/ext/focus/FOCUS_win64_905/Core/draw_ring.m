function draw_ring(xdcr, color)
n = 200; %higher n=smoother circles, slower function;
t = linspace(0,2*pi,n);
x = xdcr.center(1);
y = xdcr.center(2);
z = xdcr.center(3);
r1 = xdcr.inner_radius;
r2 = xdcr.outer_radius;

drawx1=r1*cos(t);
drawy1=r1*sin(t);
drawx2=r2*cos(t);
drawy2=r2*sin(t);
drawz=zeros(1,n);

cord_grid1=[drawx1(:) drawy1(:) drawz(:)];
cord_grid1=trans_rot(cord_grid1,[x y z],[xdcr.euler(1) xdcr.euler(2) xdcr.euler(3)],1);

cord_grid2=[drawx2(:) drawy2(:) drawz(:)];
cord_grid2=trans_rot(cord_grid2,[x y z],[xdcr.euler(1) xdcr.euler(2) xdcr.euler(3)],1);

fill3(cord_grid2(:,1),cord_grid2(:,2),cord_grid2(:,3),color,cord_grid1(:,1),cord_grid1(:,2),cord_grid1(:,3),'w');
end