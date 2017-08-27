function [ zb ] = confluent_area_topo( CS, pgxy, zc, scale_r, p, t )
%make sure the six 3d lines in CS form a closed line.
%cs_order is an array of the indexes of elements in the struct CS, which is
%arranged in clockwise or counter-clockwise order.
%zc is z coordinate at the centroid of the confluent area
if (numel(CS)~=6)
    disp('6 cross-sections (3 from measurements and 3 created by users) is need to execute the function');
    return;
end

zb=zeros(size(p,1),1);

[xc,yc]=get_centroid(pgxy.x, pgxy.y);

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
            
            if (in==1)||(on==1)
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
                    disp('÷ÿ∫œµ„');
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
                zzz=(lb*refz+la*zc)/(la+lb);
                break;
            end
        end
    end

end



