function [circleShell] = circles(R,showPlot)
%CIRCLE.M Summary of this function goes here
%   Detailed explanation goes here
%Code from Chandra Kurniawan on 24 Dec 2011 http://www.mathworks.com/matlabcentral/answers/24614-cricle-packed-with-circles

[xoc, yoc] = circle([R R], R, 1000); % outer circle
[xcc, ycc] = circle([R R], 1, 1000); % center circle
circleShell(1).xCenter=R;
circleShell(1).yCenter=R;

if showPlot
    figure;
    axis([0 2*R 0 2*R]); axis off; grid off; hold on;
    plot(xoc, yoc, '-','linewidth',2,'color',0.5.*rand(1,3));
    plot(xcc, ycc, '-','linewidth',2,'color',0.5.*rand(1,3));
end

numlapis = ((2*R) - (R+1)) / 2;
for cnt1 = 1 : numlapis
    lapis(cnt1) = cnt1 * 6;
    [xCenter, yCenter] = circle([R R], cnt1*2, lapis(cnt1)+1);
    circleShell(end+1).xCenter=xCenter(1:end-1);
    circleShell(end).yCenter=yCenter(1:end-1);
    if showPlot
        
        for cnt2 = 1 : lapis(cnt1)
            [xc, yc] = circle([xCenter(cnt2)  yCenter(cnt2)], 1, 1000);
            plot(xc, yc, '-','linewidth',2,'color',0.5.*rand(1,3));
        end
    end
end
end

function [X, Y] = circle(center,radius,n)
THETA = linspace(0, 2 * pi, n);
RHO = ones(1, n) * radius;
[X, Y] = pol2cart(THETA, RHO);
X = X + center(1);
Y = Y + center(2);
end