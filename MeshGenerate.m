function [p,t]=MeshGenerate
%use the  program Mesh2d_v24 by Darren Engwirda to generate a triangle mesh
%and write the mesh into a text file

[nodes,arcs,polygons]=read_sms_map;

nd=nodes(:,2:3);
nplg=size(polygons,1);
cnect=[];

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
    
    cnect=[cnect,c];
end

hdata.hmax=100;    %limit the cell size
[p,t] = mesh2d(nd,cnect,hdata);