function [zb_new]=InterplateElevation2(p,t,zb)
%In this method, the reference point is the intersection of the reference line
%and its perpendicular through a point in the user defined region.

hfig=figure;
patch('faces',t,'vertices',p,'facecolor','none','edgecolor','b');
axis equal;

%------------------define interplate region and reference lines------------
polyg=zeros(4,2);
rfla=zeros(2,2);
rflb=zeros(2,2);

button='Yes';
dcm_obj = datacursormode(hfig);
dcm_obj.removeAllDataCursors();
set(dcm_obj,'DisplayStyle','datatip',...
    'SnapToDataVertex','on','Enable','on');

button=questdlg('Click on four points to define the interplation region, then press Return.');
if ~strcmp(button,'Yes')
    return;
end
% Wait while the user does this.
pause;

%hold Alt to pick mutiple points
c_info = getCursorInfo(dcm_obj);
polyg(1,:)=c_info(4).Position;
polyg(2,:)=c_info(3).Position;
polyg(3,:)=c_info(2).Position;
polyg(4,:)=c_info(1).Position;

rfla(1,:)=c_info(4).Position;
rfla(2,:)=c_info(3).Position;
rflb(1,:)=c_info(1).Position;
rflb(2,:)=c_info(2).Position;

%----------------find all nodes on the reference lines-------------
nnod=size(p,1);
dmin=1;          %tolerance for judging if a point is on a line
rfnd_a=[];
rfnd_a_z=[];
rfnd_b=[];
rfnd_b_z=[];
for i=1:1:nnod
    dist=point_to_line([p(i,:),0], [rfla(1,:),0], [rfla(2,:),0]);
    if (dist<dmin) 
        rfnd_a=[rfnd_a; p(i,:)];
        rfnd_a_z=[rfnd_a_z; zb(i)];
    else
        dist=point_to_line([p(i,:),0], [rflb(1,:),0], [rflb(2,:),0]);
        if (dist<dmin)
            rfnd_b=[rfnd_b; p(i,:)];
            rfnd_b_z=[rfnd_b_z; zb(i)];
        end
    end
end

hold on;
nla=size(rfnd_a,1);
nlb=size(rfnd_b,1);
plot(rfnd_a(:,1),rfnd_a(:,2),'ro');
plot(rfnd_b(:,1),rfnd_b(:,2),'ro');

zb_new=zb;
%-----------------------interplation start--------------------
for i=1:1:nnod   
    in=inpolygon(p(i,1),p(i,2),polyg(:,1),polyg(:,2));
    if in==1
        %reference point on the first line
        [idx,d]=knnsearch(rfnd_a,p(i,1:2),'K',2);         
        z1=rfnd_a_z(idx(1));     
        z2=rfnd_a_z(idx(2));
        lna=point_to_line([p(i,:),0], [rfla(1,:),0], [rfla(2,:),0]);
        lna=min([d(1),d(2),lna]);
        l1=(d(1)^2-lna^2)^0.5;
        l2=(d(2)^2-lna^2)^0.5;
        zna=(l2*z1+l1*z2)/(l1+l2);
        
        %reference point on the second line
        [idx,d]=knnsearch(rfnd_b,p(i,1:2),'K',2);
        z1=rfnd_b_z(idx(1));
        z2=rfnd_b_z(idx(2));
        lnb=point_to_line([p(i,:),0], [rflb(1,:),0], [rflb(2,:),0]);
        lnb=min([d(1),d(2),lnb]);
        l1=(d(1)^2-lnb^2)^0.5;
        l2=(d(2)^2-lnb^2)^0.5;
        znb=(l2*z1+l1*z2)/(l1+l2);
        
        %longitutianl interplation
        zb_new(i)=(lnb*zna+lna*znb)/(lna+lnb);
    end
end


%--------------------------------------------------------------------------
function d = point_to_line(pt, v1, v2)
a = v1 - v2;
b = pt - v2;
d = norm(cross(a,b)) / norm(a);