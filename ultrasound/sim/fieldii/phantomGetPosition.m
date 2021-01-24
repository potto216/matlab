function  [phantomScatters, averageMotion_m]=phantomGetPosition(objPhantom,timeIndex,scattersToReturn)
%phantomRectusFemorisGetPosition Compute the positions of the phantom
%scatters for a specific position in time.  The scatters to return can be
%selected.
%The coordinates retured are in world space.
%INPUT
%objPhantom
%timeIndex
%scattersToReturn-{'all-scatters','only-roiScatters'}
%
%OUTPUT
%phantomScatters - the collection of requested scatters. The coordinates retured are in world space.
switch(nargin)
    case 2
        scattersToReturn='all-scatters';
    case 3
        %do nothing
    otherwise
        error('Must have 2 or 3 input arguments');
end

averageMotion_m=[];


switch(objPhantom.name)
    case 'tendon'
        error('Please Add');
        
    case {'rectusFemoris','rectusFemoris_sphereScatter','rectusFemoris_fascicle'}
        [phantomROI, averageMotion_m]=phantomRectusFemorisGetPosition(objPhantom,timeIndex);
        switch(scattersToReturn)
            case 'all-scatters'
                
%                 phantomScatters.x_m=[objPhantom.background.x_m; phantomROI.x_m]+objPhantom.parameters.scatterField.originToWorld_m(1);
%                 phantomScatters.y_m=[objPhantom.background.y_m; phantomROI.y_m]+objPhantom.parameters.scatterField.originToWorld_m(2);
%                 phantomScatters.z_m=[objPhantom.background.z_m; phantomROI.z_m]+objPhantom.parameters.scatterField.originToWorld_m(3);
%        
                phantomScatters.x_m=[objPhantom.background.x_m; phantomROI.x_m];
                phantomScatters.y_m=[objPhantom.background.y_m; phantomROI.y_m];
                phantomScatters.z_m=[objPhantom.background.z_m; phantomROI.z_m];
       
                phantomScatters.amplitude=[objPhantom.background.amplitude; phantomROI.amplitude];
            case 'only-roiScatters'
                error('Need to be in world coordinates');
                phantomScatters=phantomROI;
            otherwise
                error(['Invalid area to return of ' scattersToReturn]);
        end
    case 'trapezius'
        error('Please Add');
        
    case 'cyst'
        [phantomAllScatters, averageMotion_m]=phantomCystGetPosition(objPhantom,timeIndex);
        switch(scattersToReturn)
            case {'all-scatters'}
                phantomScatters=phantomAllScatters;
            case 'only-roiScatters'
                error('cyst model only works with all-scatters');                              
            otherwise
                error(['Invalid area to return of ' scattersToReturn]);
        end
    otherwise
        error(['The phantom name of ' objPhantom.name ' is not supported.'])
end

if false
    %% Show the ROI
    figure; plot3(phantomAllScatters.x_m,phantomAllScatters.y_m,phantomAllScatters.z_m,'b.'); xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
end



end

