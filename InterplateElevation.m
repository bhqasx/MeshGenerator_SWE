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
    p(i).intp_xy=[NaN,NaN];
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
            ptemp=rmfield(p(i),{'node_on_cs','intp_xy'});
            ptemp.FaceColor='green';
            ptemp=patch(ptemp);
            DrawCsNumber;
            options.WindowStyle='normal';
            aa=inputdlg({'input two or four cs numbers for this polygon'}...
                ,'user input', 1, {''}, options);
            rt=textscan(aa{1},'%f','Delimiter',',');
            p(i).node_on_cs=reshape(rt{1},2,size(rt{1},1)/2);
            set(ptemp,'FaceColor','none');
        else
            p(i).node_on_cs=find(tt);
        end
    end 
    
    %find the intersection point of two breaklines
    if size(p(i).node_on_cs,2)==1
        mc=[];      %coefficient matrix of intersection point eqs.
        vb=[];
        bl=[];     %xy of two points on a breakline
        for j=1:1:size(p(i).Faces,2)-1
            px1=p(i).Vertices(p(i).Faces(j),1);
            py1=p(i).Vertices(p(i).Faces(j),2);
            p1cs=isoncs(px1,py1,p(i).node_on_cs);
            
            px2=p(i).Vertices(p(i).Faces(j+1),1);
            py2=p(i).Vertices(p(i).Faces(j+1),2);
            p2cs=isoncs(px2,py2,p(i).node_on_cs);
            
            if p1cs*p2cs==0
                [mc,vb]=set_breakline_user(p(i));
                break;
            elseif p1cs~=p2cs
                mc=[mc;(py2-py1)/(px2-px1),-1];
                vb=[vb;(py2-py1)/(px2-px1)*px1-py1];
                bl=[bl;px1,py1,px2,py2];
            end
        end
        p(i).intp_xy=mc\vb;
        %draw the lines to confirm if the solution is correct
%         figure;
%         hold on;
%         line([bl(1,1),bl(1,3)],[bl(1,2),bl(1,4)]);
%         line([bl(2,1),bl(2,3)],[bl(2,2),bl(2,4)]);
%         plot(p(i).intp_xy(1),p(i).intp_xy(2),'ro');
    elseif size(p(i).node_on_cs,2)==2
        %there are four cs used to interplate elevation in this polygon
        [mc,vb]=set_breakline_user(p(i),p(i).node_on_cs(:,1));
        p(i).intp_xy=mc\vb;
        
        [mc,vb]=set_breakline_user(p(i),p(i).node_on_cs(:,2));
        p(i).intp_xy=[p(i).intp_xy,mc\vb];
    else
        button=questdlg('unexpected number of cross-sections');
    end
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
    

    function ot=isoncs(xx,yy,cs_e)
        ot=0;
        for kk=1:1:2
            x1=cs_xyz(cs_e(kk)).xyz(1,1);
            y1=cs_xyz(cs_e(kk)).xyz(1,2);
            
            x2=cs_xyz(cs_e(kk)).xyz(end,1);
            y2=cs_xyz(cs_e(kk)).xyz(end,2);
            
            coef_l=polyfit([x1,x2],[y1,y2],1);
            if abs(polyval(coef_l,xx)-yy)<0.1
                ot=cs_e(kk);
            end
            coef_l=polyfit([y1,y2],[x1,x2],1);
            if abs(polyval(coef_l,yy)-xx)<0.1
                ot=cs_e(kk);
            end
        end
    end

end


function [mc,vb]=set_breakline_user(p,ccss)
%set the breakline for a polygon region manually

mc=[];      %coefficient matrix of intersection point eqs.
vb=[];
bl=[];     %xy of two points on a breakline
for kk=1:1:size(p.Faces,2)
    tx=p.Vertices(p.Faces(kk),1);
    ty=p.Vertices(p.Faces(kk),2);
    text(tx,ty,['\it',num2str(p.Faces(kk))]);
end

if nargin==2
    dlgstr=['input end points indexes of a breakline for CS ', num2str(ccss(1)), ' and CS ', num2str(ccss(2))];
else
    dlgstr=['input end points indexes of a breakline'];
end
for kk=1:1:2
    op2.WindowStyle='normal';
    usert=inputdlg({dlgstr},'user input', 1, {''}, op2);
    
    rt=textscan(usert{1},'%f','Delimiter',',');      %use comma to seperate
    bl_u=rt{1};
    if size(bl_u,1)~=2
        button=questdlg('invalid input');
    else
        px1=p.Vertices(bl_u(1),1);
        py1=p.Vertices(bl_u(1),2);
        
        px2=p.Vertices(bl_u(2),1);
        py2=p.Vertices(bl_u(2),2);
        
        mc=[mc;(py2-py1)/(px2-px1),-1];
        vb=[vb;(py2-py1)/(px2-px1)*px1-py1];
        bl=[bl;px1,py1,px2,py2];
    end
end

end