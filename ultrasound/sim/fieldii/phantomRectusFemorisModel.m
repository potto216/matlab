function objPhantom=phantomRectusFemorisModel(objPhantom,rectusFemorisPercentDensity,rectusFemorisMotion)

%This is the opposite of the minimum motion value to make sure it will
%always start at 1
objPhantom.rectusFemoris.model.rectusFemorisMotion=rectusFemorisMotion;
objPhantom.rectusFemoris.model.motionModelOffset=-min(rectusFemorisMotion);

if ~isempty(rectusFemorisPercentDensity)
    %This code generates the motion model for the rectusFemoriss based on user input
    objPhantom.rectusFemoris.model.rectusFemorisPercentDensity=rectusFemorisPercentDensity;
    
    
    rectusFemorisRandomLength=max(rectusFemorisMotion)-min(rectusFemorisMotion)+1+length(objPhantom.rectusFemoris.band(1).amplitude);
    rectusFemorisPattern=(rand(rectusFemorisRandomLength,length(objPhantom.rectusFemoris.band))<rectusFemorisPercentDensity);
    objPhantom.rectusFemoris.model.rectusFemorisPattern=rectusFemorisPattern;
else
end

end

