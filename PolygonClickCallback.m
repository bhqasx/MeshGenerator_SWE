function PolygonClickCallback(pobj,evt,iplg)
%callback function executed when a polygon is clicked


persistent ncall;
if isempty(ncall)||(nargin==3)
    set(pobj,'LineWidth',2);
    nd=get(pobj,'Vertices');
    Faces=get(pobj,'Faces');
    sz=size(Faces,2);
    x=zeros(1,sz);
    y=zeros(1,sz);
    for i=1:1:size(Faces,2)
        x(i)=nd(Faces(1,i),1);
        y(i)=nd(Faces(1,i),2);
        tstr(1,i)={['\it',num2str(Faces(1,i))]};
    end
    ht=text(x,y,tstr);
    set(pobj,'UserData',ht);
    ncall=1;
else
    ht=get(pobj,'UserData');
    delete(ht);
    ncall=[];
end

if nargin==2
    return;
end
load('p_domain','p');
p(iplg)=[];

options.WindowStyle='normal';
aa=inputdlg({'input the indexes of the points to redraw a polygon. press Cancel if there is no need to redraw'}...
    ,'user input', 1, {''}, options);
while ~isempty(aa)
    rt=textscan(aa{1},'%f','Delimiter',',');      %use comma to seperate point indexes
    ndl=rt{1};
    if size(unique(ndl),1)==size(ndl,1)
        ndl=[ndl;ndl(1)];
    end
    
    %create a new patch
    clear newp;
    newp.Vertices=nd;
    newp.Faces=ndl.';
%    newp.FaceColor='none';
    patch(newp);
    
    %append to original polygon structure
    newp.FaceColor='none';
    newp.EdgeColor=[0,0,0];
    newp.ButtonDownFcn='';
    p(size(p,2)+1)=newp;   
    
    options.WindowStyle='normal';
    aa=inputdlg({'input the indexes of the points to redraw a polygon. press Cancel if there is no need to redraw'}...
        ,'user input', 1, {''}, options);
end

close gcf;
for i=1:1:size(p,2)
    p(i).ButtonDownFcn={@PolygonClickCallback,i};
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
%rewrite the polygon structure
save('p_domain','p');
