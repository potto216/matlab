clear all
close all



%% Run this block to create an RF movie
%Make sure the points to an rf file.
fullfilename='Z:\potto\filesToMove\S007\S007G0L1OA0MVIC_EXT4.rf';
movieBaseFilename='test'; %no extension is needed

dataBlockObj=DataBlockObj(fullfilename,@uread,'openArgs',{'frameFormatComplex',true});
dataBlockObj.open('cacheMethod','all');
processFunction=@(x) abs(x).^0.5;
dataBlockObj.newProcessStream('agentLab',processFunction, true);
dataBlockObj.image([30])
dataBlockObj.movie([],{[movieBaseFilename '.avi'],'w',5,{'avi', 'Uncompressed AVI'},false})



%% Move the demo file to a place
%copy_list	=	deppkg('demo_DataBlockObj.m',DEST)