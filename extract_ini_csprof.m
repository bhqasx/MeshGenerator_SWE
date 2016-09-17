function extract_ini_csprof
%extract cross section profiles from the model output files "_ObsPT xx"
%to facilitate comparing the quality of 2D topography interplation
%ntp: the number of points on every CS

[filename,path,FilterIndex]=uigetfile('MultiSelect','on');

ncs=size(filename,2);       %get the number of cross-sections
b=cell(1,ncs);
CS_array=struct('npt',b,'x',b,'zb',b);       %creat a struct array

for i=1:1:ncs
    cs_filepath=[path,filename{i}];
    file_id=fopen(cs_filepath);
    if file_id>=3
        npt=0;
        x=[];
        zb=[];
        tline=fgetl(file_id);
        tline=fgetl(file_id);
        tline=fgetl(file_id);
        tline=fgetl(file_id);
        a=textscan(tline,'%f'); 
        
        while ~isempty(a{1})
            npt=npt+1;
            
            tline=fgetl(file_id);
            x=[x;a{1}(4)];
            zb=[zb;a{1}(5)];
            
            a=textscan(tline,'%f');
        end
        CS_array(i).npt=npt;  
        CS_array(i).x=x;
        CS_array(i).zb=zb;           
        CS_array(i).zbmin=min(CS_array(i).zb);  %lowest level of a cross-section        
        
        fclose(file_id);
    end
end

%----------------------write to txt file------------------
file_id=fopen('CsProf_tmp.txt','w');

for i=1:1:ncs
    fprintf(file_id,'CS%d\n', i);
    for j=1:1:CS_array(i).npt
        fprintf(file_id, '%d     %f       %f\n', j, CS_array(i).x(j), CS_array(i).zb(j));
    end
end

fclose(file_id);