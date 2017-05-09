function [p,t,zb]=EditMesh(p,t,zb,region)


str={'Remove a Node',...
        'Remove a region',...
        'Edit elevation',...
        'Smooth zb'...
        'Refine and Interplate Z'};
[optype,ok]=listdlg('PromptString','Select an operation:','SelectionMode','single','ListString',str);

if optype==1
    [p,t,zb]=RemoveNode(p,t,zb);
end

if optype==2
    [p,t,zb]=RemoveRegion(p,t,zb,region);
end

if optype==3
    [p,t,zb]=EditZvalue(p,t,zb);
end

if optype==4
    %region can be input as [], if users need to set it by picking points
    %with mouse.
    [p,t,zb]=SmoothZb(p,t,zb,region);
end

if optype==5
    %region can be input as [], if users need to set it by picking points
    %with mouse.
    [p,t,zb]=RefineAndInterp(p,t,zb,region);
end 
   
%---------------------------------------------------------
function [p,t,zb]=RemoveNode(p,t,zb)
%remove a node and rebuild the mesh

% patch('faces',t,'vertices',p,'facecolor','none','edgecolor','b');
% axis equal;
hfig=figure;
trisurf(t,p(:,1),p(:,2),-zb);
view([0,90]);

while 1
    dcm_obj = datacursormode(hfig);
    dcm_obj.removeAllDataCursors();
    set(dcm_obj,'DisplayStyle','window',...
        'SnapToDataVertex','on','Enable','on');
    
    button=questdlg('Pick a node and press Return. One node at a time!');
    if ~strcmp(button,'Yes')
        break;
    end
    % Wait while the user does this.
    pause;
    
    %hold Alt to pick mutiple points
    c_info = getCursorInfo(dcm_obj);
    
    nnod=size(p,1);     %node number
    ntri=size(t,1);          %number of triangles
    t2=[];
    for i=1:1:nnod
        if (p(i,1)==c_info(1).Position(1))&&(p(i,2)==c_info(1).Position(2))
            idx=i;
            break;
        end
    end
    
    p(idx,:)=[];
    zb(idx,:)=[];
    
    for i=1:1:ntri
        if any(t(i,:)==idx)==0
            for j=1:1:3
                if t(i,j)>idx
                    t(i,j)=t(i,j)-1;
                end
            end
            t2=[t2; t(i,:)];
        end
    end
      
    t=t2;
    trisurf(t,p(:,1),p(:,2),-zb);
    view([0,90]);
end

%-------delete unused nodes--------
nnod=size(p,1);     %node number
ntri=size(t,1);          %number of triangles
aug_p=[1:nnod].';
aug_p=[aug_p,p,zb];
aug_pnew=[];
for i=1:1:nnod
    if any(any(t==aug_p(i,1)))==1
        aug_pnew=[aug_pnew; aug_p(i,:)];
    end
end
p=aug_pnew(:,2:3);
zb=aug_pnew(:,4);

for i=1:1:ntri
    for j=1:1:3
        id_new=find(aug_pnew(:,1)==t(i,j));
        t(i,j)=id_new;
    end
end

trisurf(t,p(:,1),p(:,2),-zb);
view([0,90]);


%-------------------------------------------------------------------
function [p,t,zb]=RemoveRegion(p,t,zb,region)


in = inpoly(p,region);
while sum(in)>0
    nnod=size(p,1);
    disp(nnod);
    ntri=size(t,1);  
    
    for i=1:1:nnod
        if in(i)==1
            idx=i;
            break;
        end
    end
    
    p(idx,:)=[];
    zb(idx,:)=[];   
    t2=[];
    
    for i=1:1:ntri
        if any(t(i,:)==idx)==0
            for j=1:1:3
                if t(i,j)>idx
                    t(i,j)=t(i,j)-1;
                end
            end
            t2=[t2; t(i,:)];
        end
    end    
    t=t2;
    
    in = inpoly(p,region);
end

%-------delete unused nodes--------
nnod=size(p,1);     %node number
ntri=size(t,1);          %number of triangles
aug_p=[1:nnod].';
aug_p=[aug_p,p,zb];
aug_pnew=[];
for i=1:1:nnod
    if any(any(t==aug_p(i,1)))==1
        aug_pnew=[aug_pnew; aug_p(i,:)];
    end
end
p=aug_pnew(:,2:3);
zb=aug_pnew(:,4);

for i=1:1:ntri
    for j=1:1:3
        id_new=find(aug_pnew(:,1)==t(i,j));
        t(i,j)=id_new;
    end
end

hfig=figure;
trisurf(t,p(:,1),p(:,2),-zb);
view([0,90]);

%-------------------------------------------------------------------
function [p,t,zb]=EditZvalue(p,t,zb)
%modify z value of a node

hfig=figure;
trisurf(t,p(:,1),p(:,2),zb);
%shading('interp');
view([0,90]);

while 1
    dcm_obj = datacursormode(hfig);
    dcm_obj.removeAllDataCursors();
    set(dcm_obj,'DisplayStyle','window',...
        'SnapToDataVertex','on','Enable','on');
    
    button=questdlg('Pick a node and press Return. One node at a time!');
    if ~strcmp(button,'Yes')
        break;
    end
    % Wait while the user does this.
    pause;
    
    %hold Alt to pick mutiple points
    c_info = getCursorInfo(dcm_obj);
    
    nnod=size(p,1);     %node number
    for i=1:1:nnod
        if (p(i,1)==c_info(1).Position(1))&&(p(i,2)==c_info(1).Position(2))
            idx=i;
            break;
        end
    end
    
    zz=inputdlg('input a new z value:');
    zb(idx)=str2num(zz{1});
    
    trisurf(t,p(:,1),p(:,2),zb);
    %shading('interp');
    view([0,90]);
end

%---------------------------------------------------------
function [p,t,zb2]=SmoothZb(p,t,zb1,region)
%for any points in region, use the mean zb of their surrounding points
%to substitute the original zb.
%region is an N*2 array defining a polygon 

if isempty(region)
    hfig=figure;
    trisurf(t,p(:,1),p(:,2),-zb1);
    %shading('interp');
    view([0,90]);
    
    button='Yes';
    dcm_obj = datacursormode(hfig);
    dcm_obj.removeAllDataCursors();
    set(dcm_obj,'DisplayStyle','datatip',...
        'SnapToDataVertex','on','Enable','on');
    
    button=questdlg('Click on four points to define the interplation region, then press Return.');
    if ~strcmp(button,'Yes')
        zb2=zb1;
        return;
    end
    % Wait while the user does this.
    pause;
    
    %hold Alt to pick mutiple points
    region=zeros(4,2);
    c_info = getCursorInfo(dcm_obj);
    region(1,:)=c_info(4).Position(1:2);
    region(2,:)=c_info(3).Position(1:2);
    region(3,:)=c_info(2).Position(1:2);
    region(4,:)=c_info(1).Position(1:2);
end

in = inpoly(p,region);
nnod=size(p,1);
zb2=zb1;

k=6;     %number of nearest points for calculating mean zb
wt=zeros(1,k);      %weight of each points
for i=1:1:nnod
    if in(i)==1
        [idx,d]=knnsearch(p,p(i,1:2),'K',k);   
        
        %use distance as weight
%         for j=1:1:k
%             if d(j)==0
%                 wt(j)=0
%             end
%             wt(j)=1/d(j)
%         end
        
        %arithmatic average
        wt=ones(1,k);
        
        zb2(i)=wt*zb1(idx)/sum(wt);        
    end
end

trisurf(t,p(:,1),p(:,2),-zb2);
view([0,90]);


%---------------------------------------------------------
function [p2,t2,zb2]=RefineAndInterp(p1,t1,zb1,region)
%refine a region in the mesh and execute elevation interplation for the 
%added nodes


if isempty(region)
    hfig=figure;
    trisurf(t1,p1(:,1),p1(:,2),zb1);
    view([0,90]);

    button='Yes';
    dcm_obj = datacursormode(hfig);
    dcm_obj.removeAllDataCursors();
    set(dcm_obj,'DisplayStyle','datatip',...
        'SnapToDataVertex','on','Enable','on');
    
    button=questdlg('Click on four points to define the interplation region, then press Return.');
    if ~strcmp(button,'Yes')
        zb2=zb1;
        return;
    end
    % Wait while the user does this.
    pause;
    
    %hold Alt to pick mutiple points
    region=zeros(4,2);
    c_info = getCursorInfo(dcm_obj);
    region(1,:)=c_info(4).Position(1:2);
    region(2,:)=c_info(3).Position(1:2);
    region(3,:)=c_info(2).Position(1:2);
    region(4,:)=c_info(1).Position(1:2);
end

in = inpoly(p1,region);
ti = sum(in(t1),2)>0; 
[p2,t2] = refine(p1,t1,ti);
[zb2]=InterpNearestPoints(p1,zb1,p2,4);

