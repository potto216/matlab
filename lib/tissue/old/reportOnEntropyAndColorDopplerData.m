clear;
close all;
% mat files (masks) about visit 1 and 3 of all subjects are in
bModeDatafilePathV1V3='E:\Users\dturo\MTrP_Analysis_Entropy_from001to078';
%
%What needs to be done is first read the muscle data and then form a
%spreadsheet from it.
repeatsToUse=[1];

% Spreadsheet for ColorDoppler images:
% Visit 1 data:
colorDopplerDatafilePathV1='C:\Users\dturo\Desktop\Murad\Area Color Doppler';
% Visit 3 data:
colorDopplerDatafilePathV3='C:\Users\dturo\Desktop\Murad\Area Color Doppler V3';
% In this folder there is also MTRP099. This is a fake case it is actually MTRP083 but I run a test on it
% I need those data as well.
if true
    reportTable=[];
    pel2mm=38/(475-15);
    reportTable.bmodeV1V3=loadMaskData(bModeDatafilePathV1V3,pel2mm);
    
    %conversion factor is pixel_side = 0.063 mm or pixel_area = 0.003969 mm^2
    pel2mm=0.063;
    reportTable.colorDopplerV1=loadMaskData(colorDopplerDatafilePathV1,pel2mm);
    
    %conversion factor is pixel_side = 0.063 mm or pixel_area = 0.003969 mm^2
    pel2mm=0.063;
    reportTable.colorDopplerV3=loadMaskData(colorDopplerDatafilePathV3,pel2mm);
end
%% Add build index
%% Build the joined table
joinFields={'patient','visit','site','repeat'};
joinedTable=[];
joinedRowIdx=1;

for ii=1:length(reportTable.bmodeV1V3)
    %loop through the tables to be joined and find the indices that match
    %and include those fields
    joinedTable(joinedRowIdx).patient=reportTable.bmodeV1V3(ii).patient;
    joinedTable(joinedRowIdx).visit=reportTable.bmodeV1V3(ii).visit;
    joinedTable(joinedRowIdx).site=reportTable.bmodeV1V3(ii).site;
    joinedTable(joinedRowIdx).repeat=reportTable.bmodeV1V3(ii).repeat;
    
    joinedTable(joinedRowIdx).bmodeV1V3.meanDepth_mm=reportTable.bmodeV1V3(ii).meanDepth_mm;
    joinedTable(joinedRowIdx).bmodeV1V3.meanThickness_mm=reportTable.bmodeV1V3(ii).meanThickness_mm;
    joinedTable(joinedRowIdx).bmodeV1V3.area_mm2=reportTable.bmodeV1V3(ii).area_mm2;
    
    joinedTable(joinedRowIdx).colorDopplerV1.meanDepth_mm=[];
    joinedTable(joinedRowIdx).colorDopplerV1.meanThickness_mm=[];
    joinedTable(joinedRowIdx).colorDopplerV1.area_mm2=[];
    
    joinedTable(joinedRowIdx).colorDopplerV3.meanDepth_mm=[];
    joinedTable(joinedRowIdx).colorDopplerV3.meanThickness_mm=[];
    joinedTable(joinedRowIdx).colorDopplerV3.area_mm2=[];
    
    %check to use equals or strcmpi
    for jj=1:length(reportTable.colorDopplerV1)
        if strcmp(joinedTable(joinedRowIdx).patient,reportTable.colorDopplerV1(jj).patient) && ...
                strcmp(joinedTable(joinedRowIdx).visit,reportTable.colorDopplerV1(jj).visit) && ...
                strcmp(joinedTable(joinedRowIdx).site,reportTable.colorDopplerV1(jj).site) && ...
                strcmp(joinedTable(joinedRowIdx).repeat,reportTable.colorDopplerV1(jj).repeat)
            
            joinedTable(joinedRowIdx).colorDopplerV1.meanDepth_mm=reportTable.colorDopplerV1(jj).meanDepth_mm;
            joinedTable(joinedRowIdx).colorDopplerV1.meanThickness_mm=reportTable.colorDopplerV1(jj).meanThickness_mm;
            joinedTable(joinedRowIdx).colorDopplerV1.area_mm2=reportTable.colorDopplerV1(jj).area_mm2;
            break;
        end
    end
    for jj=1:length(reportTable.colorDopplerV3)
        if strcmp(joinedTable(joinedRowIdx).patient,reportTable.colorDopplerV3(jj).patient) && ...
                strcmp(joinedTable(joinedRowIdx).visit,reportTable.colorDopplerV3(jj).visit) && ...
                strcmp(joinedTable(joinedRowIdx).site,reportTable.colorDopplerV3(jj).site) && ...
                strcmp(joinedTable(joinedRowIdx).repeat,reportTable.colorDopplerV3(jj).repeat)
            
            joinedTable(joinedRowIdx).colorDopplerV3.meanDepth_mm=reportTable.colorDopplerV3(jj).meanDepth_mm;
            joinedTable(joinedRowIdx).colorDopplerV3.meanThickness_mm=reportTable.colorDopplerV3(jj).meanThickness_mm;
            joinedTable(joinedRowIdx).colorDopplerV3.area_mm2=reportTable.colorDopplerV3(jj).area_mm2;
            break;
        end
    end
    joinedRowIdx=joinedRowIdx+1;
end

%% change datatype
for ii=1:length(joinedTable)
    joinedTable(ii).patient=str2num(joinedTable(ii).patient);
    joinedTable(ii).visit=str2num(joinedTable(ii).visit);
    joinedTable(ii).site=str2num(joinedTable(ii).site);
    joinedTable(ii).repeat=str2num(joinedTable(ii).repeat);
end

%% Now we need to do a pivot on the sites
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
        tmp.bmodeV1V3.meanDepth_mm=joinedTable(ii).bmodeV1V3.meanDepth_mm;
        tmp.bmodeV1V3.meanThickness_mm=joinedTable(ii).bmodeV1V3.meanThickness_mm;
        tmp.bmodeV1V3.area_mm2=joinedTable(ii).bmodeV1V3.area_mm2;
        
        tmp.colorDopplerV1.meanDepth_mm=joinedTable(ii).colorDopplerV1.meanDepth_mm;
        tmp.colorDopplerV1.meanThickness_mm=joinedTable(ii).colorDopplerV1.meanThickness_mm;
        tmp.colorDopplerV1.area_mm2=joinedTable(ii).colorDopplerV1.area_mm2;
        
        tmp.colorDopplerV3.meanDepth_mm=joinedTable(ii).colorDopplerV3.meanDepth_mm;
        tmp.colorDopplerV3.meanThickness_mm=joinedTable(ii).colorDopplerV3.meanThickness_mm;
        tmp.colorDopplerV3.area_mm2=joinedTable(ii).colorDopplerV3.area_mm2;
        
        if foundRepeat2
            tmp.bmodeV1V3.meanDepth_mm=[tmp.bmodeV1V3.meanDepth_mm joinedTable(repeat2Index).bmodeV1V3.meanDepth_mm];
            tmp.bmodeV1V3.meanThickness_mm=[tmp.bmodeV1V3.meanThickness_mm joinedTable(repeat2Index).bmodeV1V3.meanThickness_mm];
            tmp.bmodeV1V3.area_mm2=[tmp.bmodeV1V3.area_mm2 joinedTable(repeat2Index).bmodeV1V3.area_mm2];
            
            tmp.colorDopplerV1.meanDepth_mm=[tmp.colorDopplerV1.meanDepth_mm joinedTable(repeat2Index).colorDopplerV1.meanDepth_mm];
            tmp.colorDopplerV1.meanThickness_mm=[tmp.colorDopplerV1.meanThickness_mm joinedTable(repeat2Index).colorDopplerV1.meanThickness_mm];
            tmp.colorDopplerV1.area_mm2=[tmp.colorDopplerV1.area_mm2 joinedTable(repeat2Index).colorDopplerV1.area_mm2];
            
            tmp.colorDopplerV3.meanDepth_mm=[tmp.colorDopplerV3.meanDepth_mm joinedTable(repeat2Index).colorDopplerV3.meanDepth_mm];
            tmp.colorDopplerV3.meanThickness_mm=[tmp.colorDopplerV3.meanThickness_mm joinedTable(repeat2Index).colorDopplerV3.meanThickness_mm];
            tmp.colorDopplerV3.area_mm2=[tmp.colorDopplerV3.area_mm2 joinedTable(repeat2Index).colorDopplerV3.area_mm2];
        else
            %do nothing
        end
        
        
        joinedTable2(joinedRowIdx2).bmodeV1V3.meanDepth_mm=meanValid(tmp.bmodeV1V3.meanDepth_mm,repeatsToUse);
        joinedTable2(joinedRowIdx2).bmodeV1V3.meanThickness_mm=meanValid(tmp.bmodeV1V3.meanThickness_mm,repeatsToUse);
        joinedTable2(joinedRowIdx2).bmodeV1V3.area_mm2=meanValid(tmp.bmodeV1V3.area_mm2,repeatsToUse);
        
        joinedTable2(joinedRowIdx2).colorDopplerV1.meanDepth_mm=meanValid(tmp.colorDopplerV1.meanDepth_mm,repeatsToUse);
        joinedTable2(joinedRowIdx2).colorDopplerV1.meanThickness_mm=meanValid(tmp.colorDopplerV1.meanThickness_mm,repeatsToUse);
        joinedTable2(joinedRowIdx2).colorDopplerV1.area_mm2=meanValid(tmp.colorDopplerV1.area_mm2,repeatsToUse);
        
        joinedTable2(joinedRowIdx2).colorDopplerV3.meanDepth_mm=meanValid(tmp.colorDopplerV3.meanDepth_mm,repeatsToUse);
        joinedTable2(joinedRowIdx2).colorDopplerV3.meanThickness_mm=meanValid(tmp.colorDopplerV3.meanThickness_mm,repeatsToUse);
        joinedTable2(joinedRowIdx2).colorDopplerV3.area_mm2=meanValid(tmp.colorDopplerV3.area_mm2,repeatsToUse);
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
            joinedTable3(end).site(ss).bmodeV1V3.meanDepth_mm=[];
            joinedTable3(end).site(ss).bmodeV1V3.meanThickness_mm=[];
            joinedTable3(end).site(ss).bmodeV1V3.area_mm2=[];
            
            joinedTable3(end).site(ss).colorDopplerV1.meanDepth_mm=[];
            joinedTable3(end).site(ss).colorDopplerV1.meanThickness_mm=[];
            joinedTable3(end).site(ss).colorDopplerV1.area_mm2=[];
            
            joinedTable3(end).site(ss).colorDopplerV3.meanDepth_mm=[];
            joinedTable3(end).site(ss).colorDopplerV3.meanThickness_mm=[];
            joinedTable3(end).site(ss).colorDopplerV3.area_mm2=[];
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
        joinedTable3(foundIdx).site(joinedTable2(ii).site).bmodeV1V3.meanDepth_mm=joinedTable2(ii).bmodeV1V3.meanDepth_mm;
        joinedTable3(foundIdx).site(joinedTable2(ii).site).bmodeV1V3.meanThickness_mm=joinedTable2(ii).bmodeV1V3.meanThickness_mm;
        joinedTable3(foundIdx).site(joinedTable2(ii).site).bmodeV1V3.area_mm2=joinedTable2(ii).bmodeV1V3.area_mm2;
        
        joinedTable3(foundIdx).site(joinedTable2(ii).site).colorDopplerV1.meanDepth_mm=joinedTable2(ii).colorDopplerV1.meanDepth_mm;
        joinedTable3(foundIdx).site(joinedTable2(ii).site).colorDopplerV1.meanThickness_mm=joinedTable2(ii).colorDopplerV1.meanThickness_mm;
        joinedTable3(foundIdx).site(joinedTable2(ii).site).colorDopplerV1.area_mm2=joinedTable2(ii).colorDopplerV1.area_mm2;
        
        joinedTable3(foundIdx).site(joinedTable2(ii).site).colorDopplerV3.meanDepth_mm=joinedTable2(ii).colorDopplerV3.meanDepth_mm;
        joinedTable3(foundIdx).site(joinedTable2(ii).site).colorDopplerV3.meanThickness_mm=joinedTable2(ii).colorDopplerV3.meanThickness_mm;
        joinedTable3(foundIdx).site(joinedTable2(ii).site).colorDopplerV3.area_mm2=joinedTable2(ii).colorDopplerV3.area_mm2;
    end
    
end

disp('Completed join')
%% Create the report
reportGet={'@(x) x.patient','@(x) x.visit'};
d=cell(length(joinedTable3(1).site),3,3);
collectionType={'bmodeV1V3','colorDopplerV1','colorDopplerV3'}';
for ii=1:length(joinedTable3(1).site)
    for cc=1:length(collectionType)
        dd{ii,1,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.meanDepth_mm'];
        dd{ii,2,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.meanThickness_mm'];
        dd{ii,3,cc}= ['@(x) x.site(' num2str(ii) ').' collectionType{cc} '.area_mm2'];
    end
    
end

tableOutput=[reportGet(:); dd(:)]';
funcTableOutput=cellfun(@(x) {str2func(x)},tableOutput);
tableOutputV1=tableOutput;
tableOutputV3=tableOutput;

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
        end
    end
    
end

filename=['mtrpReportRepeats_' num2str(repeatsToUse)]
xlswrite(filename,tableOutputV1,'Visit1')
xlswrite(filename,tableOutputV3,'Visit3')