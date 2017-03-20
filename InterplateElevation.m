function gp=InterplateElevation(p_coordi,tri,edit_part,p)
%basic usage: gp=InterplateElevation(p_coordi,tri)


cs_xyz=read_elevation;
ncs=size(cs_xyz,2);
%rebulid distance-elevation data
b=cell(1,ncs);
cs_dz=struct('dist',b,'z',b);       %creat a struct array
for i=1:1:ncs
    cs_dz(i).dist=zeros(cs_xyz(i).npt,1);
    cs_dz(i).z=zeros(cs_xyz(i).npt,1);
    for j=1:1:cs_xyz(i).npt
        cs_dz(i).dist(j)=((cs_xyz(i).xyz(j,1)-cs_xyz(i).xyz(1,1))^2+(cs_xyz(i).xyz(j,2)-cs_xyz(i).xyz(1,2))^2)^0.5;
        cs_dz(i).z(j)=cs_xyz(i).xyz(j,3);    
    end
end

if nargin~=4
    load('p_domain','p');
end

hfig=figure;
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
    p(i).ButtonDownFcn={@PolygonClickCallback};
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
    vxy(i).xv=zeros(npt_in_1p,1);
    vxy(i).yv=zeros(npt_in_1p,1);
    %check if the vertices in the polygon are on measured cross-sections
    for j=1:1:npt_in_1p
        px=p(i).Vertices(pts(j),1);
        py=p(i).Vertices(pts(j),2);
        vxy(i).xv(j)=px;
        vxy(i).yv(j)=py;
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
                [mc,vb]=set_breakline_user(p(i),p(i).node_on_cs(:,1));
                break;
            elseif p1cs~=p2cs
                mc=[mc;py2-py1,px1-px2];
                vb=[vb;-py1*(px2-px1)+px1*(py2-py1)];
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
if nargin==0
    button=questdlg('Choose a grid file','Guide','Yes');
    if ~strcmp(button,'Yes')
        return;
    end
    filename=uigetfile;
    gp=load(filename);
else
    gp.p=p_coordi;
    gp.t=tri;
end
gp.p=[gp.p,zeros(size(gp.p,1),1)];

hold on;
for i=1:1:size(gp.p,1)
    p_ref=[];
    hp=plot(gp.p(i,1),gp.p(i,2),'ro');
    for j=1:1:nplg
        [in,on]=inpolygon(gp.p(i,1),gp.p(i,2),vxy(j).xv,vxy(j).yv);
        if in==1
            for k=1:1:size(p(j).node_on_cs,2)
                %get intersection point on the first CS
                mc=[];
                vb=[];

                px1=p(j).intp_xy(1,k);
                py1=p(j).intp_xy(2,k);
                px2=gp.p(i,1);
                py2=gp.p(i,2);
                mc=[mc;py2-py1,px1-px2];
                vb=[vb;-py1*(px2-px1)+px1*(py2-py1)];
                
                px1=cs_xyz(p(j).node_on_cs(1,k)).xyz(1,1);
                py1=cs_xyz(p(j).node_on_cs(1,k)).xyz(1,2);
                px2=cs_xyz(p(j).node_on_cs(1,k)).xyz(end,1);
                py2=cs_xyz(p(j).node_on_cs(1,k)).xyz(end,2);
                mc=[mc;py2-py1,px1-px2];
                vb=[vb;-py1*(px2-px1)+px1*(py2-py1)];
                
                if mc(1,:)==[0,0]
                    break;
                end
                refxy=(mc\vb).';
                pdis=((refxy(1)-px1)^2+(refxy(2)-py1)^2)^0.5;
                refz=interp_lat(cs_dz(p(j).node_on_cs(1,k)),pdis);
                p_ref=[p_ref;refxy,refz];
                %get intersection point on the second CS
                px1=cs_xyz(p(j).node_on_cs(2,k)).xyz(1,1);
                py1=cs_xyz(p(j).node_on_cs(2,k)).xyz(1,2);
                px2=cs_xyz(p(j).node_on_cs(2,k)).xyz(end,1);
                py2=cs_xyz(p(j).node_on_cs(2,k)).xyz(end,2);
                mc(2,:)=[py2-py1,px1-px2];
                vb(2,:)=[-py1*(px2-px1)+px1*(py2-py1)];
                
                refxy=(mc\vb).';
                pdis=((refxy(1)-px1)^2+(refxy(2)-py1)^2)^0.5;
                refz=interp_lat(cs_dz(p(j).node_on_cs(2,k)),pdis);
                p_ref=[p_ref;refxy,refz];
            end
            break;
        end
    end
    
    if isempty(p_ref)
        if (nargin==3&&edit_part==0)||(nargin==2)
            dlgstr='a grid point is not in any polygon, you can in put its z coordinate manually:';
            op2.WindowStyle='normal';
            usert=inputdlg({dlgstr},'user input', 1, {''}, op2);
            if ~isempty(usert)
                try
                    rt=textscan(usert{1},'%f');
                    gp.p(i,3)=rt{1};
                catch err
                    
                end
            end
        end
    else
        %longitudinal interpolation
        nref=size(p_ref,1);
        wei=zeros(1,nref);
        for k=1:1:nref
            ddd=((gp.p(i,1)-p_ref(k,1))^2+(gp.p(i,2)-p_ref(k,2))^2)^0.5;
            if ddd==0
                wei(1,:)=0;
                wei(k)=1;
                break;
            end
            wei(k)=1/ddd;
        end
        s_wei=sum(wei);
        wei=wei/s_wei;
        gp.p(i,3)=wei*p_ref(:,3);
    end
    delete(hp);
end
%draw mesh in 3D view
%trisurf(gp.t,gp.p(:,1),gp.p(:,2),gp.p(:,3));

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
        
        mc=[mc;py2-py1,px1-px2];
        vb=[vb;-py1*(px2-px1)+px1*(py2-py1)];
        bl=[bl;px1,py1,px2,py2];
    end
end

end


function refz=interp_lat(cs_d_z,pdis)
%lateral interpolation

refz={};
npt=size(cs_d_z.dist,1);
for i=1:1:npt-1
    if (pdis>=cs_d_z.dist(i))&&(pdis<=cs_d_z.dist(i+1))
        d1=pdis-cs_d_z.dist(i);
        d12=cs_d_z.dist(i+1)-cs_d_z.dist(i);
        refz=(1-d1/d12)*cs_d_z.z(i)+d1/d12*cs_d_z.z(i+1);
        return;
    end
end

if pdis-cs_d_z.dist(npt)<0.1
    refz=cs_d_z.z(npt);
end
if isempty(refz)
    button=questdlg('requested point is not on the CS');
end
end