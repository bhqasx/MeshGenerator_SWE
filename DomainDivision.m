function DomainDivision
%elevation interpolation
%step1: extract polygons from a SMS map file.  
clear;
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

save('p_domain','p');