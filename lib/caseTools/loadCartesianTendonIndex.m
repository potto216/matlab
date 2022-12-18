%This function returns which of the cartesian sample points are inside the
%tendon.  It checks to see if point types are stored in the data file and
%if so it will return those.  If not and a cmm filname is given it will use
%that.
function [isTendonPoint, samplePoints_rc]=loadCartesianTendonIndex(varargin)

p = inputParser;
p.addRequired('cartesianData', @(x) ischar(x) || isnumeric(x));
p.addOptional('cmmFullfilename', '[]',@ischar);
p.parse(varargin);

cmmFullfilename=p.Results.cmmFullfilename;

if ischar(p.Results.cartesianData)
    
    if ~isempty(whos('-file',cartesianFullfilename,'-regexp','tendonInfo'))
        cartesianData=load(cartesianFullfilename,'samplePoints_rc','tendonInfo');
        isTendonPoint=cartesianData.isTendonPoint;
        samplePoints_rc=cartesianData.samplePoints_rc;
        return;
    else
        cartesianData=load(cartesianFullfilename,'samplePoints_rc');
        cartesianData.isTendonPoint=[];
        %create the tendon map
    end
    
else
    error('not supported yet');
end




if ndims(cartesianData.samplePoints_rc)~=2
    error('This file is not cartesian data');
end

%see if the information is cached otherwise load it.
if ~isempty(cartesianData.isTendonPoint)
    error('This should have already returned.');
else
    cmmData=load(cmmFullfilename,'samplePoints_rc');
    disp('Adding index of points.');
    
    figure;
    plot(cartesianData.samplePoints_rc(2,:),cartesianData.samplePoints_rc(1,:),'b.');
    hold on
    cmmDataUnwrapAll=reshape(cmmData.samplePoints_rc,2,[]);
    cmmDataUnwrap=reshape([cmmData.samplePoints_rc(:,:,1) fliplr(cmmData.samplePoints_rc(:,:,end))],2,[]);
    plot(cmmDataUnwrapAll(2,:),cmmDataUnwrapAll(1,:),'rx');
    
    
    cmmPolygon.x=[cmmDataUnwrap(2,:) cmmDataUnwrap(2,1)];
    cmmPolygon.y=[cmmDataUnwrap(1,:) cmmDataUnwrap(1,1)];
    
    plot(cmmPolygon.x,cmmPolygon.y,'k','linewidth',2)
    legend('cartesian','cmm','tendon outline')
    
    disp('Finding the points inside the tendon.');
    [inTendon onTendon] = inpolygon(cartesianData.samplePoints_rc(2,:),cartesianData.samplePoints_rc(1,:),cmmPolygon.x,cmmPolygon.y);
    
    isTendonPoint=inTendon | onTendon;
    
    plot(cartesianData.samplePoints_rc(2,isTendonPoint),cartesianData.samplePoints_rc(1,isTendonPoint),'go');
    legend('cartesian','cmm','tendon outline','cartesian in tendon')
    
    tendonInfo.isTendonPoint=isTendonPoint;
    tendonInfo.cmmFilename=cmmFullfilename;
    
    save(cartesianFullfilename,'tendonInfo','-append');
    disp('Added tendon info to the cartesian file');
end

