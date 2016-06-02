function [cs_xyz]=read_elevation


button=questdlg('Choose an elevation file','Guide','Yes');
if ~strcmp(button,'Yes')
    return;
end
filename=uigetfile;
file_id=fopen(filename);

tline=fgetl(file_id);
tline=fgetl(file_id);
rt=textscan(tline,'%f');          
ncs=rt{1};            %number of measured cross-sections
b=cell(1,ncs);
cs_xyz=struct('cs_id',b,'npt',b,'xyz',b);       %creat a struct array

for i=1:1:ncs
    tline=fgetl(file_id);
    rt=textscan(tline,'%s%f');          
    cs_xyz(i).cs_id=rt{1}{1};
    cs_xyz(i).npt=rt{2};
    cs_xyz(i).xyz=zeros(cs_xyz(i).npt,3);
    
    for j=1:1:cs_xyz(i).npt
        tline=fgetl(file_id);
        rt=textscan(tline,'%f');
        cs_xyz(i).xyz(j,:)=rt{1};
    end
end

fclose(file_id); 