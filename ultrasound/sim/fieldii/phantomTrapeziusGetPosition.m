function  phantomTrapezius=phantomTrapeziusGetPosition(objPhantom,timeIndex)
%phantomTrapeziusGetPosition Compute the trapezius positions


mo=objPhantom.trapezius.model.motionModelOffset;

currentTrapeziusPattern=objPhantom.trapezius.model.trapeziusPattern((1:(length(objPhantom.trapezius.band(1).amplitude)))+mo+objPhantom.trapezius.model.trapeziusMotion(timeIndex),:);

%Override any base configurations
phantomTrapezius.x_m=[];
phantomTrapezius.y_m=[];
phantomTrapezius.z_m=[];
phantomTrapezius.amplitude=[];

for tt=1:length(objPhantom.trapezius.band)
        
    phantomTrapezius.x_m=[phantomTrapezius.x_m; objPhantom.trapezius.band(tt).x_m(currentTrapeziusPattern(:,tt)) ];
    phantomTrapezius.y_m=[phantomTrapezius.y_m; objPhantom.trapezius.band(tt).y_m(currentTrapeziusPattern(:,tt)) ];
    phantomTrapezius.z_m=[phantomTrapezius.z_m; objPhantom.trapezius.band(tt).z_m(currentTrapeziusPattern(:,tt)) ];
    phantomTrapezius.amplitude=[phantomTrapezius.amplitude; objPhantom.trapezius.band(tt).amplitude(currentTrapeziusPattern(:,tt)) ];
end



end

