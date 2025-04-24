function [ p,t,zb,pgxy,x_shape,y_shape ] = confluent_area_topo( CS,  zc, scale_r, hmax )
%make sure the three 3d lines in CS form a closed line.
%zc is z coordinate at the centroid of the confluent area
%you may need to use RiverGeoAnalysis.m in the repository of
%"matlab-tools-for-calibration" to prepare the input data


%----------------------------------------------------------
%connecting 6 end points from 3 CS to construct the boundary of the
%confluent area
pgxy.x=zeros(6,1);
pgxy.y=zeros(6,1);
pgxy.ics=zeros(6,1);    %the index of CS that a point in pgxy locates on
pgxy.ipOnCS=zeros(6,1);  %index of the node on its CS     

hfig=figure;
for kcs=1:1:3
    plot(CS(kcs).xy([1,end],1),CS(kcs).xy([1,end],2),'b-d');
    hold on;
end
button=questdlg('Connectiong 6 points in a clockwise or counter-clockwise direction to define the boundary (hold Alt and left click), then press Enter.');
if ~strcmp(button,'Yes')
    return;
end
dcm_obj = datacursormode(hfig);
dcm_obj.removeAllDataCursors();
set(dcm_obj,'DisplayStyle','datatip',...
    'SnapToDataVertex','on','Enable','on');

% Wait while the user does this.
pause;

%hold Alt to pick mutiple points
c_info = getCursorInfo(dcm_obj);
for kp=1:1:6
    pgxy.x(kp)=c_info(7-kp).Position(1);
    pgxy.y(kp)=c_info(7-kp).Position(2);
end
%----------------------------------------------------------


%----------------------------------------------------------
%construct the rest 3 boundary cross-section
for kp=1:1:6    
    for kcs=1:1:3
        if (pgxy.x(kp)-CS(kcs).xy(1,1)==0)&&(pgxy.y(kp)-CS(kcs).xy(1,2)==0)
            pgxy.ics(kp)=kcs;
            pgxy.ipOnCS(kp)=1;
        elseif (pgxy.x(kp)-CS(kcs).xy(end,1)==0)&&(pgxy.y(kp)-CS(kcs).xy(end,2)==0)
            pgxy.ics(kp)=kcs;
            pgxy.ipOnCS(kp)=CS(kcs).npt;
        end
    end
end

kcs=3;
for kp=1:1:6
    if kp==6
        ip1=6;
        ip2=1;
    else
        ip1=kp;
        ip2=kp+1;
    end
    
    if pgxy.ics(ip1)~=pgxy.ics(ip2)
        kcs=kcs+1;
        CS(kcs).npt=2;
        CS(kcs).xy=[CS(pgxy.ics(ip1)).xy(pgxy.ipOnCS(ip1),:); CS(pgxy.ics(ip2)).xy(pgxy.ipOnCS(ip2),:)];
        CS(kcs).zb=[CS(pgxy.ics(ip1)).zb(pgxy.ipOnCS(ip1)); CS(pgxy.ics(ip2)).zb(pgxy.ipOnCS(ip2))];
    end
end

if (numel(CS)~=6)
    disp('6 cross-sections (3 from measurements and 3 created by users) is need to execute the function');
    return;
end
%----------------------------------------------------------


%----------------------------------------------------------
%generate 2d planar mesh
nd=[pgxy.x,pgxy.y];
cnect=[(1:6).',[(2:6).';1]];
parentpath = cd(cd('..'));      %mesh2d is in the parent folder

addpath(parentpath);

if nargin==3
    hdata.hmax=100;    %limit the cell size
else
    hdata.hmax=hmax;
end
[p,t] = mesh2d(nd,cnect,hdata);

rmpath(parentpath);
%----------------------------------------------------------

zb=zeros(size(p,1),1);

[xc,yc]=get_centroid(pgxy.x, pgxy.y);
%calculate shape parameters of the polygon
x_shape=0;
y_shape=0;
for i=1:1:3
    x_shape=x_shape+abs(xc-0.5*(CS(i).xy(1,1)+CS(i).xy(end,1)));
    y_shape=y_shape+abs(yc-0.5*(CS(i).xy(1,2)+CS(i).xy(end,2)));
end

%define the inner polygon in which every node has the constant elevation zc
pg_inner_xy.x=xc+scale_r*(pgxy.x-xc);
pg_inner_xy.y=yc+scale_r*(pgxy.y-yc);

for i=1:1:size(p,1)
    [in,on]=inpolygon(p(i,1), p(i,2), pg_inner_xy.x, pg_inner_xy.y);
    if (in==1)||(on==1)
        zb(i)=zc;
    else   
        zb(i)=interp_outer_region;
    end
end

figure
trisurf(t,p(:,1),p(:,2),zb);


    
    function  zzz=interp_outer_region
        for j=1:1:6
            if j==6
                vt1=6;
                vt2=1;
            else
                vt1=j;
                vt2=j+1;
            end
            [in,on]=inpolygon(p(i,1), p(i,2), [xc; pgxy.x([vt1,vt2])], [yc; pgxy.y([vt1,vt2])]);
            
            flag_plateau=0;
            if (in==1)||(on==1)
                if pgxy.ics(vt1)~=pgxy.ics(vt2)                                         %20171031修改
                    zb1=CS(pgxy.ics(vt1)).zb(pgxy.ipOnCS(vt1));
                    zb2=CS(pgxy.ics(vt2)).zb(pgxy.ipOnCS(vt2));
                    zb_edge=min(zb1,zb2);
                    flag_plateau=1;
                end
                %get the intersection of the polygon and the line connecting the mesh node and the centroid
                mc=[];
                vb=[];
                
                px1=xc;
                py1=yc;
                px2=p(i,1);
                py2=p(i,2);
                mc=[mc;py2-py1,px1-px2];
                vb=[vb;-py1*(px2-px1)+px1*(py2-py1)];
                
                px1=pgxy.x(vt1);
                py1=pgxy.y(vt1);
                px2=pgxy.x(vt2);
                py2=pgxy.y(vt2);
                mc=[mc;py2-py1,px1-px2];
                vb=[vb;-py1*(px2-px1)+px1*(py2-py1)];
                
                if mc(1,:)==[0,0]
                    disp('重合点');
                    pause;
                end
                
                refxy=(mc\vb).';
                break;
            end
        end
        
 
        vector1=[pgxy.x(vt2)-pgxy.x(vt1),pgxy.y(vt2)-pgxy.y(vt1)];
        vector1=[-vector1(2),vector1(1)];
        for j=1:1:6
            vector2=CS(j).xy(end,:)-CS(j).xy(1,:);
            if dot(vector1,vector2)==0
                %interplation on the cross-section
                [idx,d]=knnsearch(CS(j).xy,refxy,'K',2);
                wt=zeros(1,2);      %weight of each points
                for jj=1:1:2
                    if d(jj)==0
                        %do not change the value at original points
                        wt=0*wt;
                        wt(jj)=1;
                        break;
                    else
                        wt(jj)=1/d(jj);
                    end
                end
                
                refz=wt*CS(j).zb(idx,:)/sum(wt);
                
                %interplation along the line connecting the centroid and the
                %mesh node
                la=norm([p(i,1), p(i,2)]-refxy);
                lb=norm([xc, yc]-[p(i,1), p(i,2)])-scale_r*norm([xc,yc]-refxy);
                if flag_plateau==0
                    zzz=(lb*refz+la*zc)/(la+lb);
                else
                    zzz=(lb*refz+la*zb_edge)/(la+lb);
                end
                break;
            end
        end
    end

end



