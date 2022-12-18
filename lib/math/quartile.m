function s=quartile(x)
% define data set
% x = [16, 22, 24, 24, 27, 28, 29, 30]';
Nx = size(x,1);

% compute mean
s.mx = mean(x);

% compute the standard deviation
s.sigma = std(x);

% compute the median
s.medianx = median(x);

% STEP 1 - rank the data
y = sort(x);

% compute 25th percentile (first quartile)
s.Q(1) = median(y(find(y<median(y))));

% compute 50th percentile (second quartile)
s.Q(2) = median(y);

% compute 75th percentile (third quartile)
s.Q(3) = median(y(find(y>median(y))));

% compute Interquartile Range (IQR)
s.IQR = s.Q(3)-s.Q(1);

% compute Semi Interquartile Deviation (SID)
% The importance and implication of the SID is that if you 
% start with the median and go 1 SID unit above it 
% and 1 SID unit below it, you should (normally) 
% account for 50% of the data in the original data set
s.SID = s.IQR/2;

% determine extreme Q1 outliers (e.g., x < Q1 - 3*IQR)
iy = find(y<s.Q(1)-3*s.IQR);
if length(iy)>0,
    s.outliersQ1 = y(iy);
else
    s.outliersQ1 = [];
end

% determine extreme Q3 outliers (e.g., x > Q1 + 3*IQR)
iy = find(y>s.Q(1)+3*s.IQR);
if length(iy)>0,
    s.outliersQ3 = y(iy);
else
    s.outliersQ3 = [];
end

% compute total number of outliers
Noutliers = length(s.outliersQ1)+length(s.outliersQ3);

% display results
if false
disp(['Mean:                                ',num2str(s.mx)]);
disp(['Standard Deviation:                  ',num2str(s.sigma)]);
disp(['Median:                              ',num2str(s.medianx)]);
disp(['25th Percentile:                     ',num2str(s.Q(1))]);
disp(['50th Percentile:                     ',num2str(s.Q(2))]);
disp(['75th Percentile:                     ',num2str(s.Q(3))]);
disp(['Semi Interquartile Deviation:        ',num2str(s.SID)]);
disp(['Number of outliers:                  ',num2str(Noutliers)]);
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Percentile Calculation Example
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % define percent
% kpercent = 75;
% 
% % STEP 1 - rank the data
% y = sort(x);
% 
% % STEP 2 - find k% (k /100) of the sample size, n.
% k = kpercent/100;
% result = k*Nx;
% 
% % STEP 3 - if this is an integer, add 0.5. If it isn't an integer round up.
% [N,D] = rat(k*Nx);
% if isequal(D,1),               % k*Nx is an integer, add 0.5
%     result = result+0.5;
% else                           % round up
%     result = round(result);
% end
% 
% % STEP 4 - Find the number in this position. If your depth ends 
% % in 0.5, then take the midpoint between the two numbers.
% [T,R] = strtok(num2str(result),'0.5');
% if strcmp(R,'.5'),
%     Qk = mean(y(result-0.5:result+0.5));
% else
%     Qk = y(result);
% end
% 
% % display result
% fprintf(1,['\nThe ',num2str(kpercent),'th percentile is ',num2str(Qk),'.\n\n']);

end