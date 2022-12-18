%All coordiantes returned must be in world space
function objPhantom=phantomCreateModel(trialData,objFieldII,dataBlockObj)


p=trialData.subject.phantom.parameter;

switch(p.modelName)
    case 'tendon'
        
    case {'rectusFemoris', 'rectusFemoris_sphereScatter', 'rectusFemoris_fascicle'}
        [ objPhantom ] = phantomLoad( objFieldII,p.modelName,{'totalBackgroundScatters',p.totalBackgroundScatters, ...
    'totalBandsPerRectusFemoris',p.totalBandsPerRectusFemoris, ...
    'DataBlockObj',dataBlockObj,'trialData',trialData});

        if ~isfield(p,'rectusFemorisPercentDensity')
            error('Please add trialData.subject.phantom.parameter.rectusFemorisPercentDensity=[]; to your data file.');
            
        else
            %do nothing
        end
        objPhantom.rectusFemoris.motion.offset_m=p.offset_m;
        
    case 'trapezius'
        
    case 'cyst'
        [ objPhantom ] = phantomLoad( objFieldII,p.modelName,{'trialData',trialData});
    otherwise
        error(['The phantom name of ' name ' is not supported.'])
end


%This is an old depricated model which should not be used anymore
%objPhantom=phantomRectusFemorisModel(objPhantom,p.rectusFemorisPercentDensity,p.rectusFemorisMotion);

end