maskFilenames=dirPlus('C:\Users\dturo\Desktop\Murad\Area Color Doppler\*_mask.mat','recursive',true);



%format: R:\potto\data\MTrP_Analysis_Images_from50to78\MTRP059\Case59_visit1_site1_repeat1_mask_debug.mat
maskFilenames=flattenCell(maskFilenames);
%format: C:\Users\dturo\Desktop\Murad\Area Color Doppler\MTRP038\13-13-07_mask.mat
patientInfo=cellfun(@(x) regexp( x, '(?<patient>MTRP\d+)\\(?<filename>\d{2}-\d{2}-\d{2})_mask\.mat$','names'),maskFilenames,'UniformOutput',false);

regionMark = @(x) [find(x,1,'first') find(x,1,'last')]';

pel2mm=38/(475-15);

table={'Patient','Filename','Mean Top Depth(mm)','Std Top Depth(mm)','Mean Bottom Depth(mm)','Std Bottom Depth(mm)','Mean Width(mm)','Std Width(mm)','Area (mm^2)'};
for ii=1:length(maskFilenames)
    
    
    if ~isempty(patientInfo{ii})
        data=load(maskFilenames{ii});
        if isfield(data,'inPixels')
            mask=data.inPixels;
        else
            mask=data.mask.trap;
        end
        
        if isempty(mask)
            table{end+1,1}='';
            table{end,2}='';
            table{end,3}='';
            table{end,4}='';
            table{end,5}='';
            table{end,6}='';
            table{end,7}='';
            table{end,8}='';
            table{end,9}='';
            
        else
            %trim the mask at the edges
            mask(:,1:50)=0;
            mask(:,end:(end-(50-1)))=0;
            
            
            columnMark=any(mask,1);
            %columnBounds=regionMark(columnMark);
            columnValid=find(columnMark);
            columnStartEnd_idx=colvecfun(@(x) regionMark(x),mask(:,columnValid));
            columnWidth=diff(columnStartEnd_idx,1,1);
            if false
                %% debug code
                figure;
                subplot(3,1,[1 2])
                imagesc(mask)
                hold on
                plot(columnValid,columnStartEnd_idx(1,:),'go');
                hold on
                plot(columnValid,columnStartEnd_idx(2,:),'go');
                
                subplot(3,1,3)
                plot(columnWidth)
            end
            
            meanDepth_mm=mean(columnStartEnd_idx,2)*pel2mm;
            meanWidth_mm=mean(columnWidth,2)*pel2mm;
            stdDepth_mm=std(columnStartEnd_idx,0,2)*pel2mm;
            stdWidth_mm=std(columnWidth,0,2)*pel2mm;
            area_mm2=sum(mask(:))*pel2mm^2;
            
            disp(maskFilenames{ii});
            disp(['Start/stop depth in mm are: ' num2str(meanDepth_mm')])
            table{end+1,1}=patientInfo{ii}.patient;
            table{end,2}=['''' patientInfo{ii}.filename];
            table{end,3}=meanDepth_mm(1);
            table{end,4}=stdDepth_mm(1);
            table{end,5}=meanDepth_mm(2);
            table{end,6}=stdDepth_mm(2);
            table{end,7}=meanWidth_mm;
            table{end,8}=stdWidth_mm;
            table{end,9}=area_mm2;            
            
        end
        
    end
end


xlswrite('markMeasurementsManual.xls',table)