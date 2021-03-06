function InteractiveMesh(p,t,zb)
%observe a cell in a mesh
%or find a node index


hfig=figure;
if nargin==2
    patch('faces',t,'vertices',p,'facecolor','none','edgecolor','b');
    axis equal off;
elseif nargin==3
    trisurf(t,p(:,1),p(:,2),zb);
    view([0,90]);
else
    disp('invalid number of input parameters');
    return
end
hold on;

str={'Mark a cell',...
        'Find a node'};
[optype,ok]=listdlg('PromptString','Select an operation:','SelectionMode','single','ListString',str);

if optype==1
    while 1
        icell=input('input a cell index:');
        if isempty(icell)
            break;
        end
        
        hp=patch('faces',t(icell,:),'vertices',p,'facecolor','r','edgecolor','none');
    end
end

if optype==2
    nnod=size(p,1);
    while 1
        dcm_obj = datacursormode(hfig);
        dcm_obj.removeAllDataCursors();
        set(dcm_obj,'DisplayStyle','datatip',...
            'SnapToDataVertex','on','Enable','on');
        
        button=questdlg('Click line to display a data tip, then press Return.');
        if ~strcmp(button,'Yes')
            break;
        end
        % Wait while the user does this.
        pause;
        
        c_info = getCursorInfo(dcm_obj);
        for i=1:1:nnod
            if (p(i,1)==c_info(1).Position(1))&&(p(i,2)==c_info(1).Position(2))
                disp(['The node you pick is: ',num2str(i)]);
            end
        end
        
    end
end