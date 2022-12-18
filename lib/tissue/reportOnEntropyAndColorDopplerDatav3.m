
% mat files (masks) about visit 1 and 3 of all subjects are in
bModeDatafilePathV1V3='E:\Users\dturo\MTrP_Analysis_Entropy_from001to087';
%
%What needs to be done is first read the muscle data and then form a
%spreadsheet from it.


% Spreadsheet for ColorDoppler images:
% Visit 1 data:
colorDopplerDatafilePathV1='C:\Users\dturo\Desktop\Murad\Area Color Doppler';
% Visit 3 data:
colorDopplerDatafilePathV3='C:\Users\dturo\Desktop\Murad\Area Color Doppler V3';

colorDopplerDatafilePathV4='C:\Users\dturo\Desktop\Murad\Area Color Doppler V4';
% In this folder there is also MTRP099. This is a fake case it is actually MTRP083 but I run a test on it
% I need those data as well.
patientExcludeList=45;

if true
    
    
    reportTable=[];
    pel2mm=38/(475-15);
    loadEntropy=true;
    findDepthOffset=false;
    isColorDoppler=false;
    reportTable.bmode=loadMaskData(bModeDatafilePathV1V3,pel2mm,loadEntropy,findDepthOffset,isColorDoppler,patientExcludeList);
    
    %conversion factor is pixel_side = 0.063 mm or pixel_area = 0.003969
    %mm^2 for scaling the b8's and pngs
    
    pel2mm=0.063;
    loadEntropy=false;
    findDepthOffset=true;
    isColorDoppler=true;
    colorDopplerV1=loadMaskData(colorDopplerDatafilePathV1,pel2mm,loadEntropy,findDepthOffset,isColorDoppler,patientExcludeList);
    if any(~arrayfun(@(x) x.visit==1,colorDopplerV1))
        error('These should only be visit 1 cases');
    end
    
    %conversion factor is pixel_side = 0.063 mm or pixel_area = 0.003969
    %mm^2 for png for scaling  for scaling the b8's and pngs
    pel2mm=0.063;
    loadEntropy=false;
    findDepthOffset=true;
    isColorDoppler=true;
    colorDopplerV3=loadMaskData(colorDopplerDatafilePathV3,pel2mm,loadEntropy,findDepthOffset,isColorDoppler,patientExcludeList);
    if any(~arrayfun(@(x) x.visit==3,colorDopplerV3))
        error('These should only be visit 3 cases');
    end
    
    %conversion factor is pixel_side = 0.063 mm or pixel_area = 0.003969
    %mm^2 for png for scaling  for scaling the b8's and pngs
    pel2mm=0.063;
    loadEntropy=false;
    findDepthOffset=true;
    isColorDoppler=true;
    colorDopplerV4=loadMaskData(colorDopplerDatafilePathV4,pel2mm,loadEntropy,findDepthOffset,isColorDoppler,patientExcludeList);
    if any(~arrayfun(@(x) x.visit==4,colorDopplerV4))
        error('These should only be visit 4 cases');
    end

    reportTable.colorDoppler=reshape([colorDopplerV1(:); colorDopplerV3(:); colorDopplerV4(:)],1,[]);
end

%bmodeKeyList=arrayfun(@(x) sprintf('p%d_v%d_s%d_r%d',x.patient,x.visit,x.site,x.repeat),reportTable.bmode,'UniformOutput',false);
bmodeKeyList=cell2mat(reshape(arrayfun(@(x) [x.patient x.visit x.site x.repeat],reportTable.bmode,'UniformOutput',false),[],1));
colorDopplerKeyList=cell2mat(reshape(arrayfun(@(x) [x.patient x.visit x.site x.repeat],reportTable.colorDoppler,'UniformOutput',false),[],1));
completeKeyList=unique([bmodeKeyList; colorDopplerKeyList],'rows');
%% Add build index
%% Build the joined table
joinedRowIdx=1;

joinOnFieldList={'patient','visit','site','repeat'};
groupByFieldList={'patient','visit','site'};
initValue=repmat({[]},1,length(joinOnFieldList));
joinOnFieldListStructInit={joinOnFieldList{:}; initValue{:}};

joinedTableEntryInit=struct(joinOnFieldListStructInit{:});
joinedTable=repmat(joinedTableEntryInit,length(reportTable.bmode),1);

bmodeFieldList={'meanDepth_mm','meanThickness_mm','area_mm2','entropyAvg','entropyArea_mm2'};
colorDopplerFieldList={'meanDepth_mm','meanThickness_mm','area_mm2','mtrpArea_mm2','mtrpDepth_mm','mtrpMajorAxisLength_mm','mtrpMinorAxisLength_mm',...
    'ratioArea','ratioAreaGeometricMean','varMTRP','varTRAP','ratioVAR','ratioVARGeometricMean','deltaPerPixelX_um','deltaPerPixelY_um'};


repeatFunc.bmode.meanDepth_mm=@(r1,r2) meanValid([r1.meanDepth_mm r2.meanDepth_mm],repeatsToUse);
repeatFunc.bmode.meanThickness_mm=@(r1,r2) meanValid([r1.meanThickness_mm r2.meanThickness_mm],repeatsToUse);
repeatFunc.bmode.area_mm2=@(r1,r2) meanValid([r1.area_mm2 r2.area_mm2],repeatsToUse);
repeatFunc.bmode.entropyAvg=@(r1,r2) meanValid([r1.entropyAvg r2.entropyAvg],repeatsToUse);
repeatFunc.bmode.entropyArea_mm2=@(r1,r2) meanValid([r1.entropyArea_mm2 r2.entropyArea_mm2],repeatsToUse);

repeatFunc.colorDoppler.meanDepth_mm=@(r1,r2) meanValid([r1.meanDepth_mm r2.meanDepth_mm],repeatsToUse);
repeatFunc.colorDoppler.meanThickness_mm=@(r1,r2) meanValid([r1.meanThickness_mm r2.meanThickness_mm],repeatsToUse);
repeatFunc.colorDoppler.area_mm2=@(r1,r2) meanValid([r1.area_mm2 r2.area_mm2],repeatsToUse);
repeatFunc.colorDoppler.mtrpArea_mm2=@(r1,r2) meanValid([r1.mtrpArea_mm2 r2.mtrpArea_mm2],repeatsToUse);
repeatFunc.colorDoppler.mtrpDepth_mm=@(r1,r2) meanValid([r1.mtrpDepth_mm r2.mtrpDepth_mm],repeatsToUse);
repeatFunc.colorDoppler.mtrpMajorAxisLength_mm=@(r1,r2) meanValid([r1.mtrpMajorAxisLength_mm r2.mtrpMajorAxisLength_mm],repeatsToUse);
repeatFunc.colorDoppler.mtrpMinorAxisLength_mm=@(r1,r2) meanValid([r1.mtrpMinorAxisLength_mm r2.mtrpMinorAxisLength_mm],repeatsToUse);
repeatFunc.colorDoppler.ratioArea=@(r1,r2) meanValid([r1.ratioArea r2.ratioArea],repeatsToUse);
repeatFunc.colorDoppler.ratioAreaGeometricMean=@(r1,r2) meanGeometricValid([r1.ratioArea r2.ratioArea],repeatsToUse);
repeatFunc.colorDoppler.varMTRP=@(r1,r2) meanValid([r1.varMTRP r2.varMTRP],repeatsToUse);
repeatFunc.colorDoppler.varTRAP=@(r1,r2) meanValid([r1.varTRAP r2.varTRAP],repeatsToUse);
repeatFunc.colorDoppler.ratioVAR=@(r1,r2) meanValid([r1.ratioVAR r2.ratioVAR],repeatsToUse);
repeatFunc.colorDoppler.ratioVARGeometricMean=@(r1,r2) meanGeometricValid([r1.ratioVAR r2.ratioVAR],repeatsToUse);
repeatFunc.colorDoppler.deltaPerPixelX_um=@(r1,r2) r1.deltaPerPixelX_um;
repeatFunc.colorDoppler.deltaPerPixelY_um=@(r1,r2) r1.deltaPerPixelY_um;

%ASSUMPTION: That bmode contains all of the sites that Color Doppler does

for ii=1:size(completeKeyList,1)
    %loop through the tables to be joined and find the indices that match
    %and include those fields
    joinedTable(joinedRowIdx).patient=completeKeyList(ii,1);
    joinedTable(joinedRowIdx).visit=completeKeyList(ii,2);
    joinedTable(joinedRowIdx).site=completeKeyList(ii,3);
    joinedTable(joinedRowIdx).repeat=completeKeyList(ii,4);
    
    %sets up the primary keys
    %joinedTable(joinedRowIdx)=structCopyFields(joinOnFieldList,joinedTable(joinedRowIdx),reportTable.bmode(ii));
    
    
    %joinedTable(joinedRowIdx).bmode=structCopyFields(bmodeFieldList,[],reportTable.bmode(ii));
    joinedTable(joinedRowIdx).bmode=structCopyFields(bmodeFieldList,[],[]);
    joinedTable(joinedRowIdx).colorDoppler=structCopyFields(colorDopplerFieldList,[],[]);
    
    foundIndexList=structArrayFind(joinOnFieldList,reportTable.colorDoppler,joinedTable(joinedRowIdx));
    if ~(isempty(foundIndexList) || length(foundIndexList)==1)
        warning('Too many indexes found for colorDoppler.  Using only the first one');
        joinedTable(joinedRowIdx).colorDoppler=structCopyFields(colorDopplerFieldList,[],reportTable.colorDoppler(foundIndexList(1)));
    elseif isempty(foundIndexList)
        joinedTable(joinedRowIdx).colorDoppler=structCopyFields(colorDopplerFieldList,[],[]);
    elseif length(foundIndexList)==1
        joinedTable(joinedRowIdx).colorDoppler=structCopyFields(colorDopplerFieldList,[],reportTable.colorDoppler(foundIndexList(1)));
    end
    
    
    foundIndexList=structArrayFind(joinOnFieldList,reportTable.bmode,joinedTable(joinedRowIdx));
    if ~(isempty(foundIndexList) || length(foundIndexList)==1)
        warning('Too many indexes found for bmode.  Using only the first one');
        joinedTable(joinedRowIdx).bmode=structCopyFields(bmodeFieldList,[],reportTable.bmode(foundIndexList(1)));
    elseif isempty(foundIndexList)
        joinedTable(joinedRowIdx).bmode=structCopyFields(bmodeFieldList,[],[]);
    elseif length(foundIndexList)==1
        joinedTable(joinedRowIdx).bmode=structCopyFields(bmodeFieldList,[],reportTable.bmode(foundIndexList(1)));
    end
    
    
    joinedRowIdx=joinedRowIdx+1;
    disp(['Joining Index ' num2str(joinedRowIdx)]);
end



%% Now we need to group the repeats
joinedTable2=[];
joinedRowIdx2=1;
for ii=1:length(joinedTable)
    if joinedTable(ii).repeat==1
        
        %Look for the repeat 2
        
        for jj=1:length(joinedTable)
            repeat2Index=-1;
            foundRepeat2=false;
            if joinedTable(ii).patient==joinedTable(jj).patient && ...
                    joinedTable(ii).visit==joinedTable(jj).visit && ...
                    joinedTable(ii).site==joinedTable(jj).site && ...
                    joinedTable(ii).repeat==1 && joinedTable(jj).repeat==2
                foundRepeat2=true;
                repeat2Index=jj;
                break;
            end
        end
        
        
        joinedTable2(joinedRowIdx2).patient=joinedTable(ii).patient;
        joinedTable2(joinedRowIdx2).visit=joinedTable(ii).visit;
        joinedTable2(joinedRowIdx2).site=joinedTable(ii).site;
        
        %load in repeat 1
        repeat1=joinedTable(ii);
        
        if foundRepeat2
            repeat2=joinedTable(repeat2Index);
        else
            repeat2=[];
            repeat2.bmode=structCopyFields(bmodeFieldList,[],[]);
            repeat2.colorDoppler=structCopyFields(colorDopplerFieldList,[],[]);
            %do nothing
        end
        
        fieldnameList=fieldnames(repeatFunc.bmode);
        for ff=1:length(fieldnameList)
            joinedTable2(joinedRowIdx2).bmode.(fieldnameList{ff}) = ...
                repeatFunc.bmode.(fieldnameList{ff})(repeat1.bmode,repeat2.bmode);
        end
        
        fieldnameList=fieldnames(repeatFunc.colorDoppler);
        for ff=1:length(fieldnameList)
            joinedTable2(joinedRowIdx2).colorDoppler.(fieldnameList{ff}) = ...
                repeatFunc.colorDoppler.(fieldnameList{ff})(repeat1.colorDoppler,repeat2.colorDoppler);
        end
        
        %
        joinedRowIdx2=joinedRowIdx2+1;
        
    elseif joinedTable(ii).repeat==2
        %don't do anything only process on the first one
        continue;
    else
        error(['Unsupported repeat value of ' num2str(joinedTable(ii).repeat)]);
    end
end

%% perform the pivot on the data
joinedTable3=[];
for ii=1:length(joinedTable2)
    
    %see if the patient has already been entered
    foundIdx=[];
    for jj=1:length(joinedTable3)
        if joinedTable3(jj).patient==joinedTable2(ii).patient && ...
                joinedTable3(jj).visit==joinedTable2(ii).visit
            foundIdx=jj;
            break;
        end
    end
    
    if isempty(foundIdx)
        joinedTable3(end+1).patient=joinedTable2(ii).patient;
        joinedTable3(end).visit=joinedTable2(ii).visit;
        
        for ss=1:4
            joinedTable3(end).site(ss).bmode=structCopyFields(bmodeFieldList,[],[]);
            joinedTable3(end).site(ss).colorDoppler=structCopyFields(colorDopplerFieldList,[],[]);
        end
        
        
        foundIdx=length(joinedTable3);
    else
        %do nothing
    end
    
    if foundIdx>length(joinedTable3)
        error('Found index is too large.');
    else
        if joinedTable3(foundIdx).patient~=joinedTable2(ii).patient || ...
                joinedTable3(foundIdx).visit~=joinedTable2(ii).visit
            error('The patient, visit does not match');
        end
        joinedTable3(foundIdx).site(joinedTable2(ii).site).bmode=joinedTable2(ii).bmode;
        
        joinedTable3(foundIdx).site(joinedTable2(ii).site).colorDoppler=joinedTable2(ii).colorDoppler;
    end
    
end

disp('Completed join')
%% Create the report
reportGet={'@(x) x.patient','@(x) x.visit'};
dd=cell(length(joinedTable3(1).site),11,3);
validDD=false(length(joinedTable3(1).site),11,3);
collectionType={'bmode','colorDoppler'}';
for ii=1:length(joinedTable3(1).site)
    for cc=1:length(collectionType)
        dd{ii,1,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.meanDepth_mm'];
        dd{ii,2,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.meanThickness_mm'];
        dd{ii,3,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.area_mm2'];
        dd{ii,4,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.mtrpArea_mm2'];
        dd{ii,5,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.mtrpDepth_mm'];
        dd{ii,6,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.mtrpMajorAxisLength_mm'];
        dd{ii,7,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.mtrpMinorAxisLength_mm'];
        dd{ii,8,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.entropyAvg'];
        dd{ii,9,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.entropyArea_mm2'];
        dd{ii,10,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.ratioArea'];
        dd{ii,11,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.ratioAreaGeometricMean'];
        dd{ii,12,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.varMTRP'];
        dd{ii,13,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.varTRAP'];
        dd{ii,14,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.ratioVAR'];
        dd{ii,15,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.ratioVARGeometricMean'];
        
        switch(collectionType{cc})
            case 'bmode'
                validDD(ii,1,cc)=true;
                validDD(ii,2,cc)=true;
                validDD(ii,3,cc)=true;
                validDD(ii,8,cc)=true;
                validDD(ii,9,cc)=true;
                
            case 'colorDoppler'
                validDD(ii,1,cc)=true;
                validDD(ii,2,cc)=true;
                validDD(ii,3,cc)=true;
                validDD(ii,4,cc)=true;
                validDD(ii,5,cc)=true;
                validDD(ii,6,cc)=true;
                validDD(ii,7,cc)=true;
                validDD(ii,10,cc)=true;
                validDD(ii,11,cc)=true;
                validDD(ii,12,cc)=true;
                validDD(ii,13,cc)=true;
                validDD(ii,14,cc)=true;
                validDD(ii,15,cc)=true;
                
            otherwise
                error('Unsupport collection');
        end
        
    end
    
end
dd=dd(validDD);
tableOutput=[reportGet(:); dd(:)]';
funcTableOutput=cellfun(@(x) {str2func(x)},tableOutput);
tableOutputV1=tableOutput;
tableOutputV3=tableOutput;
tableOutputV4=tableOutput;

for ii=1:length(joinedTable3)
    
    for ff=1:length(funcTableOutput)
        if joinedTable3(ii).visit==1
            if ff==1
                tableOutputV1{end+1,ff}=funcTableOutput{ff}(joinedTable3(ii));
            else
                tableOutputV1{end,ff}=funcTableOutput{ff}(joinedTable3(ii));
            end
        elseif joinedTable3(ii).visit==3
            if ff==1
                tableOutputV3{end+1,ff}=funcTableOutput{ff}(joinedTable3(ii));
            else
                tableOutputV3{end,ff}=funcTableOutput{ff}(joinedTable3(ii));
            end
        elseif joinedTable3(ii).visit==4
            if ff==1
                tableOutputV4{end+1,ff}=funcTableOutput{ff}(joinedTable3(ii));
            else
                tableOutputV4{end,ff}=funcTableOutput{ff}(joinedTable3(ii));
            end
            
        end
    end
    
end

filename=strrep(['mtrpReportRepeats_' num2str(repeatsToUse)],' ','_');
xlswrite(filename,tableOutputV1,'Visit1')
xlswrite(filename,tableOutputV3,'Visit3')
xlswrite(filename,tableOutputV4,'Visit4')
finalData=joinedTable3;
save([filename '.mat'],'finalData');