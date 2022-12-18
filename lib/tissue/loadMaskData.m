%This function loads the mask data for a set of mask file names
%The rule for averaging the entropy is that we average all of the entropy
%values in the mask if they are less than 4.
function reportTable=loadMaskData(maskDatafilePath,pel2mm,loadEntropy,findDepthOffset,isColorDoppler,patientExcludeList)
import javax.xml.xpath.*;

if ~isColorDoppler
    maskFilenames=dirPlus(fullfile(maskDatafilePath,'*_mask.mat'),'recursive',true);
    maskFilenames=flattenCell(maskFilenames);
    goodPath=cellfun(@(x) ~isempty(regexp( x, '\\MTRP\d\d\d\\')),maskFilenames,'UniformOutput',true);
    maskFilenames(~goodPath)=[];
    
    
    foundValidFileIndex=regexp( maskFilenames, 'Case(?<patient>\d+)_visit(?<visit>\d)_site(?<site>\d)_repeat(?<repeat>\d)_mask\.mat');
    maskFilenames(cellfun(@(x) isempty(x),foundValidFileIndex))=[];
    
else
    allMatFilenames=dirPlus(fullfile(maskDatafilePath,'*.mat'),'recursive',true);
    allMatFilenames=flattenCell(allMatFilenames);
    goodPath=cellfun(@(x) ~isempty(regexp( x, '\\MTRP\d\d\d\\')),allMatFilenames,'UniformOutput',true);
    allMatFilenames(~goodPath)=[];
    parseOldColorFormat= cellfun(@(x) regexp( x, 'Case(?<patient>\d+)_visit(?<visit>\d)_site(?<site>\d)_repeat(?<repeat>\d)_mask\.mat','names'),allMatFilenames,'UniformOutput',false);
    oldColorFormat=cellfun(@(x) ~isempty(x) && str2double(x.patient)<5, parseOldColorFormat);
    parseNewColorFormat= cellfun(@(x) regexp( x, 'Case(?<patient>\d+)_visit(?<visit>\d)_site(?<site>\d)_repeat(?<repeat>\d)(_all|_mask_all)\.mat','names'),allMatFilenames,'UniformOutput',false);
    newColorFormat=cellfun(@(x) ~isempty(x) && str2double(x.patient)>=5, parseNewColorFormat);
    maskFilenames=allMatFilenames((oldColorFormat | newColorFormat));
    
    
    factory = XPathFactory.newInstance;
    xpath = factory.newXPath;
    xDeltaExpressionValue = xpath.compile('//object/regions/region/DeltaPerPixelX');
    xDeltaExpressionUnit = xpath.compile('//object/regions/region/DeltaPerPixelX/@unit');
    yDeltaExpressionValue = xpath.compile('//object/regions/region/DeltaPerPixelY');
    yDeltaExpressionUnit = xpath.compile('//object/regions/region/DeltaPerPixelY/@unit');            
    
end


%format: R:\potto\data\MTrP_Analysis_Images_from50to78\MTRP059\Case59_visit1_site1_repeat1_mask_debug.mat

%patientInfo=cellfun(@(x) regexp( x, 'Case(?<patient>\d+)_visit(?<visit>\d)_site(?<site>\d)_repeat(?<repeat>\d)_mask_debug\.mat$','names'),maskFilenames,'UniformOutput',true);

%maskfilenameFunc=@(caseNum,visitNum,siteNum,repeatNum) sprintf('Case%d_visit%d_site%d_repeat%d_mask.mat',caseNum,visitNum,siteNum,repeatNum);
maskfilenameFuncForEntroy=@(caseNum,visitNum,siteNum,repeatNum) sprintf('Case%d_visit%d_site%d_repeat%d_mask_tiff_data.mat',caseNum,visitNum,siteNum,repeatNum);

% maskfilenameFuncColorDopplerV1SpecialCase=@(caseNum,visitNum,siteNum,repeatNum) sprintf('Case%d_visit%d_site%d_repeat%d.mat',caseNum,visitNum,siteNum,repeatNum);
% filenameColorDopplerDataRatio=@(caseNum,visitNum,siteNum,repeatNum) sprintf('Case%d_visit%d_site%d_repeat%d_all.mat',caseNum,visitNum,siteNum,repeatNum);
filenameDepthOffset=@(caseNum,visitNum,siteNum,repeatNum) sprintf('Case%d_visit%d_site%d_repeat%d.mat',caseNum,visitNum,siteNum,repeatNum);
patientInfoParse=@(filenames) cellfun(@(x) regexp( x, 'Case(?<patient>\d+)_visit(?<visit>\d)_site(?<site>\d)_repeat(?<repeat>\d)','names'),filenames,'UniformOutput',false);
patientInfo=patientInfoParse(maskFilenames);

% badMatches=(cellfun(@(x) isempty(x), patientInfo));
% maskFilenames(badMatches)=[];
% patientInfo(badMatches)=[];
% if length(patientInfo)~=length(maskFilenames)
%     error('Lengths should be equal.');
% end

% regionMark = @(x) [find(x,1,'first') find(x,1,'last')]';

ridx=1;
reportTable=struct([]);

for ii=1:length(maskFilenames)
    
    if isempty(patientInfo{ii})
        continue;
    end
    currentPatient=str2double(patientInfo{ii}.patient);
    currentVisit=str2double(patientInfo{ii}.visit);
    currentSite=str2double(patientInfo{ii}.site);
    currentRepeat=str2double(patientInfo{ii}.repeat);
    
    if  any(currentPatient==patientExcludeList)
        continue;
    end
    
    %check for duplicates
    for cc=1:(ridx-1)
        if reportTable(cc).patient==currentPatient && reportTable(cc).visit==currentVisit && ...
                reportTable(cc).site==currentSite && reportTable(cc).repeat==currentRepeat
            error('Repeat found.');
        end
    end
    
    %first setup the blank recordpatient info
    reportTable(ridx).patient=currentPatient;
    reportTable(ridx).visit=currentVisit;
    reportTable(ridx).site=currentSite;
    reportTable(ridx).repeat=currentRepeat;
    reportTable(ridx).meanDepth_mm=[];
    reportTable(ridx).meanThickness_mm=[];
    reportTable(ridx).area_mm2=[];
    reportTable(ridx).mtrpArea_mm2=[];
    reportTable(ridx).mtrpDepth_mm=[];
    reportTable(ridx).mtrpMajorAxisLength_mm=[];
    reportTable(ridx).mtrpMinorAxisLength_mm=[];
    reportTable(ridx).ratioArea=[];
    reportTable(ridx).ratioAreaGeometricMean=[];
    reportTable(ridx).entropyAvg=[];
    reportTable(ridx).entropyArea_mm2=[];
    reportTable(ridx).depthOffset_mm=[];
    reportTable(ridx).varMTRP=[];
    reportTable(ridx).varTRAP=[];
    reportTable(ridx).ratioVAR=[];
    reportTable(ridx).ratioVARGeometricMean=[];
    reportTable(ridx).deltaPerPixelX_um=[];
    reportTable(ridx).deltaPerPixelY_um=[];
     
    maskFilenameIndexReportTableIsUsing(ridx)=ii;
    
    
    if reportTable(ridx).patient==48 && reportTable(ridx).visit==3  && reportTable(ridx).site==3 && (reportTable(ridx).repeat==1 | reportTable(ridx).repeat==2)
        disp('breakpoint');
    end
    %make sure the patient name and filename still match
    [currentPath,currentFilename, currentFileExt]=fileparts(maskFilenames{ii});
    
    
    data=load(maskFilenames{ii});
    
    if isfield(data,'inPixels')
        mask=data.inPixels;
    elseif isfield(data,'mask')
        if isfield(data.mask,'trap')
            mask=data.mask.trap;
        elseif islogical(data.mask)
            mask=data.mask;
        else
            error('Unsupported value');
        end
    else
        mask=[];
        disp(['Mask not found in ' maskFilenames{ii}]);
    end
    
    
    if ~isempty(mask)
        [upperTissueDepthMean_mm,lowerTissueDepthMean_mm,tissueThicknessMean_mm,upperTissueDepthStd_mm,lowerTissueDepthStd_mm,tissueThicknessStd_mm,tissueArea_mm2] = calcTissueWidth( mask,pel2mm );
        disp(maskFilenames{ii});
        disp(['Start depth/muscle width in mm are: ' num2str([upperTissueDepthMean_mm tissueThicknessMean_mm])]);
        
        reportTable(ridx).meanDepth_mm=upperTissueDepthMean_mm;
        reportTable(ridx).meanThickness_mm=tissueThicknessMean_mm;
        reportTable(ridx).area_mm2=tissueArea_mm2;
    end
    
    if ~isColorDoppler
        %No 50 column edge mask
        entropyFullfilename=fullfile(currentPath,maskfilenameFuncForEntroy(reportTable(ridx).patient,reportTable(ridx).visit,reportTable(ridx).site,reportTable(ridx).repeat));
        if loadEntropy && exist(entropyFullfilename,'file')
            edata=load(entropyFullfilename,'entropy_limit','validEntropyMaskRegion','maskedEntropy','Threshold');
            validEntropyValues=edata.maskedEntropy(edata.validEntropyMaskRegion);
            if ~isempty(validEntropyValues)
                reportTable(ridx).entropyAvg=mean(validEntropyValues);
            else
                reportTable(ridx).entropyAvg=[];
            end
            if isnan(reportTable(ridx).entropyAvg)
                error('NaN detected.');
            end
            reportTable(ridx).entropyArea_mm2=sum(edata.validEntropyMaskRegion(:))*pel2mm^2;
        end
    end
    
    %This is only for the color doppler
    
    
    if isColorDoppler
        if isfield(data,'fileDir')
            if exist([data.fileDir '.xml'],'file')
                xmlNode=xmlread([data.fileDir '.xml']);
                deltaPerPixelX_um = str2double(xDeltaExpressionValue.evaluate(xmlNode,XPathConstants.STRING));
                deltaPerPixelXUnit = xDeltaExpressionUnit.evaluate(xmlNode,XPathConstants.STRING);
                
                deltaPerPixelY_um = str2double(yDeltaExpressionValue.evaluate(xmlNode,XPathConstants.STRING));
                deltaPerPixelYUnit = yDeltaExpressionUnit.evaluate(xmlNode,XPathConstants.STRING);
                if ~(strcmp(deltaPerPixelXUnit,'µm') && strcmp(deltaPerPixelYUnit,'µm'))
                    error(['deltaPerPixelXUnit and deltaPerPixelYUnit are not both µm in ' data.fileDir ]);
                end
                
                reportTable(ridx).deltaPerPixelX_um=deltaPerPixelX_um;
                reportTable(ridx).deltaPerPixelY_um=deltaPerPixelY_um;
                
            else
                %skip
            end
        else
            %skip
        end
        
        if isfield(data,'area_Gold') || isfield(data,'depthMTRP')
            %area_Gold (Trigger point area in cm2)
            %            cm^2=>mm^2  (10mm/1cm)^2=100mm^2/1cm^2
            %this will cause an error if both the fields are not defined.
            reportTable(ridx).mtrpArea_mm2=data.area_Gold*100;
            reportTable(ridx).mtrpDepth_mm=data.depthMTRP{1,2};
            reportTable(ridx).mtrpMajorAxisLength_mm=data.depthMTRP{2,2};
            reportTable(ridx).mtrpMinorAxisLength_mm=data.depthMTRP{3,2};
            %         elseif colorDopplerV1SpecialCase &&  ~isfield(data,'area_Gold') && ~isfield(data,'depthMTRP')
            %
            %             alternateColorDopplerFullfilename=fullfile(currentPath,maskfilenameFuncColorDopplerV1SpecialCase(reportTable(ridx).patient,reportTable(ridx).visit,reportTable(ridx).site,reportTable(ridx).repeat));
            %             alternateData=load(alternateColorDopplerFullfilename);
            %
            %             [upperTissueDepthMean_mm,lowerTissueDepthMean_mm,tissueThicknessMean_mm,upperTissueDepthStd_mm,lowerTissueDepthStd_mm,tissueThicknessStd_mm,tissueArea_mm2] = calcTissueWidth( alternateData.mask.trap,pel2mm );
            %             disp(maskFilenames{ii});
            %             disp(['Start depth/muscle width in mm are: ' num2str([upperTissueDepthMean_mm tissueThicknessMean_mm])]);
            %
            %             reportTable(ridx).meanDepth_mm=upperTissueDepthMean_mm;
            %             reportTable(ridx).meanThickness_mm=tissueThicknessMean_mm;
            %             reportTable(ridx).area_mm2=tissueArea_mm2;
            %             %area_Gold (Trigger point area in cm2)
            %             %            cm^2=>mm^2  (10mm/1cm)^2=100mm^2/1cm^2
            %             %this will cause an error if both the fields are not defined.
            %             reportTable(ridx).mtrpArea_mm2=alternateData.area_Gold*100;
            %             reportTable(ridx).mtrpDepth_mm=alternateData.depthMTRP{1,2};
            %             reportTable(ridx).mtrpMajorAxisLength_mm=alternateData.depthMTRP{2,2};
            %             reportTable(ridx).mtrpMinorAxisLength_mm=alternateData.depthMTRP{3,2};
            %
            %         elseif colorDopplerV1SpecialCase
            %             error('This should never happen');
        else
            
        end
        
        if findDepthOffset
            depthInfoFilename=fullfile(currentPath,filenameDepthOffset(reportTable(ridx).patient,reportTable(ridx).visit,reportTable(ridx).site,reportTable(ridx).repeat));
            if exist(depthInfoFilename,'file')
                tmp=load(depthInfoFilename);
                if ~isfield(tmp,'fileDirB8')
                    error('Expected variable fileDirB8');
                end
                
                [frame,header]=uread(tmp.fileDirB8,1);
                
                [index] = find(frame(:,round(size(frame,2)/2),1)>0,1,'first');
                if header.ul(2)==header.ur(2)  && header.ul(2)==(index-1)
                    %do nothing
                else
                end
                
                %offset=(index-1)*scal4efactor
                
            else
            end
        end
        
        
        if ~isempty(reportTable(ridx).mtrpArea_mm2) && ~isempty(reportTable(ridx).area_mm2)
            reportTable(ridx).ratioArea=reportTable(ridx).mtrpArea_mm2/reportTable(ridx).area_mm2;
        end
        
        %colorDopplerDataRatioFullfilename=fullfile(currentPath,filenameColorDopplerDataRatio(reportTable(ridx).patient,reportTable(ridx).visit,reportTable(ridx).site,reportTable(ridx).repeat));
        
        
        varFieldsFound=sum([isfield(data,'VarMTRP') isfield(data,'VarTRAP') isfield(data,'RatioVAR')]);
        if (varFieldsFound~=0  && varFieldsFound~=3)
            error('The number of var fields is not correct.');
        end
        
        if isfield(data,'VarMTRP')
            reportTable(ridx).varMTRP=data.VarMTRP;
            
        else
            reportTable(ridx).varMTRP=[];
        end
        
        if isfield(data,'VarTRAP')
            reportTable(ridx).varTRAP=data.VarTRAP;
        else        
            reportTable(ridx).varTRAP=[];
        end
        
        if isfield(data,'RatioVAR')
            reportTable(ridx).ratioVAR=data.RatioVAR;
        else            
            reportTable(ridx).ratioVAR=[];
        end
        
    end
    
    ridx=ridx+1;
    
end

end


