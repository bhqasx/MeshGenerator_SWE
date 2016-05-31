function [nodes,arcs,polygons]=read_sms_map
%read sms map file
%arcvertices are not read by far

button=questdlg('Choose a SMS map file. Notice: change the file extension to .txt in advance','Guide','Yes');
if ~strcmp(button,'Yes')
    return;
end
filename=uigetfile;
file_id=fopen(filename);

nodes=[];
arcs=[];
nplg=0;
while ~feof(file_id)
    tline=fgetl(file_id);
    
    if strcmp(tline,'NODE')
        tline=fgetl(file_id);
        rt=textscan(tline,'%s%f%f%f');     %read node coordinates
        tline=fgetl(file_id);
        rt2=textscan(tline,'%s%f');          %read node ID
        nodes=[nodes;rt2{2},rt{2},rt{3},rt{4}];
    end
    
    if strcmp(tline,'ARC')
        tline=fgetl(file_id);
        rt=textscan(tline,'%s%f');          %read arc ID
        while isempty(strfind(tline,'NODES'))
            tline=fgetl(file_id);
        end
        rt2=textscan(tline,'%s%d%d');        %read start and end nodes of an arc
        arcs=[arcs; rt{2}, rt2{2}, rt2{3}];
    end
    
    if strcmp(tline,'POLYGON')
        tline=fgetl(file_id);
        while isempty(strfind(tline,'ARCS'))
            tline=fgetl(file_id);
            if strcmp(tline,'END')
                break;
            end
        end
        
        if ~isempty(strfind(tline,'ARCS'))
            rt=textscan(tline,'%s%d');
            if rt{2}~=0
                arcs_in_pg=zeros(rt{2},1);
                
                for i=1:1:rt{2}
                    tline=fgetl(file_id);
                    rt2=textscan(tline,'%d');
                    arcs_in_pg(i)=rt2{1}(1);
                end
                nplg=nplg+1;         %count the number of polygons
                polygons(nplg)={arcs_in_pg};
            end
        end        
    end
end




fclose(file_id); 