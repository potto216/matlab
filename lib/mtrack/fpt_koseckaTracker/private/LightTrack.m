function  [EstA,EstB,EstLambda,Estc0,F0] = ...
LightTrack(I,J,Pos,A0,B0,lambda,c0,good)
% Light Shi-Tomasi algorithm
% Implemented by Hailin Jin
% and Paolo Favaro
% UCLA Vision Lab
% Last updated 11/02/2000
% It performs an alignment between two
% image patches on planes subject to
% a rigid motion

% The image model is of a slanted plane
% Estimation of the scene parameters is
% performed using Shi-Tomasi model (affine
% transformation)

% Patch coordinates
global MaxIterationNumber;
global STDimX STDimY;
[STY,STX] = meshgrid(-STDimX:STDimX,-STDimY:STDimY);

[Jy,Jx] = gradient(J);

% the vector u is so composed:
% [a11 a12 a21 a22 b1 b2]

N = length(good);

EstA = zeros(4,N);
EstB = zeros(2,N);
EstLambda = ones(N,1);
Estc0 = zeros(N,1);
F0 = zeros(N,1);
FF0 = 0;

for fi = 1:N

  if good(fi),
     
    PosLeft = Pos(:,fi);
    
    u = [A0(:,fi);B0(:,fi);lambda(fi);c0(fi)];
    ubest= u;
    PosLeft = Pos(:,fi);
    
    X = STX + PosLeft(1);
    Y = STY + PosLeft(2);
    
    STPI = Interpolate(I,X,Y);

    for ii = 1:MaxIterationNumber,
      
      fprintf('.');
      
      dFdu = zeros(8,1);
      T = zeros(8,8);
      
      A = [u(1),u(2);u(3),u(4)];
      B = u(5:6);
      lmbd = u(7);
      c00 = u(8);
       
      newX = A(1,1)*STX + A(1,2)*STY + B(1) + PosLeft(1);
      newY = A(2,1)*STX + A(2,2)*STY + B(2) + PosLeft(2);

      PJ  = Interpolate(J,newX,newY);
      
      
      Gx  = Interpolate(Jx,newX,newY);
      Gy  = Interpolate(Jy,newX,newY);

      Delta = STPI-(lmbd*PJ+c00);
       
      %show the patches
      %ShowPatches(STPI,PJ,Delta);
       
      for i = 1:2*STDimX+1,
	for j = 1:2*STDimY+1,
	  
	  x = STX(i,j);
	  y = STY(i,j);
	  
	  % compute F'
	  %dydA = [x y 0 0;0 0 x y];
	  %dydA = dABdA(A,[STX(i,j);STY(i,j)]);
	  %dydB = eye(2);
	  
	  % dydu
	  %dydu = [dydA dydB];
	  dydu = [x y 0 0 1 0;
		  0 0 x y 0 1];
	  
	  % gradient of J
	  GJ = [Gx(i,j) Gy(i,j)];
	  dIdu = lmbd*GJ*dydu;
	  % integrate F'
	  ddduu = [dIdu';PJ(i,j);1];
	  dFdu = dFdu+Delta(i,j)*ddduu;
	  T = T+ddduu*ddduu';
	  
	end;
      end;
      
      if any(any(isnan(T)|isinf(T)))
%	keyboard
	ubest = u;
	break
      end
      
      u = u+pinv(T)*dFdu;

      FF0(ii) = sum(sum(Delta.^2));
      
      if ii>1
	if FF0(ii)<FF0(ii-1)
	  ubest = u;
	else
	  FF0 = FF0(1:ii-1);
	  break
	end
      end
      
      if ii>1,
	if abs(FF0(ii-1)-FF0(ii))/FF0(ii-1)<0.001,
	  break;
	end;
      end;
    end;
%    figure(9); plot(FF0);
    
    u = ubest;
    
    % the current estimate is in u
    A = [u(1),u(2);u(3),u(4)];
    B = u(5:6);
    lmbd = u(7);
    c00 = u(8);
    
    newX = A(1,1)*STX + A(1,2)*STY + B(1) + PosLeft(1);
    newY = A(2,1)*STX + A(2,2)*STY + B(2) + PosLeft(2);
    
    PJ  = lmbd*Interpolate(J,newX,newY)+c00;
    
    Mean = sum(sum(STPI))/((2*STDimX+1)*(2*STDimY+1));
    Variance = sum(sum((STPI-Mean).^2))/((2*STDimX+1)*(2*STDimY+1));

    %NormI = sum(sum(STPI));
    %NormJ = sum(sum(PJ));
    
    F0(fi) = sqrt(sum(sum((PJ-STPI).^2))/((2*STDimX+1)*(2*STDimY+1)))/Variance;
    EstA(:,fi) = u(1:4);
    EstB(:,fi) = u(5:6);
    EstLambda(fi) = u(7);
    Estc0(fi) = u(8);
    
    fprintf('\n');
  end;
end;

