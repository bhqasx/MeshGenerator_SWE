function [p,t,zb,nodcod]=ReadMesh
%读取二维浅水模型中的网格文件

[filename,path,FilterIndex]=uigetfile('','Choose a mesh file');
file_id=fopen([path,filename]);

tline=fgetl(file_id);
tline=fgetl(file_id);
tline=fgetl(file_id);
tline=fgetl(file_id);
a=textscan(tline,'%f');
nnod=a{1}(1);       %number of nodes
tline=fgetl(file_id);
tline=fgetl(file_id);
a=textscan(tline,'%f');
ntri=a{1}(1);         %number of cells
a=textscan(tline,'%f');
tline=fgetl(file_id);

p=zeros(nnod,2);
t=zeros(ntri,3);
zb=zeros(nnod,1);
nodcod=zeros(nnod,1);

for i=1:1:nnod
    tline=fgetl(file_id);
    a=textscan(tline,'%f');
    p(i,1)=a{1}(1);
    p(i,2)=a{1}(2);
    zb(i)=a{1}(7);
    nodcod(i)=a{1}(6);
end

for i=1:1:ntri
    tline=fgetl(file_id);
    a=textscan(tline,'%f');
    t(i,:)=a{1}(1:3);
end

fclose(file_id);