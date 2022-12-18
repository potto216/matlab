function histn(X_rc,M)
sz=49;

xi=linspace(min(X_rc(2,:)),max(X_rc(2,:)),sz);
yi=linspace(min(X_rc(1,:)),max(X_rc(1,:)),sz);

xr = interp1(xi,1:numel(xi),X_rc(2,:),'nearest')';
yr = interp1(yi,1:numel(yi),X_rc(1,:),'nearest')';

Z = accumarray([xr yr], 1, [sz sz]);
figure;
surf(xi,yi,Z)
if nargin==1
    return
end
%%
[gX,gY]=meshgrid(xi,yi);
%scale the track counts 
alphaM=zeros(size(M));
indToKeep=sub2ind(size(M),round(gY(:)),round(gX(:)));
alphaM(indToKeep)=Z(:);
alphaM=alphaM/max(alphaM(:));

MColor=repmat(M/max(M(:)),[1 1 3]);

im=MColor(:,:,1);
im(alphaM>0.35)=1;
MColor(:,:,1)=im;
%MColor(:,:,1)=MColor(:,:,1)+alphaM;
%MColor(:,:,1)=MColor(:,:,1)/max(max(MColor(:,:,1)));
figure; imagesc(MColor)