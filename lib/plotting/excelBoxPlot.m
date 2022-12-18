function excelBoxPlot(viewsMethodResults,viewGroupName,patientMethods,trialDataResultsCartesianCMMFilenameXLS,sheetName,plotXLabel,plotYLabel,plotTitle,viewsSortMetric,viewsSortMetricCombineFunction,tName)


patientFields=reshape([repmat({'XScatter';'Xbar'},1,length(patientMethods));patientMethods(:)'],1,[]);

[patientNameIndexMapList,patientNameList]=grp2idx(viewGroupName);


%either sort on a metric or use normal ordering
if ~isempty(viewsSortMetric)
    metricGrouped = grpstats(viewsSortMetric,patientNameIndexMapList,viewsSortMetricCombineFunction);
    [sortedMetricGroupedValues,patientOrderInTable]=sort(metricGrouped);
else

    patientOrderInTable=1:length(patientNameList);
end

%% Build the spreadsheet

row.sortMethod = 1;
row.mean = 2;
row.stdev = 3;
row.methodName = 4;
row.patientName = 5;
row.dataElementCount = 6;
row.maxRowUsed=row.dataElementCount;

column.key=1;
column.value=2;
column.p1XScatter=3;
column.p1Xbar=4;
column.p1CartesianVsMotionCorr=5;
column.p1CmmVsMotionCorr=6;


spreadSheetHeaderLine=row.maxRowUsed+1;
spreadSheetDataStartLine=spreadSheetHeaderLine+1;
spreadSheet={};

patientHeaders=reshape(cellfunkron(@(x,y) [ y(:)' x(:)'],patientFields,tName(patientNameList(patientOrderInTable))),1,[]);

spreadSheet(spreadSheetHeaderLine,1:(2+length(patientHeaders)))={'Key','Value',patientHeaders{:}}; %#ok<CCAT>

azList=num2cell(('A':'Z'));
spreadsheetColumnHeader=[azList reshape(cellfunkron(@(x,y) [ y x],azList,azList),1,[])];



%First write the key value pairs
spreadSheetDataLine=spreadSheetDataStartLine;

spreadSheet{spreadSheetDataLine,column.key}='totalMethods';
spreadSheet{spreadSheetDataLine,column.value}=length(patientMethods);
spreadSheetDataLine=spreadSheetDataLine+1;

 
spreadSheet{spreadSheetDataLine,column.key}='totalPatients';
spreadSheet{spreadSheetDataLine,column.value}=length(patientNameList);
spreadSheetDataLine=spreadSheetDataLine+1;

spreadSheet{spreadSheetDataLine,column.key}='plotXLabel';
spreadSheet{spreadSheetDataLine,column.value}=plotXLabel;
spreadSheetDataLine=spreadSheetDataLine+1;

spreadSheet{spreadSheetDataLine,column.key}='plotYLabel';
spreadSheet{spreadSheetDataLine,column.value}=plotYLabel;
spreadSheetDataLine=spreadSheetDataLine+1;

spreadSheet{spreadSheetDataLine,column.key}='plotTitle';
spreadSheet{spreadSheetDataLine,column.value}=plotTitle;



switch(length(patientMethods));
    case 2
        scatterOffset=[-0.15 0.15];
   case 3
       scatterOffset=[-0.22 0 0.22];
    otherwise
        error(['Method count of ' num2str(length(patientMethods)) ' is not supported and needs to be added.']);
end


%% Now Write the patient info
trialCount=zeros(length(patientNameList),1);
viewPatientNameList={};
for ii=1:length(patientNameList)
    
    spreadSheetDataStartLine=spreadSheetHeaderLine+1;
    viewPatientIndex=(patientNameIndexMapList==patientOrderInTable(ii));
    viewPatientNameList{ii}=patientNameList{patientOrderInTable(ii)};
    patientDataBlock=[];
    trialCount(ii)=sum(viewPatientIndex);
    for mm=1:size(viewsMethodResults,2)
            yData=viewsMethodResults(viewPatientIndex,mm);
            scatterX=repmat(ii+scatterOffset(mm),length(yData),1);
            barX=repmat(ii,length(yData),1);
            patientDataBlock=[patientDataBlock scatterX barX yData];             %#ok<AGROW>
    end
    currentPatientStartColumn=column.p1XScatter+(ii-1)*length(patientFields);
        
    spreadSheet(((spreadSheetHeaderLine+1):(spreadSheetHeaderLine+1+size(patientDataBlock,1)-1)), ...
        ((currentPatientStartColumn):(currentPatientStartColumn+size(patientDataBlock,2)-1)))= num2cell(patientDataBlock); %#ok<AGROW> %mat2cell(patientDataBlock,ones(size(patientDataBlock,1),1),ones(1,size(patientDataBlock,2)));
    
  
end

viewPatientNameList=viewPatientNameList(:);
if ~all(size(viewPatientNameList)==size(patientNameList))
    error('viewPatientNameList should equal patientNameList');
end

colRange=column.p1XScatter:size(spreadSheet,2);
rowRange=[spreadSheetDataStartLine size(spreadSheet,1)];

rangeData=cellfunkron(@(x,y) [ x num2str(y)],spreadsheetColumnHeader(colRange),num2cell(rowRange));

spreadSheet{row.sortMethod,1}=['Sort by ' func2str(viewsSortMetricCombineFunction)];
spreadSheet(row.sortMethod,colRange)= num2cell(reshape(rot90(repmat(sortedMetricGroupedValues,1,length(patientFields))),1,[]));

spreadSheet{row.stdev,1}='Stdev';
spreadSheet(row.stdev,colRange)=cellfun(@(x,y) ['=STDEV(' x ':' y ')'],rangeData(:,1),rangeData(:,2),'UniformOutput',false);

spreadSheet{row.mean,1}='Average';
spreadSheet(row.mean,colRange)=cellfun(@(x,y) ['=AVERAGE(' x ':' y ')'],rangeData(:,1),rangeData(:,2),'UniformOutput',false);


spreadSheet{row.methodName,1}='MethodName';
spreadSheet(row.methodName,colRange)=repmat(patientFields,1,length(viewPatientNameList));

spreadSheet{row.patientName,1}='PatientName';
spreadSheet(row.patientName,colRange)=tName(reshape(rot90(repmat(viewPatientNameList,1,length(patientFields))),1,[]));

spreadSheet{row.dataElementCount,1}='dataElementCount';
spreadSheet(row.dataElementCount,colRange)=num2cell(reshape(rot90(repmat(trialCount,1,length(patientFields))),1,[]));


xlswrite(trialDataResultsCartesianCMMFilenameXLS,spreadSheet,sheetName);
