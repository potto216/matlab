function draw_circ(xdcr,color)
n=200; %higher n=smoother circles, slower function;
t=linspace(0,2*pi,n);
x=xdcr.center(1);
y=xdcr.center(2);
z=xdcr.center(3);
r=xdcr.radius;
drawx=r*cos(t);
drawy=r*sin(t);
drawz=zeros(1,n);
cord_grid=[drawx(:) drawy(:) drawz(:)];
cord_grid=trans_rot(cord_grid,[x y z],[xdcr.euler(1) xdcr.euler(2) xdcr.euler(3)],1);

fill3(cord_grid(:,1),cord_grid(:,2),cord_grid(:,3),color);
