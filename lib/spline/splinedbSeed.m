%This file is an example of showing how the splines were first created and
%saved.

splineData(1).controlpt.x=[3.5968;19.523;42.8226;69.6613;93.5507;122.159;];
splineData(1).controlpt.y=[731.845;783.5409;792.6637;765.2953;692.3129;598.0439;];
splineData(1).name='spline 1';
splineData(1).tag='good';
save('ZH2Trial33_Spline.mat','splineData');

splineData(1).controlpt.x=[5.0714;15.9839;33.3848;60.2235;80.8687;107.1175;126.5829;];
splineData(1).controlpt.y=[716.6404;765.2953;780.5;765.2953;725.7632;652.7807;588.9211;];
splineData(1).name='spline 1';
splineData(1).tag='okay';
save('ZH2Trial34_Spline.mat','splineData');

splineData(1).controlpt.x=[9.7903; 36.9240; 71.4309;  103.2834;  126.5829;];  %case 34
splineData(1).controlpt.y=[728.8041; 774.4181; 768.3363; 695.3538; 604.1257;];
splineData(1).name='spline 1';
splineData(1).tag='fine';
save('ZH2Trial35_Spline.mat','splineData');