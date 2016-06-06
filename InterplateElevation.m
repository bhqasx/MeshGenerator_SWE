function InterplateElevation(gp)


clear;
cs_xyz=read_elevation;
ncs=size(cs_xyz,2);
load('p_domain','p');
for i=1:1:size(p,2)
    switch mod(i,4)
        case 0
            p(i).EdgeColor='black';
        case 1
            p(i).EdgeColor='blue';
        case 2
            p(i).EdgeColor='red';
        case 3
            p(i).EdgeColor='green';
    end
    patch(p(i));
end
DrawCsNumber;
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
    
    %fix polygons whose cross sections are not well defined
    if any(p(i).node_on_cs>2)
        warndlg('more than two vertices of a polygon lie on a cs',['polygon ', num2str(i)]);
    else
        tt=(p(i).node_on_cs>0);
        if sum(tt)~=2
            ptemp=rmfield(p(i),'node_on_cs');
            ptemp.FaceColor='green';
            ptemp=patch(ptemp);
            DrawCsNumber;
            options.WindowStyle='normal';
            aa=inputdlg({'input two or four cs numbers for this polygon'}...
                ,'user input', 1, {''}, options);
            rt=textscan(aa{1},'%f','Delimiter',',');
            p(i).node_on_cs=rt{1};
            set(ptemp,'FaceColor','none');
        else
            p(i).node_on_cs=find(tt);
        end
    end 
    
    %find the intersection point of two b
end

%-----------------------------interpolation------------------------------
for i=1:1:size(gp,1)
    for j=1:1:nplg
        
    end
end

%---------------------------------nested function-----------------------
    function DrawCsNumber
        for cc=1:1:ncs
            tx=(cs_xyz(cc).xyz(1,1)+cs_xyz(cc).xyz(end,1))/2;
            ty=(cs_xyz(cc).xyz(1,2)+cs_xyz(cc).xyz(end,2))/2;
            text(tx,ty,num2str(cc));
        end
    end

end