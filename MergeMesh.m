function [p,t]=MergeMesh(p,t,pe,te,cnct_nd1,cnct_nd2)
%Merge two meshes. cnct_nd1 is the indexs of the connecting nodes in mesh
%p, cnct_nd2 is the indexes of the connectiong nodes in mesh pe, cnct_nd1(i)
%and cnct_nd2(i) refer to the same node entity.

n_cnct=size(cnct_nd1);
if n_cnct~=size(cnct_nd2);
    disp('Eerror: the size of cnct_nd1 and cnct_nd2 are different');
    return;
end

% for i=1:1:n_cnct
%     if p(cnct_nd1(i),1)~=pe(cnct_nd2(i),1)
%         disp('Eerror: cnct_nd1 and cnct_nd2 refer to different nodes');
%         return;
%     end
%     
%     if p(cnct_nd1(i),2)~=pe(cnct_nd2(i),2)
%         disp('Eerror: cnct_nd1 and cnct_nd2 refer to different nodes');
%         return;
%     end
% end


nnod1=size(p,1);
nnod2=size(pe,1);
new_idx_pe=zeros(nnod2,1);   %new indexes of nodes in pe in the merged mesh
nd_count=0;

for i=1:1:nnod2
    k=find(cnct_nd2==i);
    if isempty(k)
        p=[p;pe(i,:)];       %update p
        nd_count=nd_count+1;
        new_idx_pe(i)=nnod1+nd_count;
    else
        new_idx_pe(i)=cnct_nd1(k);
    end
end

%--------------------------update t------------------------
ntri=size(te,1);
for i=1:1:ntri
    for j=1:1:3
        te(i,j)=new_idx_pe(te(i,j));
    end
end
t=[t;te];