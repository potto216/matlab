clear 
rectusFemoris1
dataType='rf';
[objPhantom,objFieldII,matFilepath, fieldii,image]=parforLoadData_phantomSimulateRectusFemorisMotion( metadata.phantom);
if strcmpi(dataType,'fieldii')
    
    
    dataBlockObjMetadata.scale.lateral.value=getCaseRFUnits(objPhantom.phantomArguments{6}.metadata.ultrasound,'lateral','mm');
    dataBlockObjMetadata.scale.lateral.units='mm';
    dataBlockObjMetadata.scale.axial.value=getCaseRFUnits(objPhantom.phantomArguments{6}.metadata.ultrasound,'axial','mm');
    dataBlockObjMetadata.scale.axial.units='mm';
    dataBlockObjMetadata.ultrasound=objPhantom.caseData.metadata.ultrasound;
    
    dataBlockObj=DataBlockObj(fieldii.imBlock,'matlabArray','metadataMaster',dataBlockObjMetadata);
    dataBlockObj.open()
elseif strcmpi(dataType,'image')
    dataBlockObjMetadata.scale.lateral.value=getCaseRFUnits(objPhantom.phantomArguments{6}.metadata.ultrasound,'lateral','mm');
    dataBlockObjMetadata.scale.lateral.units='mm';
    dataBlockObjMetadata.scale.axial.value=getCaseRFUnits(objPhantom.phantomArguments{6}.metadata.ultrasound,'axial','mm');
    dataBlockObjMetadata.scale.axial.units='mm';
    dataBlockObjMetadata.ultrasound=objPhantom.caseData.metadata.ultrasound;
    
    dataBlockObj=DataBlockObj(image.imBlock,'matlabArray','metadataMaster',dataBlockObjMetadata);
    dataBlockObj.open()
elseif  strcmpi(dataType,'rf')
    openArgs={'frameFormatComplex',true};
    dataBlockObj=DataBlockObj(objPhantom.phantomArguments{6}.metadata.rfFilename,@uread,'openArgs',openArgs);
    dataBlockObj.open('cacheMethod','all');
    processFunction=@(x) abs(x).^0.5;
    dataBlockObj.newProcessStream('agentLab',processFunction, true);   
else
    error(['Invalid data type: ' dataType]);
end

%Now run the tracker on the data aobject
findSpline= @(splineName) metadata.agent(arrayfun(@(a) strcmp(a.name,splineName),metadata.agent));

topSpline=findSpline('topSpline');
bottomSpline=findSpline('bottomSpline');
lateralDim_pel=[1:dataBlockObj.size(2)];
ptTop_rc=[spline(topSpline.vpt(2,:),topSpline.vpt(1,:),lateralDim_pel); lateralDim_pel];
ptBottom_rc=[spline(bottomSpline.vpt(2,:),bottomSpline.vpt(1,:),lateralDim_pel); lateralDim_pel];
scaleMatrixTo_mm=diag([dataBlockObj.getUnitsValue('axial','mm'), dataBlockObj.getUnitsValue('lateral','mm')]);

ptTop_mm=scaleMatrixTo_mm*ptTop_rc;
ptBottom_mm=scaleMatrixTo_mm*ptBottom_rc;


validWindow_rc=round([[min(ptTop_rc(1,:),[],2) max(ptBottom_rc(1,:),[],2)];[min([ptTop_rc(2,:) ptBottom_rc(2,:)],[],2) max([ptTop_rc(2,:) ptBottom_rc(2,:)],[],2)]]);

if true
    %%
    dataBlockObj.image(1)
    hold on;
    plot(ptTop_mm(2,:),ptTop_mm(1,:),'r');
    plot(ptBottom_mm(2,:),ptBottom_mm(1,:),'r');
    
end

im=dataBlockObj.getSlice(1);
[imRows,imColumns] = ndgrid(1:size(im,1),1:size(im,2));
IN = inpolygon(imColumns(:),imRows(:),[ptTop_rc(2,:) fliplr(ptBottom_rc(2,:))],[ptTop_rc(1,:) fliplr(ptBottom_rc(1,:))]);
%IN = inpolygon(imColumns(:),imRows(:),[1 100 100 1],[500 500 800 800]);
imo=im;

imo(~IN)=nan;
figure; imagesc(imo)

windowSize_rc=[51;11];
[windowRows,windowColumns] = ndgrid(1:windowSize_rc(1),1:windowSize_rc(2));

%indexBlock=zeros(windowSize_rc(1)*windowSize_rc(2),((size(im,1)-1)-windowSize_rc(1)),((size(im,2)-1)-windowSize_rc(2)));
%indexBlock=zeros(windowSize_rc(1)*windowSize_rc(2),diff(validWindow_rc(1,:))+1-windowSize_rc(1), diff(validWindow_rc(2,:))+1-windowSize_rc(2));
indexBlock=zeros(windowSize_rc(1)*windowSize_rc(2),diff(validWindow_rc(1,:))+1-windowSize_rc(1), diff(validWindow_rc(2,:))+1-windowSize_rc(2));
indexBlockValid=zeros(diff(validWindow_rc(1,:))+1-windowSize_rc(1), diff(validWindow_rc(2,:))+1-windowSize_rc(2));

%What we want to do is find all; of the blocks that are only in the region
%and then extract the image values for them which can then be used as
%feature vectors for tracking
for ir=validWindow_rc(1,1):(validWindow_rc(1,2)-windowSize_rc(1))
    for ic=validWindow_rc(2,1):(validWindow_rc(2,2)-windowSize_rc(2))
        imInd=sub2ind(size(im),windowRows+ir-1,windowColumns+ic-1);
        indexBlock(:,ir,ic)=imInd(:);     
        indexBlockValid(ir,ic)=~any(isnan(imo(imInd(:))));   
        
    end
end

any(isnan(imo(imInd(:))))