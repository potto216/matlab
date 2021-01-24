function objPhantom=phantomTrapeziusModel(objPhantom,trapeziusPercentDensity,trapeziusMotion)
%This code generates the motion model for the trapeziuss based on user input
objPhantom.trapezius.model.trapeziusPercentDensity=trapeziusPercentDensity;
objPhantom.trapezius.model.trapeziusMotion=trapeziusMotion;

trapeziusRandomLength=max(trapeziusMotion)-min(trapeziusMotion)+1+length(objPhantom.trapezius.band(1).amplitude);
trapeziusPattern=(rand(trapeziusRandomLength,length(objPhantom.trapezius.band))<trapeziusPercentDensity);
objPhantom.trapezius.model.trapeziusPattern=trapeziusPattern;

%This is the opposite of the minimum motion value to make sure it will
%always start at 1
objPhantom.trapezius.model.motionModelOffset=-min(trapeziusMotion);
end

