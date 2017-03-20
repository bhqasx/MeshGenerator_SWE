function [zb2]=InterpNearestPoints(p1,zb1,p2,k)
%find k nearst points to each node in p2 from p1 and use 
%their zb values tointerplate
%zb is allowed to have more than one colums

if nargin==3
    k=3;
end
wt=zeros(1,k);      %weight of each points
nnod=size(p2,1);
zb2=zeros(size(zb1));


for i=1:1:nnod
    [idx,d]=knnsearch(p1,p2(i,1:2),'K',k);
    for j=1:1:k
        if d(j)==0
            %do not change the value at original points
            wt=0*wt;
            wt(j)=1;
            break;
        else
            wt(j)=1/d(j);
        end
    end
    
    zb2(i,:)=wt*zb1(idx,:)/sum(wt);
end