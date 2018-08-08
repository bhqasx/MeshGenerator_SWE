function [vol,A]=Vol_A_UnderZ(p,t,zb,node,zref)


in = inpoly(p,node);
ti = sum(in(t),2)>0;

nt=size(t,1);
vol=0;
A=0;
for i=1:1:nt
    if ti(i)==1
        n1=t(i,1);
        n2=t(i,2);
        n3=t(i,3);
        zb_cell=(zb(n1)+zb(n2)+zb(n3))/3;
        if zref>zb_cell
            a_cell=polyarea(p([n1;n2;n3;n1],1),p([n1;n2;n3;n1],2));
            v_cell=a_cell*(zref-zb_cell);
            vol=vol+v_cell;
            A=A+a_cell;
        end
    end
end