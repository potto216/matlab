clear
close all


trialNameList={};
trialNameList{1}='MRUS005_V1_S1_T2';


tt=1
trialName=trialNameList{tt};
[trialData]=loadMetadata([trialName '.m']);



dataBlockObj=getCollection(trialData,'col_ultrasound_bmode');
%dataBlockObj=getCollection(trialData,'col_ultrasound_rf');
blockData=uint8(dataBlockObj.blockData);

im1 = blockData(:,:,1);
im2 = blockData(:,:,2);

%Calculates an optical flow for a sparse feature set using the iterative Lucas-Kanade method with pyramids
prevPts = cv.goodFeaturesToTrack(im1);
nextPts = cv.calcOpticalFlowPyrLK(im1,im2, prevPts,'MaxLevel',3,'WinSize',[11 11]);
cell2mat(prevPts')'-cell2mat(nextPts')'
nextPts = cv.calcOpticalFlowPyrLK(im1, im2, prevPts,'WinSize',11);

flow = cv.calcOpticalFlowFarneback(im1, im2,'WinSize',11);

%cv.calcOpticalFlowFarneback
%Computes a dense optical flow using the Gunnar Farneback's algorithm


[kpts1,descs1] = cv.SIFT(im1);
[kpts2,descs2] = cv.SIFT(im2);
matcher = cv.DescriptorMatcher('BruteForce');
matcher.add(descs1);
%matches = matcher.match(descs2);
matches = matcher.radiusMatch(descs2,12);
all(cellfun(@(x) isempty(x), matches))
im = cv.drawMatches(im1,kpts1,im2,kpts2,matches);
imshow(im);


detector = cv.FeatureDetector('SURF');
size(keypoints) = detector.detect(im1);

varargout = agentLab(dataBlockObj);

return
%%
close(varargout)
varargout = agentLab(dataBlockObj);