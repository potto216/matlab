function  phantomTendon=phantomTendonGetPosition(objPhantom,timeIndex)
%phantomTendonGetPosition Compute the tendon positions


mo=objPhantom.tendon.model.motionModelOffset;

currentTendonPattern=objPhantom.tendon.model.tendonPattern((1:(length(objPhantom.tendon.band(1).amplitude)))+mo+objPhantom.tendon.model.tendonMotion(timeIndex),:);

%Override any base configurations
phantomTendon.x_m=[];
phantomTendon.y_m=[];
phantomTendon.z_m=[];
phantomTendon.amplitude=[];

for tt=1:length(objPhantom.tendon.band)
        
    phantomTendon.x_m=[phantomTendon.x_m; objPhantom.tendon.band(tt).x_m(currentTendonPattern(:,tt)) ];
    phantomTendon.y_m=[phantomTendon.y_m; objPhantom.tendon.band(tt).y_m(currentTendonPattern(:,tt)) ];
    phantomTendon.z_m=[phantomTendon.z_m; objPhantom.tendon.band(tt).z_m(currentTendonPattern(:,tt)) ];
    phantomTendon.amplitude=[phantomTendon.amplitude; objPhantom.tendon.band(tt).amplitude(currentTendonPattern(:,tt)) ];
end



end

