function zoomCallback(obj,evd,rfMotionCompare,irMotionCompare,axLeastsq)
newLim = get(evd.Axes,'XLim');
%msgbox(sprintf('The new X-Limits are [%.2f %.2f].',newLim));

%fix new limits
newLim(1)=max(round(newLim(1)),1);
newLim(2)=min(round(newLim(2)),length(rfMotionCompare));

rfMotionCompare=rfMotionCompare(newLim(1):newLim(2));
irMotionCompare=irMotionCompare(newLim(1):newLim(2));



axes(axLeastsq);
axSave=axis;
plot(rfMotionCompare,irMotionCompare,'.'); 

xlabel('RF'); ylabel('Joint Velocity IR');
axv=[min([rfMotionCompare(:); irMotionCompare(:)]) max([rfMotionCompare(:); irMotionCompare(:)])];

%xlim(axv);
%ylim(axv);
axis(axSave);


%do a least squares fit
p = polyfit(rfMotionCompare,irMotionCompare,1);
%px=axv;
px=[axSave(1) axSave(2)];
py=polyval(p,px);
hold on
plot(px,py,'r');
legend('data','line fit')
hold off

testIdx=1:length(irMotionCompare);
[b,bint,r,rint,stats] = regress(irMotionCompare(testIdx),[rfMotionCompare(testIdx) ones(size(rfMotionCompare(testIdx),1),1)]);
title(['R squared value is ' num2str(stats(1))]);

