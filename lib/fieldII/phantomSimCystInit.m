% Creates a phantom of scatters with a motion profile. This returns the
% backgroup scatters which represent the location in the view (transducer) space 
% and their amplitude. These should be column vectors
% phantomData.background.x_m
% phantomData.background.y_m
% phantomData.background.z_m
% phantomData.background.amplitude
%
% WARNING assumes symmetric around xLim/yLim. The coordinates returned are
% in scatterfield space
% phantomData.xLim_m
% phantomData.yLim_m
% phantomData.zLim_m

function [phantomData] = phantomSimCystInit(varargin)

p = inputParser;   % Create an instance of the class.
p.addParamValue('totalBackgroundScatters',10000, @(x) (isnumeric(x) && isscalar(x)));
p.addParamValue('DataBlockObj',[],  @(x) isa(x,'DataBlockObj') || isempty(x));
p.addParamValue('trialData',[],  @(x) (isempty(x) || isstruct(x)) );
p.addParamValue('verbose',true,  @(x) islogical(x));
p.parse(varargin{:});

trialData = p.Results.trialData;

p=trialData.subject.phantom.parameter;

%  Create the general scatterers which are the background scatters. The
%  cysts will be formed by adjusting these. Point scatters will be added in
%  later
%These dimensions are in scatter coordinates
N = p.backgroundScatter.total;

pt_m=diag(p.scatterField.size_m)*(rand(3,N)-repmat([0.5; 0.5; 0],1,N));
amp=p.backgroundScatter.amplitude*randn(1,N);

% %Create cyst spheres
% for ii=1:length(p.sphere)
%     insideSphere = (sum((pt_m - repmat(p.sphere(ii).center_m,1,N).^2),1) < p.sphere(ii).radius_m^2);
%     amp(insideSphere) = p.sphere(ii).amplitude;
% end


%Create cyst cylinders
for ii=1:length(p.sphere)
    insideSphere = (sum((pt_m([1 3],:) - repmat(p.sphere(ii).center_m([1 3],:),1,N)).^2,1) < p.sphere(ii).radius_m^2);
    amp(insideSphere) = p.sphere(ii).amplitude;
    if false
        figure;
        plot(pt_m(1,~insideSphere),pt_m(3,~insideSphere),'b.')
        hold on;
        plot(pt_m(1,insideSphere),pt_m(3,insideSphere),'r.')
    end
end

%Create point scatters

pointLocation_m = cell2mat(arrayfun(@(x) x.center_m,p.point,'UniformOutput',false));
pointAmplitudes = [p.point.amplitude];
%  Return the variables

% phantomSize_m=trialData.subject.phantom.parameter.size_m;
% z_start=trialData.subject.phantom.parameter.originToView_m(3);
% phantomData.xLim_m =[-(phantomSize_m(1)/2) (phantomSize_m(1)/2)];   %  Width of phantom
% phantomData.yLim_m =[-(phantomSize_m(2)/2) (phantomSize_m(2)/2)];   %  Lateral
% phantomData.zLim_m =[z_start  (phantomSize_m(3) + z_start)];   %   Height of phantom

phantomData.parameters=p;
% phantomData.specifications.xSize_m=x_size;
% phantomData.specifications.ySize_m=y_size;
% phantomData.specifications.zSize_m=z_size;
% phantomData.specifications.zStart_m=z_start;

phantomData.background.x_m=[pt_m(1,:) pointLocation_m(1,:)]';
phantomData.background.y_m=[pt_m(2,:) pointLocation_m(2,:)]';
phantomData.background.z_m=[pt_m(3,:) pointLocation_m(3,:)]';
phantomData.background.amplitude=[amp pointAmplitudes]';