function x=scaleTo1(x)

x=x-min(x(:));
x=x/max(x(:));