function [ energyInternal, energyExternal, energyExternalAdjusted ] = optFun(  v_rc, imGradientMag,energyBand,d,M )

   %
       
   energyBand=[energyBand(1) energyBand energyBand(end)];
   
    vDelta_rc=(diff(v_rc,1,2));
    vDeltaAbs_rc=abs(vDelta_rc);
    
    b1=1;
    %valid vertics range from [v(2),v(end)]
    
    energyInternalElasticity=b1*(sqrt(sum(vDeltaAbs_rc.^2,1))-repmat(d,1,size(vDeltaAbs_rc,2)));
    
    a1=1;
    %valid vertics range from [v(2),v(end-1)]
    energyInternalStiffness=a1*(1-colvecfun(@(vp,vn) vp'*vn/sqrt((vp'*vp)*(vn'*vn)),vDeltaAbs_rc(:,1:end-1),vDeltaAbs_rc(:,2:end)));
    energyInternal=[energyInternalStiffness(1) energyInternalStiffness energyInternalStiffness(end)]+[energyInternalElasticity(1) energyInternalElasticity];
    
    vLimitAxis1_rc=min(max(round(v_rc(1,:)),1),size(imGradientMag,1));
    vLimitAxis2_rc=min(max(round(v_rc(2,:)),1),size(imGradientMag,2));
    
    energyExternal= 1-imGradientMag(sub2ind(size(imGradientMag),vLimitAxis1_rc,vLimitAxis2_rc))/M;
   
    
    energyExternalAdjusted=energyBand.*energyExternal;
end

