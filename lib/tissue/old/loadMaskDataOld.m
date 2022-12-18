%This function loads the mask data for a set of mask file names
%The rule for averaging the entropy is that we average all of the entropy
%values in the mask if they are less than 4.
function reportTable=loadMaskData(maskDatafilePath,pel2mm,loadEntropy,colorDopplerV1SpecialCase,findDepthOffset)

maskFilenames=dirPlus(fullfile(maskDatafilePath,'*_mask.mat'),'recursive',true);

%format: R:\potto\data\MTrP_Analysis_Images_from50to78\MTRP059\Case59_visit1_site1_repeat1_mask_debug.mat
maskFilenames=flattenCell(maskFilenames);
%patientInfo=cellfun(@(x) regexp( x, 'Case(?<patient>\d+)_visit(?<visit>\d)_site(?<site>\d)_repeat(?<repeat>\d)_mask_debug\.mat$','names'),maskFilenames,'UniformOutput',true);

maskfilenameFunc=@(caseNum,visitNum,siteNum,repeatNum) sprintf('Case%s_visit%s_site%s_repeat%s_mask.mat',caseNum,visitNum,siteNum,repeatNum);
maskfilenameFuncForEntroy=@(caseNum,visitNum,siteNum,repeatNum) sprintf('Case%s_visit%s_site%s_repeat%s_mask_tiff_data.mat',caseNum,visitNum,siteNum,repeatNum);

maskfilenameFuncColorDopplerV1SpecialCase=@(caseNum,visitNum,siteNum,repeatNum) sprintf('Case%s_visit%s_site%s_repeat%s.mat',caseNum,visitNum,siteNum,repeatNum);
filenameDepthOffset=@(caseNum,visitNum,siteNum,repeatNum) sprintf('Case%s_visit%s_site%s_repeat%s.mat',caseNum,visitNum,siteNum,repeatNum);

patientInfo=cellfun(@(x) regexp( x, 'Case(?<patient>\d+)_visit(?<visit>\d)_site(?<site>\d)_repeat(?<repeat>\d)_mask\.mat$','names'),maskFilenames,'UniformOutput',false);


badMatches=(cellfun(@(x) isempty(x), patientInfo));
maskFilenames(badMatches)=[];
patientInfo(badMatches)=[];
if length(patientInfo)~=length(maskFilenames)
    error('Lengths should be equal.');
end

% regionMark = @(x) [find(x,1,'first') find(x,1,'last')]';

ridx=1;
reportTable=struct([]);
for ii=1:length(maskFilenames)
    
    %make sure the patient name and filename still match
    [currentPath,currentFilename, currentFileExt]=fileparts(maskFilenames{ii});
    if ~strcmpi(maskfilenameFunc(patientInfo{ii}.patient,patientInfo{ii}.visit,patientInfo{ii}.site,patientInfo{ii}.repeat),[currentFilename currentFileExt])
        error('Filename does not match patient info');
    end
    
    
    
    %     checkFile='Case82_visit1_site4_repeat1_mask';
    %
    %     if strcmpi(currentFilename,checkFile)
    %         disp('break');
    %     end
    if ~isempty(patientInfo{ii})
        data=load(maskFilenames{ii});
        if isfield(data,'inPixels')
            mask=data.inPixels;
        elseif isfield(data,'mask')
            mask=data.mask.trap;
        else
            mask=[];
            disp(['Mask not found in ' maskFilenames{ii}]);
        end
        
        
        
        %first setup the blank recordpatient info
        reportTable(ridx).patient=patientInfo{ii}.patient;
        reportTable(ridx).visit=patientInfo{ii}.visit;
        reportTable(ridx).site=patientInfo{ii}.site;
        reportTable(ridx).repeat=patientInfo{ii}.repeat;
        reportTable(ridx).meanDepth_mm=[];
        reportTable(ridx).meanThickness_mm=[];
        reportTable(ridx).area_mm2=[];
        reportTable(ridx).mtrpArea_mm2=[];
        reportTable(ridx).mtrpDepth_mm=[];
        reportTable(ridx).mtrpMajorAxisLength_mm=[];
        reportTable(ridx).mtrpMinorAxisLength_mm=[];
        reportTable(ridx).entropyAvg=[];
        reportTable(ridx).entropyArea_mm2=[];
        reportTable(ridx).depthOffset_mm=[];
        
        

        if ~isempty(mask)
            [upperTissueDepthMean_mm,lowerTissueDepthMean_mm,tissueThicknessMean_mm,upperTissueDepthStd_mm,lowerTissueDepthStd_mm,tissueThicknessStd_mm,tissueArea_mm2] = calcTissueWidth( mask,pel2mm );
            disp(maskFilenames{ii});
            disp(['Start depth/muscle width in mm are: ' num2str([upperTissueDepthMean_mm tissueThicknessMean_mm])]);
            
            reportTable(ridx).meanDepth_mm=upperTissueDepthMean_mm;
            reportTable(ridx).meanThickness_mm=tissueThicknessMean_mm;
            reportTable(ridx).area_mm2=tissueArea_mm2;
        end
        
        %No 50 column edge mask
        entropyFullfilename=fullfile(currentPath,maskfilenameFuncForEntroy(patientInfo{ii}.patient,patientInfo{ii}.visit,patientInfo{ii}.site,patientInfo{ii}.repeat));
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
        
        %This is only for the color doppler
        
        if isfield(data,'area_Gold') || isfield(data,'depthMTRP')
            %area_Gold (Trigger point area in cm2)
            %            cm^2=>mm^2  (10mm/1cm)^2=100mm^2/1cm^2
            %this will cause an error if both the fields are not defined.
            reportTable(ridx).mtrpArea_mm2=data.area_Gold*100;
            reportTable(ridx).mtrpDepth_mm=data.depthMTRP{1,2};
            reportTable(ridx).mtrpMajorAxisLength_mm=data.depthMTRP{2,2};
            reportTable(ridx).mtrpMinorAxisLength_mm=data.depthMTRP{3,2};
        elseif colorDopplerV1SpecialCase &&  ~isfield(data,'area_Gold') && ~isfield(data,'depthMTRP')
        
            alternateColorDopplerFullfilename=fullfile(currentPath,maskfilenameFuncColorDopplerV1SpecialCase(patientInfo{ii}.patient,patientInfo{ii}.visit,patientInfo{ii}.site,patientInfo{ii}.repeat));
            alternateData=load(alternateColorDopplerFullfilename);
            
            [upperTissueDepthMean_mm,lowerTissueDepthMean_mm,tissueThicknessMean_mm,upperTissueDepthStd_mm,lowerTissueDepthStd_mm,tissueThicknessStd_mm,tissueArea_mm2] = calcTissueWidth( alternateData.mask.trap,pel2mm );
            disp(maskFilenames{ii});
            disp(['Start depth/muscle width in mm are: ' num2str([upperTissueDepthMean_mm tissueThicknessMean_mm])]);
            
            reportTable(ridx).meanDepth_mm=upperTissueDepthMean_mm;
            reportTable(ridx).meanThickness_mm=tissueThicknessMean_mm;
            reportTable(ridx).area_mm2=tissueArea_mm2;
                        %area_Gold (Trigger point area in cm2)
            %            cm^2=>mm^2  (10mm/1cm)^2=100mm^2/1cm^2
            %this will cause an error if both the fields are not defined.
            reportTable(ridx).mtrpArea_mm2=alternateData.area_Gold*100;
            reportTable(ridx).mtrpDepth_mm=alternateData.depthMTRP{1,2};
            reportTable(ridx).mtrpMajorAxisLength_mm=alternateData.depthMTRP{2,2};
            reportTable(ridx).mtrpMinorAxisLength_mm=alternateData.depthMTRP{3,2};

        elseif colorDopplerV1SpecialCase
            error('This should never happen');
        else
            
        end
        
        if findDepthOffset
            depthInfoFilename=fullfile(currentPath,filenameDepthOffset(patientInfo{ii}.patient,patientInfo{ii}.visit,patientInfo{ii}.site,patientInfo{ii}.repeat));
            if exist(depthInfoFilename,'file')
                tmp=load(depthInfoFilename);
                isfield(tmp,'fileDirB8')
                
                [frame,header]=uread(tmp.fileDirB8,1);                
                
                [index] = find(frame(:,round(size(frame,2)/2),1)>0,1,'first');
                if header.ul(2)==header.ur(2)  && header.ul(2)==(index-1)
                    %do nothing
                else
                end
                
                %offset=(index-1)*scalefactor
                                
            else
            end
        end
        
        ridx=ridx+1;
    end
 
end

end

