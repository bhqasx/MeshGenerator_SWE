function PolygonClickCallback(pobj,evt,iplg)
%callback function executed when a polygon is clicked


set(pobj,'LineWidth',2);
nd=get(pobj,'Vertices');
Faces=get(pobj,'Faces');
for i=1:1:size(Faces,2)
    x=nd(Faces(1,i),1);
    y=nd(Faces(1,i),2);
    text(x,y,num2str(Faces(1,i)));
end

load('p_domain','p');
p(iplg)=[];

options.WindowStyle='normal';
aa=inputdlg({'input the indexes of the points to redraw a polygon. press Cancel if there is no need to redraw'}...
    ,'user input', 1, {''}, options);
while ~isempty(aa)
    rt=textscan(aa{1},'%f','Delimiter',',');      %use comma to seperate point indexes
    ndl=rt{1};
    
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
