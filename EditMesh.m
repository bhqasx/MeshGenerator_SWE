function [p,t,zb]=EditMesh(p,t,zb)


str={'Remove a Node',...
        'Edit elevation'};
[optype,ok]=listdlg('PromptString','Select an operation:','SelectionMode','single','ListString',str);

if optype==1
    [p,t,zb]=RemoveNode(p,t,zb);
end

if optype==2
    [p,t,zb]=EditZvalue(p,t,zb);
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
    set(dcm_obj,'DisplayStyle','datatip',...
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

%---------------------------------------------------------
function [p,t,zb]=EditZvalue(p,t,zb)
%modify z value of a node

hfig=figure;
trisurf(t,p(:,1),p(:,2),-zb);
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
    
    trisurf(t,p(:,1),p(:,2),-zb);
    %shading('interp');
    view([0,90]);
end
    