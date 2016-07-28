function [bd_line,nodcod]=set_bd_type(gp,nodcod)
%use Data Cursor to set boundary type for nodes on boundaries
%each run of this file will create a boundary line


hfig=figure;
patch('faces',gp.t,'vertices',gp.p,'facecolor','none','edgecolor','b');
axis equal off;

rgpp=size(gp.p,1);
if nargin==1
    nodcod=zeros(rgpp,1);           %variable to record bd types of nodes
end

hold on;
for i=1:1:rgpp
    plot_nod_bd(gp.p(i,1), gp.p(i,2), nodcod(i));
end

button='Yes';
bd_line=[];     %a sequence of node indexes defing a boundary line
while 1==1
    dcm_obj = datacursormode(hfig);
    dcm_obj.removeAllDataCursors();
    set(dcm_obj,'DisplayStyle','datatip',...
        'SnapToDataVertex','off','Enable','on');
    
    button=questdlg('Click line to display a data tip, then press Return.');
    if ~strcmp(button,'Yes')
        break;
    end
    % Wait while the user does this.
    pause;
    
    %hold Alt to pick mutiple points
    c_info = getCursorInfo(dcm_obj);
               
    str={'Flow Velocity: nodcod=1',...
        'Water Level  : nodcod=2',...
        'dep $ flow V : nodcod=3',...
        'Free BD: nodcod=4',...
        'Wall BD      : nodcod=5'};
    [bdtype,ok]=listdlg('PromptString','input boundary type:','SelectionMode','single','ListString',str);
    
    npick=size(c_info,2);
    for i=npick: -1: 1
        for j=1:1:rgpp
            if (gp.p(j,1)==c_info(i).Position(1))&&(gp.p(j,2)==c_info(i).Position(2))
                nodcod(j)=bdtype;
                plot_nod_bd(c_info(i).Position(1),c_info(i).Position(2),nodcod(j));
                
                bd_line=[bd_line;j];
                break;
            end
        end
    end
end


%-------------------------------------------------------------------
function plot_nod_bd(px,py,bdtype)
%mark the bd node according to its boundary type

switch bdtype
    case 0
        return;
    case 1
        plot(px,py,'ro');
    case 2
        plot(px,py,'go');
    case 3
        plot(px,py,'mo');
    case 4
        plot(px,py,'bo');
    case 5
        plot(px,py,'ko');
end

