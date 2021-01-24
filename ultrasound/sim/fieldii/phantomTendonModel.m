function objPhantom=phantomTendonModel(objPhantom,tendonPercentDensity,tendonMotion)
%This code generates the motion model for the tendons based on user input
objPhantom.tendon.model.tendonPercentDensity=tendonPercentDensity;
objPhantom.tendon.model.tendonMotion=tendonMotion;

tendonRandomLength=max(tendonMotion)-min(tendonMotion)+1+length(objPhantom.tendon.band(1).amplitude);
tendonPattern=(rand(tendonRandomLength,length(objPhantom.tendon.band))<tendonPercentDensity);
objPhantom.tendon.model.tendonPattern=tendonPattern;

%This is the opposite of the minimum motion value to make sure it will
%always start at 1
objPhantom.tendon.model.motionModelOffset=-min(tendonMotion);
end

