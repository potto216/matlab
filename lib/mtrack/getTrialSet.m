function [ trialNameList,activeProcessStreamIndexList ] = getTrialSet( trialSetName )
%GETTRIALSET Summary of this function goes here_
%   Detailed explanation goes here
switch(trialSetName)
    case 'S3_BMode'
        %This collect has all the simultaneous collects
        trialNameList={};
        
        trialNameList{end+1}='MRUS003_V1_S1_T1';
        trialNameList{end+1}='MRUS003_V1_S1_T2';
        trialNameList{end+1}='MRUS003_V1_S1_T6';        
        activeProcessStreamIndexList=1*ones(size(trialNameList));    
    case 'S3_RF'
        %This collect has all the simultaneous collects
        trialNameList={};
        
        trialNameList{end+1}='MRUS003_V1_S1_T1';
        trialNameList{end+1}='MRUS003_V1_S1_T2';
        trialNameList{end+1}='MRUS003_V1_S1_T6';        
        activeProcessStreamIndexList=4*ones(size(trialNameList));       
    case 'S3_RF_P2'
        %This collect has all the simultaneous collects
        trialNameList={};
        
        trialNameList{end+1}='MRUS003_V1_S1_T1_P2';
        activeProcessStreamIndexList=4*ones(size(trialNameList));       
        
    case 'AllSet_BMode'
        trialNameList={};
        trialNameList{end+1}='MRUS003_V1_S1_T1';
        trialNameList{end+1}='MRUS003_V1_S1_T2';
        trialNameList{end+1}='MRUS003_V1_S1_T6';    
        
        trialNameList{end+1}='MRUS004_V1_S1_T1';
        trialNameList{end+1}='MRUS004_V1_S1_T2';
        trialNameList{end+1}='MRUS004_V1_S1_T3';
        trialNameList{end+1}='MRUS004_V1_S1_T4';
        %points in one of the frames.
        
        
        trialNameList{end+1}='MRUS005_V1_S1_T1';
        trialNameList{end+1}='MRUS005_V1_S1_T2';
        trialNameList{end+1}='MRUS005_V1_S1_T3';
        trialNameList{end+1}='MRUS005_V1_S1_T4';
        
        
        trialNameList{end+1}='MRUS006_V1_S1_T1';
        trialNameList{end+1}='MRUS006_V1_S1_T2';
        trialNameList{end+1}='MRUS006_V1_S1_T3';
        trialNameList{end+1}='MRUS006_V1_S1_T4';
        activeProcessStreamIndexList=1*ones(size(trialNameList));
    
    
    case 'Set_BModeRF_Simultaneous_RunBmode'
        %This collect has all the simultaneous collects
        trialNameList={};
        
         trialNameList{end+1}='MRUS004_V1_S1_T1';
         trialNameList{end+1}='MRUS004_V1_S1_T2';
        trialNameList{end+1}='MRUS005_V1_S1_T1';        
        trialNameList{end+1}='MRUS005_V1_S1_T2';        
        trialNameList{end+1}='MRUS006_V1_S1_T1';        
        activeProcessStreamIndexList=1*ones(size(trialNameList));
    case 'Set_BModeRF_Simultaneous_RunRF'
        %This collect has all the simultaneous collects
        trialNameList={};
        
        trialNameList{end+1}='MRUS004_V1_S1_T1';
        trialNameList{end+1}='MRUS004_V1_S1_T2';
        trialNameList{end+1}='MRUS005_V1_S1_T1';        
        trialNameList{end+1}='MRUS005_V1_S1_T2';        
        trialNameList{end+1}='MRUS006_V1_S1_T1';        
        activeProcessStreamIndexList=4*ones(size(trialNameList));
        
        
    case 'Set_RunRF'
        %This collect has all the rf collects
        trialNameList={};
        trialNameList{end+1}='MRUS003_V1_S1_T1';
        trialNameList{end+1}='MRUS003_V1_S1_T2';
        trialNameList{end+1}='MRUS003_V1_S1_T3';
        trialNameList{end+1}='MRUS003_V1_S1_T4';
        trialNameList{end+1}='MRUS003_V1_S1_T5';        
        trialNameList{end+1}='MRUS003_V1_S1_T6';
        
        trialNameList{end+1}='MRUS004_V1_S1_T1';
        trialNameList{end+1}='MRUS004_V1_S1_T2';
        trialNameList{end+1}='MRUS004_V1_S1_T5';        
        
        trialNameList{end+1}='MRUS005_V1_S1_T1';        
        trialNameList{end+1}='MRUS005_V1_S1_T2';        
        trialNameList{end+1}='MRUS005_V1_S1_T5';
        
        trialNameList{end+1}='MRUS006_V1_S1_T1';        
        trialNameList{end+1}='MRUS006_V1_S1_T5';
        
        activeProcessStreamIndexList=repmat({'standardRF'},length(trialNameList),1);
    case 'Set_NewRF'
        %This collect has all the simultaneous collects
        trialNameList={'MRUS007_V1_S1_T3'};
        activeProcessStreamIndexList=4*ones(size(trialNameList));      
    case 'Set_NewBMode'
        %This collect has all the simultaneous collects
        trialNameList={'MRUS007_V1_S1_T2'};
        activeProcessStreamIndexList=1*ones(size(trialNameList));              
    case 'Set_Phantom_Projection'
        trialNameList={};
        
        trialNameList{end+1}='rectusFemoris_phantom_linearMotion_fascicle';
        activeProcessStreamIndexList=3*ones(size(trialNameList)); %3 is projection
    case 'Set_Phantom_FieldII'
        trialNameList={};
        
        trialNameList{end+1}='rectusFemoris_phantom_linearMotion_fascicle';
        activeProcessStreamIndexList=2*ones(size(trialNameList)); %3 is projection        
    otherwise
        error(['Unsupported set of ' trialSetName]);
end



end

