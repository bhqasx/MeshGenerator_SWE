function domn=DomainDivision(outline_src,varargin)
%elevation interpolation
%step1: extract polygons from a SMS map file.  

if outline_src==1
    domn=extract_sms_domain;      %extract domains from a sms map file
elseif outline_src==2
    if nargin==1
        domn=divide_domain;              %specify domains by mouse from 3D cross-section lines
    elseif nargin==2 
        domn=divide_domain(varargin{1});         %edit a domain division
    else
        disp('invalid input parameter');
        return;
    end
elseif outline_src==3
    if nargin==4
        domn=auto_divide_domain(varargin{1},varargin{2},varargin{3});
    else
        disp('invalid input parameter');
        return;
    end
else
    disp('invalid input parameter');
    return;
end
    


%--------------------------------------------------------------
function p=extract_sms_domain
[nodes,arcs,polygons]=read_sms_map;

nd=nodes(:,2:3);
nplg=size(polygons,2);

b=cell(1,nplg);
p=struct('Vertices',b,'Faces',b,'FaceColor',b);       %creat a struct array
for i=1:1:nplg
    PlgArcs=polygons{i};
    narc_in_plg=size(PlgArcs,1);
    c=zeros(narc_in_plg,2);
    for j=1:1:narc_in_plg
        ind=find(arcs(:,1)==PlgArcs(j));    %find the row index of the jth arc in a polygon
        rnd=find(nodes(:,1)==arcs(ind,2));
        c(j,1)=rnd;
        rnd=find(nodes(:,1)==arcs(ind,3));
        c(j,2)=rnd;
    end

    %check the connective relationship
    for j=2:1:narc_in_plg
        if (sum(c(j-1,:)==c(j,1))==0)&&(sum(c(j-1,:)==c(j,2))==0)
            msgbox('invalid connective relationship');
        else
            if c(j-1,1)==c(j,1)
                c(j-1,:)=fliplr(c(j-1,:));
            elseif c(j-1,1)==c(j,2)
                c(j-1:j,:)=fliplr(c(j-1:j,:));
            elseif c(j-1,2)==c(j,2)
                c(j,:)=fliplr(c(j,:));
            end
        end
    end
    
    p(i).Vertices=nd;
    p(i).Faces=[c(1,:),(c(2:end,2)).'];
    p(i).FaceColor='none';
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
    p(i).ButtonDownFcn={@PolygonClickCallback,i};    %set the callback function and its input parameter
    patch(p(i));
end


%--------------------------------------------------------------
function p=divide_domain(p)
cs_xyz=read_elevation;
hfig=figure;
ncs=size(cs_xyz,2);
for i=1:1:ncs
     plot3(cs_xyz(i).xyz(:,1),cs_xyz(i).xyz(:,2),cs_xyz(i).xyz(:,3),'b-d');
     hold on;
end
view([0,90]);

if nargin==0
    ndm=0;
else
    ndm=size(p,2);
    for i=1:1:ndm
        patch(p(i));
    end
end

nd=zeros(4,3);
button='Yes';
while 1==1   
    button=questdlg('Click on four points to define a interplation region, then press Return.');
    if ~strcmp(button,'Yes')
        return;
    end
    
    ndm=ndm+1;
    
    dcm_obj = datacursormode(hfig);
    dcm_obj.removeAllDataCursors();
    set(dcm_obj,'DisplayStyle','datatip',...
        'SnapToDataVertex','on','Enable','on');
    
    % Wait while the user does this.
    pause;
    
    %hold Alt to pick mutiple points
    c_info = getCursorInfo(dcm_obj);
    nd(1,:)=c_info(4).Position;
    nd(2,:)=c_info(3).Position;
    nd(3,:)=c_info(2).Position;
    nd(4,:)=c_info(1).Position;
    
    p(ndm).Vertices=nd;
    p(ndm).Faces=[1,2,3,4,1];
    p(ndm).FaceColor='none';
    p(ndm).EdgeColor='red';
    
    p(ndm).ButtonDownFcn={@PolygonClickCallback,ndm};    %set the callback function and its input parameter
    patch(p(ndm));
end


%--------------------------------------------------------------
function pg=auto_divide_domain(CS,bl1,bl2)
ncs=size(CS,2);
for i=1:1:ncs-1
    %left floodplain domain
    iptc=3*(i-1)+1;
    pg(iptc).Vertices=[CS(i).xy(1,:);CS(i+1).xy(1,:);bl1(i+1,:);bl1(i,:)];
    pg(iptc).Faces=[1,2,3,4,1];
    
    %main channel
    iptc=3*(i-1)+2;
    pg(iptc).Vertices=[bl1(i,:);bl1(i+1,:);bl2(i+1,:);bl2(i,:)];
    pg(iptc).Faces=[1,2,3,4,1];
    
    iptc=3*i;
    pg(iptc).Vertices=[bl2(i,:);bl2(i+1,:);CS(i+1).xy(end,:);CS(i).xy(end,:)];
    pg(iptc).Faces=[1,2,3,4,1];
end

for i=1:1:size(pg,2)
    pg(i).FaceColor='none';
    switch mod(i,4)
        case 0
            pg(i).EdgeColor='black';
        case 1
            pg(i).EdgeColor='blue';
        case 2
            pg(i).EdgeColor='red';
        case 3
            pg(i).EdgeColor='green';
    end
    pg(i).ButtonDownFcn={@PolygonClickCallback,i};    %set the callback function and its input parameter
    patch(pg(i));    
end