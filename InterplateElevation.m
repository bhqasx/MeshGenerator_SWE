function InterplateElevation


clear;
cs_xyz=read_elevation;
ncs=size(cs_xyz,2);
load('p_domain','p');
%assign two measured cross-sections to each polygon
nplg=size(p,2);
for i=1:1:nplg
    p(i).node_on_cs=zeros(ncs,1);
    pts=p(i).Faces;       %get all vertices in a polygon
    if pts(1)==pts(end)
        pts=pts(1:end-1);
    end
    npt_in_1p=size(pts,2);
    %check if the vertices in the polygon are on measured cross-sections
    for j=1:1:npt_in_1p
        px=p(i).Vertices(pts(j),1);
        py=p(i).Vertices(pts(j),2);
        for k=1:1:ncs
            if abs(px-cs_xyz(k).xyz(1,1))<1e-02&&abs(py-cs_xyz(k).xyz(1,2))<1e-02
                p(i).node_on_cs(k)=p(i).node_on_cs(k)+1;
            elseif abs(px-cs_xyz(k).xyz(end,1))<1e-02&&abs(py-cs_xyz(k).xyz(end,2))<1e-02
                p(i).node_on_cs(k)=p(i).node_on_cs(k)+1;
            end
        end
    end
    
    if any(p(i).node_on_cs>2)
        warndlg('more than two vertices of a polygon lie on a cs',['polygon ', num2str(i)]);
    else
        tt=(p(i).node_on_cs>0);
        if sum(tt)~=2
            warndlg('need order',['polygon ', num2str(i)]);
        else
            p(i).node_on_cs=find(tt);
        end
    end
    
end