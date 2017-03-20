function newzb=InterpAlongLine(p,zb,refl,refz,node)
%refl上的点必须均匀分布
%

newzb=zb;
nnod=size(p,1);
in=inpoly(p,node);
for i=1:1:nnod
    if in(i)==true
        [idx,d]=knnsearch(refl,p(i,1:2),'K',2);
        z1=refz(idx(1));     
        z2=refz(idx(2));
        lna=point_to_line([p(i,:),0], [refl(idx(1),:),0], [refl(idx(2),:),0]);
        lna=min([d(1),d(2),lna]);
        l1=(d(1)^2-lna^2)^0.5;
        l2=(d(2)^2-lna^2)^0.5;
        zna=(l2*z1+l1*z2)/(l1+l2);        
        
        if zna>zb(i)
            newzb(i)=zna;
        end
    end
end



%--------------------------------------------------------------------------
function d = point_to_line(pt, v1, v2)
a = v1 - v2;
b = pt - v2;
d = norm(cross(a,b)) / norm(a);
