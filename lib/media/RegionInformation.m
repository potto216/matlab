classdef RegionInformation  < handle
    %REGIONINFORMATION This class allows region information to be stored and accessed on a per frame basis.
    
    properties  (GetAccess = public, SetAccess = private)
        region=[];
        imSample=[];
    end
    
    methods (Access=public)
        %This function returns the mask for the specified region for a
        %current frame
        function getMask(this,regionName,currentFrame,dataBlockObj)
        end
        
        function addRegionFromTrialData(this,viewName,dataBlockObj,trialData,activeRegionName)
            %**********************************************************************
            %*    FORM/LOAD BOUNDARY REGION
            %* This is needed by some of the tracking algorithms
            %**********************************************************************
            
            %     'collection.fieldii.bmode'
            %     'collection.ultrasound.bmode'
            % 'collection.ultrasound.rf'
            % 'collection.projection'
            switch(nargin)
                case 4
                    activeRegionName=[];
                case 5
                otherwise
                    error('Invalid number of inputs');
            end
            
            if isempty(activeRegionName)                
                activeRegionIndex=1;
            else
                switch(viewName)
                    case 'collection.fieldii.bmode'
                        activeRegionIndex=find(arrayfun(@(x) strcmp(x.name,activeRegionName), trialData.collection.fieldii.mode.region));
                    case 'collection.projection.bmode'
                        activeRegionIndex=find(arrayfun(@(x) strcmp(x.name,activeRegionName), trialData.collection.projection.bmode.region));
                    case 'collection.ultrasound.bmode'
                        activeRegionIndex=find(arrayfun(@(x) strcmp(x.name,activeRegionName), trialData.collection.ultrasound.bmode.region));
                    case 'collection.ultrasound.rf'
                        activeRegionIndex=find(arrayfun(@(x) strcmp(x.name,activeRegionName), trialData.collection.ultrasound.rf.region));
                    otherwise
                        error(['Not currently handeling ' viewName]);
                end
               
                if length(activeRegionIndex)~=1                    
                    error(['activeRegionName ' activeRegionIndex ' does not correspond to only one region name. Make sure the name and case are correct.']);
                else
                    %do nothing
                end
            end
            
            switch(viewName)
                case 'collection.fieldii.bmode'
                    activeRegion=trialData.collection.fieldii.bmode.region(activeRegionIndex);
                    if tIsBranch(trialData,[viewName '.region'])
                        findSpline= @(splineName) activeRegion.agent(arrayfun(@(a) strcmp(a.name,splineName),activeRegion.agent));
                    else
                        warning(['No region information found for ' viewName]);
                        return
                    end
                case 'collection.projection.bmode'
                    activeRegion=trialData.collection.projection.bmode.region(activeRegionIndex);
                    if tIsBranch(trialData,[viewName '.region'])
                        findSpline= @(splineName) activeRegion.agent(arrayfun(@(a) strcmp(a.name,splineName),activeRegion.agent));
                    else
                        warning(['No region information found for ' viewName]);
                        return
                    end                    
                case 'collection.ultrasound.bmode'
                    activeRegion=trialData.collection.ultrasound.bmode.region(activeRegionIndex);
                    if tIsBranch(trialData,[viewName '.region'])
                        findSpline= @(splineName) activeRegion.agent(arrayfun(@(a) strcmp(a.name,splineName),activeRegion.agent));
                    else
                        warning(['No region information found for ' viewName]);
                        return
                    end
                case 'collection.ultrasound.rf'
                    activeRegion=trialData.collection.ultrasound.rf.region(activeRegionIndex);
                    if tIsBranch(trialData,[viewName '.region'])
                        findSpline= @(splineName) activeRegion.agent(arrayfun(@(a) strcmp(a.name,splineName),activeRegion.agent));
                    else
                        warning(['No region information found for ' viewName]);
                        return
                    end                    
                otherwise
                    warning(['Not currently handeling ' viewName]);
                    return
            end
            
            
            
            topSpline=findSpline('topRFBorder');
            if isempty(topSpline)
                topSpline=findSpline('topSpline');
            end
            
            bottomSpline=findSpline('bottomRFBorder');
            if isempty(bottomSpline)
                bottomSpline=findSpline('bottomSpline');
            end
            
            lateralDim_pel=(1:dataBlockObj.size(2));
            
            %We need to form the region polygon in a clockwise form therefor we use:
            ptTop_rc=[spline(topSpline.vpt(2,:),topSpline.vpt(1,:),lateralDim_pel); lateralDim_pel];
            
            ptBottom_rc=[spline(bottomSpline.vpt(2,:),bottomSpline.vpt(1,:),lateralDim_pel); lateralDim_pel];
            this.region.prPolygon_rc=[ptTop_rc fliplr(ptBottom_rc)];
            
            this.imSample=dataBlockObj.getSlice(4,[]);
            this.region.scale_mm=[dataBlockObj.getUnitsValue('lateral','mm') dataBlockObj.getUnitsValue('axial','mm')];
            this.region.mask = poly2mask(this.region.prPolygon_rc(2,:), this.region.prPolygon_rc(1,:),size(this.imSample,1),size(this.imSample,2));
            this.region.interiorBoundary_rc=[max(ptTop_rc(1,:)) min(ptBottom_rc(1,:)); min(lateralDim_pel) max(lateralDim_pel)];
            this.region.exteriorBoundary_rc=[min(ptTop_rc(1,:)) max(ptBottom_rc(1,:)); min(lateralDim_pel) max(lateralDim_pel)];
            this.region.view=viewName;
            this.region.data=activeRegion;
            
            
        end
        
        %Plot the region information
        %If the hold is on it will overlay the plot assuming the units to
        %be mm
        function plot(this,showInteriorExteriorBoundary)
            switch(nargin)
                case 1
                    showInteriorExteriorBoundary=false;
                case 2
                    %do nothing
                otherwise
                    error('Invalid number of input arguments.');
            end
            
            drawRectangle=@(b_rc,color) plot([b_rc(2,1) b_rc(2,2) b_rc(2,2) b_rc(2,1)], [b_rc(1,1) b_rc(1,1) b_rc(1,2) b_rc(1,2)],color);
            
            regionBorder_rc=bwboundaries(this.region.mask);
            regionBorder_rcInMm=diag([this.region.scale_mm(2) this.region.scale_mm(1)])*regionBorder_rc{1}';
            if ~ishold
                imageOverlay( this.imSample,this.region.mask,this.region.scale_mm);
                hold on;
                plot(regionBorder_rcInMm(2,:),regionBorder_rcInMm(1,:),'y','lineWidth',2)
                hold off;
            else
                % assume hold on means that the  we are just ploting on another region 
                plot(regionBorder_rcInMm(2,:),regionBorder_rcInMm(1,:),'y','lineWidth',1)
            end
            
            
            if showInteriorExteriorBoundary
                drawRectangle(diag(fliplr(this.region.scale_mm))*this.region.interiorBoundary_rc,'r');
                drawRectangle(diag(fliplr(this.region.scale_mm))*this.region.exteriorBoundary_rc,'g');
                legend('rectangular interior','rectangular exterior')
            else
            end
            
            title('Valid Region (yellow)')
        end
        
    end
    
end

