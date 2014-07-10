% This is the new video segment code
% Optionally, you can pass arguments for the current directory, and the
% files to segment
%
% new_vs(datadir, experiment, subjects, trials, motes, cams)
%  datadir: The directory containing 'norm' and 'video' directories
%  experiment: The experiment number
%  subjects: 
function new_vs(datadir)

    vs.datadir='.';
    vs.first_frame = 22;
    vs.vid_playing=false;
    vs.files=[];
    vs.andir_list={};
    vs.andir_sel=2;
    vs.andir_h=[];
    vs.candir_h = [];
    vs.candir_sel=2;
    vs.cannotations=[];
    vs.anmodified = false;
    vs.an_default = 'default';
    vs.filter_size=10;
    vs.sens_h={};
    vs.sel_sensors=[1:5];
    vs.vid_h = {};
    vs.tools_h={};
    vs.scroll_h=[];
    vs.marker_h={};
    vs.marker_pos=1;
    vs.an_rect_h=[];
    vs.an_h={};
    vs.tb_height = 0;
    vs.ncams=4;
    vs.sel_file=1;
    vs.sel_file_h=[];
    vs.data_len = 0;
    vs.motes=[];
    vs.sel_motes = [];
    vs.title='Video Segment';
    vs.margins=5; % margin size in pixels
    vs.framelist = [];
    vs.axis_pref = 1; % 1 is 'full', 2 is 'tight', 3 is 'adaptive'
    vs.jump_small=10;
    vs.jump_big=100;
    vs.bounds=[0 1]; % the zoom bounds
    vs.ylim=[]; %[sensors]x[2]
    vs.first_click=[];
    vs.clicked=false;
    vs.sel_show=false; % show selection rectangle
    vs.sel_h={}; % the selection rectangles
    vs.sel_color=[0.75 0.75 0.75];
    vs.annotations=[];
    vs.annote_colors=[1 0 0;0 1 0;0 0 1;0 0 0;1 1 0;0 1 1;1 0 1;.5 .5 .5;1 .5 .5;.5 1 .5;.5 .5 1];
    vs.annote_max = size(vs.annote_colors,1);
    vs.maxBtn_h = [];
    vs.cur_annote=1;
    vs.delete_mode = false;
    vs.saveBtn_h=[];
    
    vs.frame_cache = [];
    vs.frame_saved = 50;

    vs.sensors={
        1, 'Acc X', -2048, 2048;
        2, 'Acc Y', -2048, 2048;
        3, 'Acc Z', -2048, 2048;
        4, 'GyroA X', 0, 4096;
        5, 'GyroA Y', 0, 4096;
        6, 'GyroB X', 0, 4096;
        7, 'GyroB Y', 0, 4096};


    [vs fh] = changeDir(vs);
end

function [vs fh] = changeDir(vs)
    vs=getFiles( vs); % Get the files in the current directory
    [vs fh] = changeFile(vs, 1);
end

function [vs fh] = changeFile(vs, fnum)

    if(isempty(fnum) || fnum < 1 || fnum > numel(vs.files))
        fnum = 1;
    end

    vs.sel_file = fnum;
        
    %-- Create and populate the figure ---    
    fh = createFig(vs);
    vs = get(fh,'UserData');

    %vs.sel_file = fnum;
    set(vs.sel_file_h, 'Value', vs.sel_file);


    %--- Reset the things that need to be reset ---
    vs.andir_list={};
    vs.andir_sel=2;
    vs.anmodified = false;
    vs.bounds=[0 1]; % the zoom bounds
    vs.annotations=[];
    vs.cur_annote=1;
    vs.delete_mode = false;
    vs.marker_pos = 1; % reset marker position

    %save changes
    set(fh, 'UserData', vs);

    %--- draw things that must be changed ---
    drawData(fh);
    loadAnnotationList();
    setMarkerPos(vs.marker_pos);

    vs = get(fh,'UserData');

end


function vs = getFiles(vs)
    datadir = vs.datadir;

    % look in 'norm'
    ndir = [datadir filesep 'split'];
    vdir = [datadir filesep 'video'];

    nfiles = dir(ndir);
    nfiles=nfiles(~[nfiles.isdir]);
    nfiles={nfiles.name};

    % separate 'norm' files
    nf=regexp(nfiles, '^m([0-9]+)_s([0-9]+)_m([0-9]+)_n([0-9]+)\.txt$', 'tokens');

    %put together matrix
    mat=zeros(0,4);
    for nfi = 1:numel(nf)
        nff = nf{nfi};
        if(isempty(nff))
            continue; % no match
        end
        nff=nff{:};   
        mat = [mat; str2num(nff{1}) str2num(nff{2}) str2num(nff{3}) str2num(nff{4})];
    end

    % figure out which motes to use
    motes = unique(mat(:,4)); % unique motes
    vs.motes = motes;
    vs.sel_motes = 1:numel(motes);

    % Go through and create file list
    files=[];
    files.name='';
    mat = unique(mat(:,1:3), 'rows');
    for idx=1:size(mat,1)
        files(idx).name = sprintf('Exp %i: sub %i, mvmnt %i', mat(idx,:));
        files(idx).f={};
        files(idx).vf={};
        files(idx).af=[];
        for mote = vs.motes'
            fname = sprintf('%s%sm%04i_s%02i_m%02i_n%02i.txt', ndir, filesep, [mat(idx,:) mote]);
            files(idx).f={files(idx).f{:} fname};
        end
        for cam=1:vs.ncams
            vfname = sprintf('%s%sm%04i_s%02i_m%02i_c%02i.avi', vdir, filesep, [mat(idx,:) cam]);
            files(idx).vf={files(idx).vf{:} vfname};
        end
        afname = sprintf('m%04i_s%02i_m%02i.txt', [mat(idx,:)]); % note: this file has no prefix
        files(idx).af=afname;
    end

    vs.files = files;
end

function fh=createFig(vs)
    fh = findobj('Tag', 'VideoSegment');
    if(isempty(fh))
        fh = figure;

        %--- position in screen ---
        scrnSz = get(0, 'ScreenSize');
        figPos = scrnSz + [50 50 -100 -100];
        set(fh, 'Position', figPos);
    else
        vs2 = get(fh, 'UserData');
%         for idx=1:numel(vs2.vid_h)
%             delete(vs2.vid_h{idx});
%         end
        clf(fh);
        %set(fh, 'UserData', []);

        % make the video segment window come to the front
        ch = get(0, 'Children');
        idx = find(ch==fh,1);
        ch = [ch(idx); ch(1:idx-1); ch(idx+1:end)];
        set(0,'Children', ch);
    end
    set(fh,'pointer','fullcrosshair');



    %--- create the graphs ---
    vs.sens_h=[];
    vs.an_h={};
    vs.sel_h={};
    for g_idx = 1:numel(vs.sel_sensors)
        h = axes('Parent', fh, 'Position', [0 0 1 1]);
        s = vs.sel_sensors(g_idx);
        title(h,sprintf(vs.sensors{s,2}, g_idx));
        vs.sens_h{g_idx} = h;
    end

    %--- create the video ---
    vs.vid_h={};
    cams = vs.files(vs.sel_file).vf;
    for ci = 1:numel(cams)
        vf = cams{ci};
        if(exist(vf,'file') == 0)
            break; % this doesn't exist
        end
        vh = axes('Parent', fh, 'Position', [0 0 1 1]); % create movie display window
        vs.vid_h{ci} = vh;
    end
    
%     for g_idx = 1:vs.ncams
%         h = actxcontrol('WMPlayer.OCX.7', [0 0 320 240], fh);
%         h.settings.autoStart=0; % turn off auto-start
%         h.uiMode='none';
%         vs.vid_h{g_idx} = h;
%     end


    %--- create the toolbar ---
    curH = 18;
    curX=0;
    curY=vs.margins;
    h={};

    %*** Directory Chooser ***
    curW = 50;
    h{1} = uicontrol(fh,'Style','pushbutton', 'String', 'Dir', 'Position', [curX curY curW curH], 'Callback', @dirBtn);
    curX = curX + curW+2;

    %*** File button ***
    curW=75;
    h{2} = uicontrol(fh,'Style','text','String','Experiment','Position',[curX curY curW curH]);
    curX = curX + curW+1;
    curW=150;
    h{3} = uicontrol(fh,'Style','popupmenu', 'String', {vs.files(:).name}, 'Value', 1, 'Position', [curX curY curW curH], 'Callback', @expSelFcn );
    vs.sel_file_h=h{3};
    curX = curX + curW+2;

    %*** Mote selection button ***
    curW = 50;
    h{4} = uicontrol(fh,'Style','pushbutton', 'String', 'Motes', 'Position', [curX curY curW curH], 'Callback', @moteBtn);
    curX = curX + curW+2;

    %*** Sensor selection button ***
    curW = 50;
    h{4} = uicontrol(fh,'Style','pushbutton', 'String', 'Sensors', 'Position', [curX curY curW curH], 'Callback', @sensorsBtn);
    curX = curX + curW+2;

    %*** Axis pref ***
    curW=40;
    h{5} = uicontrol(fh,'Style','text','String','Axis','Position',[curX curY curW curH]);
    curX = curX + curW+1;
    curW=70;
    h{6} = uicontrol(fh,'Style','popupmenu', 'String', {'Full', 'Tight', 'Adaptive'}, 'Value', vs.axis_pref, 'Position', [curX curY curW curH], 'Callback', @axisBtn );
    curX = curX + curW+2;


    %*** Filter Size ***
    curW=60;
    h{7} = uicontrol(fh,'Style','text','String','Filter Size','Position',[curX curY curW curH]);
    curX = curX + curW+1;
    curW=30;
    h{8} = uicontrol(fh,'Style','edit','String',sprintf('%i', vs.filter_size),'Position',[curX curY curW curH], 'Callback', @filterFld);
    curX = curX + curW+2;

    %*** Zoom out ****
    curW = 50;
    h{9} = uicontrol(fh,'Style','pushbutton', 'String', 'Zoom Out', 'Position', [curX curY curW curH], 'Callback', @zoomOutBtn);
    curX = curX + curW+2;

    %*** Current Annotation ***
    curW = curH;
    h{10} = axes('Parent', fh,'Units', 'Pixels', 'Position',[curX curY curW curH]);
    vs.an_rect_h = rectangle('Parent', h{10}, 'Position',[0 0 curW curH], 'FaceColor', vs.annote_colors(1,:));
    axis(h{10}, 'off');
    curX = curX + curW+2;

    %*** Max Annotation pref ***
    curW=65;
    h{11} = uicontrol(fh,'Style','text','String','Cycle after','Position',[curX curY curW curH]);
    curX = curX + curW+1;
    curW=40;
    h{12} = uicontrol(fh,'Style','popupmenu', 'String', num2cell(1:size(vs.annote_colors,1)), 'Value', vs.annote_max, 'Position', [curX curY curW curH], 'Callback', @maxBtn );
    vs.maxBtn_h = h{12};
    curX = curX + curW+2;

    %*** Annotation Directory ***
    curW=65;
    h{11} = uicontrol(fh,'Style','text','String','Annotations','Position',[curX curY curW curH]);
    curX = curX + curW+1;
    curW=100;
    h{12} = uicontrol(fh,'Style','popupmenu', 'String', {vs.an_default}, 'Value', 1, 'Position', [curX curY curW curH], 'Callback', @andirFcn );
    curX = curX + curW+2;
    vs.andir_h = h{12};

    %*** Save button ***
    curW = 50;
    h{13} = uicontrol(fh,'Style','pushbutton', 'String', 'Save', 'Position', [curX curY curW curH], 'Callback', @saveBtn);
    vs.saveBtn_h=h{13};
    curX = curX + curW+2;

    %*** Compare_an ***
    curW=65;
    h{14} = uicontrol(fh,'Style','text','String','Compare to','Position',[curX curY curW curH]);
    curX = curX + curW+1;
    curW=100;
    h{15} = uicontrol(fh,'Style','popupmenu', 'String', {vs.an_default}, 'Value', 1, 'Position', [curX curY curW curH], 'Callback', @compDirFcn );
    curX = curX + curW+2;
    vs.candir_h = h{15};

    vs.tb_height = curH;
    vs.tools_h = h;

    %--- Scrollbar ---
    curX=vs.margins;
    curY = curY + (curH) + vs.margins;
    vs.scroll_h = uicontrol(fh,'Style','slider','Position',[curX curY 300 curH], 'Callback', @scrollBar);
    vs.tb_height = vs.tb_height + curH + vs.margins;


    %--- save the variables ---
    set(fh, 'UserData', vs);

    %--- remove toolbar ---
    %set(fh, 'MenuBar', 'none', 'Toolbar', 'none');

    %--- set name, and some callbacks ---
    set(fh, 'Name', vs.title, 'NumberTitle', 'off', 'ResizeFcn', @resizeFunc, 'Units', 'pixels', 'Tag', 'VideoSegment', 'keyPressFcn', @keyPressFcn);
    set(fh, 'WindowButtonDownFcn', @WindowButtonDownFcn, 'WindowButtonMotionFcn', @WindowButtonMotionFcn, 'WindowButtonUpFcn', @WindowButtonUpFcn);
    set(fh, 'CloseRequestFcn', @closeFunc);

    %--- Add the data ---
    drawData(fh); % set initial selection
    loadAnnotationList();


    resizeFunc(fh,[]);
    updateAnnoteLabel();
end


function resizeFunc(src, evt)
    fh = src;
    vs = get(fh, 'UserData');

    fPos = get(fh, 'Position');
    width=fPos(3);
    height=fPos(4);

    axBnds = vs.margins*[1 1 -2 -2] + [0 0 width height]; % bounds for the axis

    %--- Start by Resizing video ---
    vSz=[0 0];
    curY = height;
    curX = width - vSz(1) - vs.margins;
    for idx=1:numel(vs.vid_h)
        vf = vs.files(vs.sel_file).vf{idx};
        m = aviread(vf,1);

        h = vs.vid_h{idx};
        
        lSz = size(m(1).cdata);
        lSz = lSz([2 1]); % set X Y appropriately
        
        curX = width - lSz(1) - vs.margins;
        curY = curY - lSz(2) - vs.margins;
        
        set(h, 'Units', 'pixels', 'Position', [curX curY lSz(1) lSz(2)]);
        
        vSz = max([vSz; lSz]);
    end
    axBnds(3) = axBnds(3) - vs.margins - vSz(1);

    %--- Now, Move the toolbar ---
    axBnds(4) = axBnds(4) - vs.margins - vs.tb_height;
    axBnds(2) = axBnds(2) + vs.tb_height + vs.margins;


    %--- Then Resize the graphs ---
    curY=axBnds(2)+axBnds(4) + vs.margins;
    curX=axBnds(1);
    curH = floor((axBnds(4)-(numel(vs.sens_h)+1)*vs.margins)/numel(vs.sens_h)); % calculate height of each axis
    for idx=1:numel(vs.sens_h)
        h = vs.sens_h{idx};
        curY = curY - vs.margins - curH;
        x=[axBnds(1) curY axBnds(3) curH];
        set(h, 'Units', 'pixels');
        xd=get(h,'TightInset');
        x = x + [xd(1:2) -xd(3:4)-xd(1:2)];
        %get(h,'Position')
        set(h,'Position', x);
    end
    axBnds = x;

    %--- Resize scrollbars ---
    h = vs.scroll_h;
    x = get(h,'Position');
    x = [axBnds(1) x(2) axBnds(3) x(4)];
    set(h, 'Position', x);

end


function closeFunc(src, evt)
    if(~saveCheck)
        delete(src);
    end
end

% called for the experiment selection menu
function expSelFcn(src, evt)
    fh = get(src, 'Parent');
    vs = get(fh, 'UserData');

    fnum = get(vs.sel_file_h,'Value');
    if(vs.sel_file==fnum) % nothing changed, do nothing
        return;
    end
    cancel = saveCheck();
    if(cancel)
        set(src,'Value', vs.sel_file);
    else
        changeFile(vs, fnum);
    end
    vs = get(fh,'UserData');
end

function drawData(fh)
    vs = get(fh, 'UserData');
    colors='rgbcmyk';
    sens_base=15-1;

    pos = getMarkerPos();

    if(vs.sel_file < 1 || vs.sel_file > numel(vs.files))
        return; % a bad index
    end

    %--- Clear each axis ---
    for idx=1:numel(vs.sens_h)
        cla(vs.sens_h{idx});
    end

    %--- Draw the selection rectangles ---
    for si=1:numel(vs.sens_h)
        vs.sel_h{si} = rectangle('Position', [0 0 1 1], 'EdgeColor', 'none', 'FaceColor', 'none','Parent',vs.sens_h{si});
    end

    %--- Gather all data ---
    data_len=-1;
    file = vs.files(vs.sel_file);
    files = file.f(vs.sel_motes);
    didx=1;
    adata=cell(numel(files),1);
    for idx=1:numel(files)
        f = files{idx};
        adata{idx}=[];
        if(exist(f) ~= 2)
            continue;
        end
        data=dlmread(f,' ');
        if(size(data,1)<1)
            continue;
        end
%          sensor_start_idx = find(data(:,vs.first_frame)==0, 1 , 'last')+1;
%          if(numel(sensor_start_idx) < 1)
%              sensor_start_idx = 1;
%          end
%          data = data(sensor_start_idx:end,:);
        if(data_len==-1)
            data_len = size(data,1);
        else
            data_len = min(size(data,1), data_len);
        end

        if(vs.filter_size > 1) % filter the data
            data(:,15:21) = mov_avg(data(:,15:21), vs.filter_size);
        end
        
        
        %data(:,sens_base + 2) = atan( (data(:,sens_base + 2) - 240) ./ data(:,sens_base + 3) );
        adata{didx}=data;
        didx=didx+1;
    end
    vs.data_len = data_len;

    %--- Create the framelist ---
    flist_all = [];
    for data_idx = 1:numel(adata)
        data = adata{data_idx};
        if(numel(data)==0)
            continue;
        end
        fl = data(1:data_len,vs.first_frame:end);
        flist_all = cat(3, flist_all, fl);
    end
    flst = mean(flist_all,3);
%      figure;
%      plot(squeeze(flist_all(1:50,1,:)));
%     data = adata{1};
%     if(vs.first_frame > 1)
%         flst = data(1:data_len,vs.first_frame:end);
%     else
%         flst = data(1:data_len,vs.first_frame);
%     end
    vs.framelist={};
    for cam = 1:size(flst,2);
        fr = [[1:size(flst,1)]' flst(:,cam)]; % get the framelist for this camera
        fr([false; fr(1:end-1,2)>=fr(2:end,2)],:) = []; % make the framelist represent only the first frame
        vs.framelist={vs.framelist{:} fr};
    end

    %--- Draw all the data ---
    vs.ylim=zeros(numel(vs.sel_sensors),2);
    vs.ylim(:,1)=Inf;
    vs.ylim(:,2)=-Inf;
    for idx=1:numel(adata)
        mnum = vs.sel_motes(idx);

        data = adata{idx};
        if(size(data,1)==0)
            continue;
        end
        data=data(1:data_len,:);
        color = colors(mod(mnum-1,numel(colors))+1);
        for sens=1:numel(vs.sel_sensors)
            s = vs.sel_sensors(sens);
            h = vs.sens_h{sens};
            hold(h, 'on');
            
            plot(1:data_len, data(:,sens_base + s), color, 'Parent', h);
            vs.ylim(sens, 1) = min( [vs.ylim(sens, 1);data(:,sens_base + s)]);
            vs.ylim(sens, 2) = max( [vs.ylim(sens, 2);data(:,sens_base + s)]);        
            set(h, 'XLim', [1 data_len]);
        end
    end

    %--- Load the video ---
    for idx=1:numel(vs.vid_h)
        h = vs.vid_h{idx};
        vf = vs.files(vs.sel_file).vf{idx};
        m = aviread(vf,1);
        image(m.cdata,'Parent', h); % set to the first frame
        axis(h,'off');
    end


    %--- Draw video frame indicator ---
    mh = cell(numel(vs.sel_sensors), 2);
    for idx = 1:size(mh,1)
        s = vs.sel_sensors(idx);
        mh{idx,1} = plot(vs.marker_pos, vs.sensors{s,4}, 'rv', 'Parent', vs.sens_h{idx}, 'MarkerFaceColor', [1 0 0]);
        mh{idx,2} = plot(vs.marker_pos, vs.sensors{s,3}, 'r^', 'Parent', vs.sens_h{idx}, 'MarkerFaceColor', [1 0 0]);
    end
    vs.marker_h = mh;


    %--- Save data ---
    set(fh, 'UserData', vs);

    updateSlider();
    setAxesZoom();
    drawAnnotations()

    setAxis(); % set the y-axis
    pause(1/4);
    setPos(pos);
end

function moteBtn(src, event)
    fh = get(src, 'Parent');
    vs = get(fh, 'UserData');

    listStr={};
    for mote=vs.motes'
        listStr = {listStr{:} sprintf('Mote %i', mote)};
    end
    sel = listdlg('ListString', listStr, 'InitialValue', vs.sel_motes, 'PromptString', 'Select Motes');
    if(isempty(sel))
        return;
    end

    vs.sel_motes = sel;
    set(fh, 'UserData', vs);

    vs.marker_pos

    drawData(fh);

    end

    function saveBtn(src,evt)
    saveAnnotations();
end

function sensorsBtn(src, event)
    fh = get(src, 'Parent');
    vs = get(fh, 'UserData');

    listStr=vs.sensors(:,2);
    sel = listdlg('ListString', listStr, 'InitialValue', vs.sel_sensors, 'PromptString', 'Select Sensors');
    if(isempty(sel))
        return;
    end

    vs.sel_sensors = sel;
    set(fh, 'UserData', vs);

    createFig(vs);
    end

    function axisBtn(src, event)
    fh = get(src, 'Parent');
    vs = get(fh, 'UserData');

    vs.axis_pref = get(src,'Value');
    if(~ismember(vs.axis_pref, [1:3]))
        vs.axis_pref = 1;
    end
    set(fh, 'UserData', vs);

    setAxis();
    drawAnnotations();
end

function maxBtn(src, event)
    fh = getfh();
    vs = get(fh, 'UserData');

    vs.annote_max = get(src,'Value');
    set(fh, 'UserData', vs);

    setAnnoteLabel(getAnnoteLabel());
end

function zoomOutBtn(src, event)
    fh = get(src, 'Parent');
    vs = get(fh, 'UserData');

    mid = (vs.bounds(1) + vs.bounds(2))/2;
    amt = (vs.bounds(2) - vs.bounds(1));

    bnds = [mid-amt*2 mid+amt*2];
    if(bnds(1) < 0)
        bnds(1) = 0;
    end
    if(bnds(2) > 1)
        bnds(2) = 1;
    end

    vs.bounds = bnds;
    set(fh, 'UserData', vs);
    updateSlider();
    setAxesZoom();
end

function dirBtn(src, event)
    fh = get(src, 'Parent');
    vs = get(fh, 'UserData');

    cancel = saveCheck();
    if(cancel)
        return;
    end

    my_dir = uigetdir(vs.datadir, 'Choose a directory containing the video and norm directories');
    if(isstr(my_dir) && isdir(my_dir))
        vs.datadir = my_dir;
        changeDir(vs);
    end

end

function filterFld(src, event)
    fh = get(src, 'Parent');
    vs = get(fh, 'UserData');

    % get value and limit to 1 -> 100 
    val = floor(str2num(get(src,'String')));
    if(val < 1)
        val=1;
    elseif(val > 100)
        val=100;
    end

    % set the filter size
    vs.filter_size = val;

    % set the text box to reflect the actual value
    set(src,'String', sprintf('%i',vs.filter_size));

    % save the data
    set(fh, 'UserData', vs);

    % redraw graph
    drawData(fh);
end

function frame = pos2frame(pos, cam)
    fh=getfh();
    vs = get(fh,'UserData');

    if(cam < 1 || cam > numel(vs.framelist))
        frame=-1; % no frame for this camera
        return;
    end
    fr = vs.framelist{cam};
    frame = interp1(fr(:,1), fr(:,2), pos, 'linear', 'extrap');
end

function pos = frame2pos(frame, cam)
    fh=getfh();
    vs = get(fh,'UserData');
    
    if(cam < 1 || cam > numel(vs.framelist))
        pos=-1; % no frame for this camera
        return;
    end
    
    fr = vs.framelist{cam};    
    pos = interp1(fr(:,2), fr(:,1), frame, 'linear', 'extrap');
end

function newPos = setPos(pos)
    pos = validatePos(pos);
    setMarkerPos(pos);

    setVideoPos(pos);

    newPos = getMarkerPos();
end

% change the position of video and marker
function newPos = advancePos(delta_pos)
    pos = getMarkerPos();
    newPos = setPos(pos+delta_pos);
end

function pos = getMarkerPos()
    fh = getfh();
    vs = get(fh, 'UserData');

    pos = vs.marker_pos;
end

function pos = validatePos(pos)
    fh = getfh();
    vs = get(fh, 'UserData');

    if(pos < 1)
        pos = 1;
    elseif(pos > vs.data_len)
        pos = vs.data_len;
    end
end

function setMarkerPos(pos)
    fh = getfh();
    vs = get(fh, 'UserData');

    pos=validatePos(pos);    

    vs.marker_pos=pos;
    for idx = 1:size(vs.marker_h,1)
        h = vs.marker_h(idx,:);
        set(h{1}, 'XData', pos);
        set(h{2}, 'XData', pos);
    end
    set(fh,'UserData', vs);

end

function setVideoPos(pos)
    fh = getfh();
    vs = get(fh,'UserData');
    
    pos = validatePos(pos);
    
    for cam = 1:numel(vs.vid_h)
        frame = pos2frame(pos,cam);
        setVideoFrame(frame, cam);
    end
end

function setVideoFrame(frame, cam)
    fh = getfh();
    vs = get(fh,'UserData');
    
    sf=vs.frame_saved;
    
    if(cam < 1 || cam > numel(vs.vid_h))
        return;
    end
    
    h = vs.vid_h{cam};
    frame = round(frame);
    
    frame_cache = get(h, 'UserData');
    
    if(isempty(frame_cache) || frame < frame_cache.first || frame > frame_cache.last)
        vf = vs.files(vs.sel_file).vf{cam};
        ii = aviinfo(vf);
        
        frame_cache.first = frame;% - sf;
        frame_cache.last = frame+sf;
        if(frame_cache.first < 1)
            frame_cache.first = 1;
        end
        if(frame_cache.last > ii.NumFrames)
            frame_cache.last = ii.NumFrames;
        end
        if(frame < frame_cache.first || frame > frame_cache.last)
            return;
        end
        
        frame_cache.mov = aviread(vf, [frame_cache.first:frame_cache.last]);
        
    end
    
    fi = frame - frame_cache.first + 1;
    
    image(frame_cache.mov(fi).cdata,'Parent', h); % set to the first frame
    axis(h,'off');
    set(h, 'UserData', frame_cache);
        

end

function frame=getVideoFrame(cam)
    frame=pos2frame(getMarkerPos(), cam);
end

function advanceFrame(frames, cam)
    frame = frames + round(getVideoFrame(cam));
    pos = frame2pos(frame,cam);
    setPos(pos);
end


function fh=getfh()
    fh = findobj('Tag', 'VideoSegment');
end


function avg=mov_avg(data, filter_size)
    filt = ones(filter_size,1);
    avg = conv2(data,filt, 'valid');
        
    half_filter = floor(filter_size/2);
    avg = [repmat(avg(1,:), half_filter,1); avg; repmat(avg(end,:), filter_size-half_filter-1,1)]/filter_size;
end

function setAxis()
    fh = getfh();
    vs = get(fh,'UserData');

    ylim_all = getylim();
    for idx=1:numel(vs.sens_h)
        h = vs.sens_h{idx};
        s = vs.sel_sensors(idx);
        sx = vs.sensors(s,:);

        ylim = ylim_all(idx,:);

        set(h, 'YLim', ylim); % do this so markers can get set without disappearing
        my_eps = (ylim(2) - ylim(1))/1000;
        if(size(vs.marker_h,1) >= idx)
            set(vs.marker_h{idx,1}, 'YData', ylim(2)-my_eps);
            set(vs.marker_h{idx,2}, 'YData', ylim(1)+my_eps);
        end
        %set(h, 'YLim', ylim);

    end
    
    drawAnnotations();

end

function keyPressFcn(src,evt)
    fh = getfh();
    vs = get(fh, 'UserData');

    stop_play = false;
    switch(evt.Key)
        case 'rightarrow' % move a little to the right
            stop_play = true;
            if(strcmp(evt.Modifier,'shift'))
                advancePos(1); % if shift is pressed, move just one sample
            else
                advanceFrame(1,1); % otherwise move several
            end
        case 'leftarrow' % move a little to the left
            stop_play = true;
            if(strcmp(evt.Modifier,'shift'))
                advancePos(-1); % if shift is pressed, move just one sample
            else
                advanceFrame(-1,1); % otherwise move several
            end
        case 'uparrow' % play the video
            %advancePos(vs.jump_big);
            if(~vs.vid_playing)
                playVideo(1,1)
            else
                stop_play = true;
            end
        case 'downarrow' % play the video at 1/3 speed
            %advancePos(vs.jump_big);
            if(~vs.vid_playing)
                playVideo(1,1/3)
            else
                stop_play = true;
            end
        case 'space'
            addAnnotation();
        case 'd'
            vs = get(fh,'UserData');
            vs.delete_mode = ~vs.delete_mode;
            set(fh,'UserData',vs);
            updateAnnoteLabel();
        otherwise
            if(~isempty(evt.Character) && evt.Character <= '9' && evt.Character >= '1')
                label = evt.Character-'0';
                setAnnoteLabel(label);
            end
    end
    
    if(stop_play)
        vs = get(fh,'UserData');
        vs.vid_playing=false;
        set(fh,'UserData',vs);
    end

end

function WindowButtonDownFcn(src, evt)
    fh = getfh();
    vs = get(fh,'UserData');

    x=floor(getPointPos());
    first_click = x;
    sel_show = false;
    clicked=true;

    setPos(x);

    stype = get(fh,'SelectionType');


    if(strcmp(stype,'alt'))
        if(~vs.delete_mode)
            addAnnotation();
            clicked=false;
        else
            sel_show = true;
        end
    elseif(strcmp(stype, 'extend'))
        sel_show = true;
    end

    vs = get(fh,'UserData');
    vs.first_click = first_click;
    vs.clicked = clicked;
    vs.sel_show = sel_show;
    vs.vid_playing=false;
    set(fh,'UserData',vs);

    drawSelRect();

end

function WindowButtonMotionFcn(src, evt)
    fh = getfh();
    vs = get(fh, 'UserData');

    if(vs.clicked)
        x=getPointPos();
        setPos(x);
        drawSelRect();
        drawnow();
    end
end

function WindowButtonUpFcn(src, evt)
    fh = getfh();
    vs = get(fh, 'UserData');

    vs.clicked = false;
    vs.sel_show = false;
    set(fh, 'UserData', vs);

    sel = get(src,'SelectionType');
    if(strcmp(sel, 'extend'))
        x=floor(getPointPos());
        setZoom(vs.first_click, x);
    elseif(strcmp(sel,'alt'))
        if(vs.delete_mode)
            deleteAnnotations(vs.first_click, floor(getPointPos()));
            vs = get(fh,'UserData');
            vs.delete_mode = false;
            set(fh,'UserData',vs);
            updateAnnoteLabel();
        end
    end
    drawSelRect();
end

function pos = getPointPos()
    fh = getfh();
    vs = get(fh, 'UserData');

    pos=get(vs.sens_h{1}, 'CurrentPoint');
    pos = pos(1);

end

% set zoom from sample 1 to sample 2
function setZoom(s1, s2)
    fh = getfh();
    vs = get(fh, 'UserData');

    if(s1 < 1)
        s1=1; % first sample must be >= 1
    end
    if(s2 > vs.data_len)
        s2 = vs.data_len; % second must not be beyond data
    end
    if(s1 >= s2) % in this case, zoom out completely
        vs.bounds=[0 1];
    elseif(vs.data_len < 2)
        vs.bounds = [0 1];
    else % ok, set the bounds for real
        vs.bounds=[s1-1 s2-1]/(vs.data_len-1);
    end

    % save the data
    set(fh,'UserData',vs);

    % set the slider
    updateSlider();

    % Set Axes
    setAxesZoom();
end

function setAxesZoom()
    fh = getfh();
    vs = get(fh, 'UserData');

    sbnds = round(vs.bounds*(vs.data_len - 1) + 1); % find the sample bounds
    for idx=1:numel(vs.sens_h)
        h = vs.sens_h{idx};
        set(h, 'XLim', sbnds);
    end
%     ylim = getylim();
% 
%     for idx=1:numel(vs.sens_h)
%         h = vs.sens_h{idx};
%         set(h, 'YLim', ylim(idx,:));
%     end
    setAxis();

end

function scrollBar(src, evt)
    fh = getfh();
    vs = get(fh, 'UserData');
    
    x = get(src, 'Value');
    if(x < 0)
        x = 0;
    elseif(x > 1)
        x=1;
    end

    % determine zoomPos;
    amt = vs.bounds(2) - vs.bounds(1);
    vs.bounds = [0 amt]+x*(1-amt);

    % save data
    set(fh, 'UserData', vs);

    %update slider
    setAxesZoom();

end

function updateSlider()
    fh = getfh();
    vs = get(fh, 'UserData');

    bjump_size = vs.bounds(2) - vs.bounds(1);
    sjump_size = 0.01;

    val = vs.bounds(1)/(1-bjump_size);

    set(vs.scroll_h, 'SliderStep', [sjump_size bjump_size], 'Value', val, 'Min', 0, 'Max', 1);
    if(bjump_size == 1)
        set(vs.scroll_h, 'Enable', 'off');
        set(vs.tools_h{9}, 'Enable', 'off'); % zoom button
    else
        set(vs.scroll_h, 'Enable', 'on');
        set(vs.tools_h{9}, 'Enable', 'on'); % zoom button
    end
    end

    function label = getAnnoteLabel()
    fh = getfh();
    vs = get(fh, 'UserData');

    label = vs.cur_annote;

end

function color = getAnnoteColor()
    fh = getfh();
    vs = get(fh, 'UserData');

    label = vs.cur_annote;
    color = vs.annote_colors(label,:);
end

function setAnnoteLabel(label)
    fh = getfh();
    vs = get(fh, 'UserData');

    n = vs.annote_max;

    while(label < 0)
        label = label + n;
    end
    label = mod(label-1,n)+1;

    vs.cur_annote = label;

    set(fh,'UserData',vs);
    updateAnnoteLabel();
end

% update the square
function updateAnnoteLabel()
    fh = getfh();
    vs = get(fh, 'UserData');

    if(vs.delete_mode)
        color=[1 1 1];
    else
        color = getAnnoteColor();
    end
    set(vs.an_rect_h, 'FaceColor', color);

end

% adds annotation at the current position
function addAnnotation()
    fh = getfh();
    vs = get(fh, 'UserData');

    % don't allow annotation adding if in delete mode
    if(vs.delete_mode)
        return;
    end

    pos = getMarkerPos();
    label = getAnnoteLabel();

    vs.annotations=[vs.annotations; pos label];

    vs.anmodified=true;
    set(fh,'UserData',vs);

    drawAnnotations();
    setAnnoteLabel(getAnnoteLabel()+1);
end

% deletes annotations between the two time periods
function deleteAnnotations(x1, x2)
    fh = getfh();
    vs = get(fh, 'UserData');

    % make sure x1 is the smaller one
    if(x1 > x2)
        t=x2;
        x2=x1;
        x1=t;
    end

    vs.anmodified=true;
    vs.annotations((vs.annotations(:,1) >= x1) & (vs.annotations(:,1) <= x2),:)=[];
    set(fh,'UserData',vs);
    drawAnnotations();

end

function drawAnnotations()
    fh = getfh();
    vs = get(fh, 'UserData');

    if(isempty(vs.annotations))
        vs.annotations = zeros(0,2);
    end

    % figure out the maximum annotation that needs to be supported
    amax = max(vs.annotations(:,2));
    smax = numel(vs.sens_h);
    if(size(vs.annotations,1)>0 && (size(vs.an_h,1)<smax || size(vs.an_h,2) < amax))
        vs.an_h{smax,amax}=[];
    end

    % actually draw the damn things
    for label = 1:size(vs.an_h,2)
        if(label > size(vs.annote_colors,1))
            break; % can't draw something without a color
        end
        color = vs.annote_colors(label,:);

        an = vs.annotations(vs.annotations(:,2)==label,:);
        an1 = vs.cannotations(vs.cannotations(:,2) == label,:);

        % figure out x and y vectors
        x = zeros(3,size(an,1) + size(an1,1));
        y0=x;
        if(size(x,2)>0)
            x(1,:) = [an(:,1);an1(:,1)];
            x(2,:) = [an(:,1);an1(:,1)*nan];
            x(3,:) = nan;
        end
        x = reshape(x,[],1);

        ylim_all = getylim();
        for si = 1:size(vs.an_h,1)
            sh = vs.sens_h{si};
            ylim = ylim_all(si,:);

            h = vs.an_h{si,label};
            if(isempty(h) || ~ishandle(h))
                h = plot([1],[1], 'Parent', sh);
            end

            y=y0;
            if(size(y,2) > 0)
                y(1,1:size(an)) = ylim(1);
                y(2,1:size(an)) = ylim(2);
                y(1,(size(an)+1):end) = (ylim(1)+ylim(2))/2;
                y(2,(size(an)+1):end) = nan;

                y(3,:) = nan;
            end
            y = reshape(y,[],1);

            set(h,'XData',x,'YData',y,'Color', color, 'Marker', 'x', 'LineWidth', 1.5);
            vs.an_h{si,label}=h;
        end
    end

    % save data
    set(fh,'UserData',vs);

    if(vs.anmodified)
        val = 'on';
    else
        val = 'off';
    end
    set(vs.saveBtn_h,'Enable', val);

end

function drawSelRect()
    fh=getfh();
    vs = get(fh,'UserData');

    %--- figure out the bounds ---
    bounds=[0 0 0 0];
    ylim = getylim();

    x1=getPointPos();
    x2 = vs.first_click;
    if(x2 < x1)
        t=x2;
        x2 = x1;
        x1=t;
    end
    bounds(1) = x1;
    bounds(3) = x2 - x1;

    if(vs.sel_show )
        faceColor = vs.sel_color;
    else
        faceColor = 'none';
    end
    if(bounds(3) <1)
        faceColor = 'none';
        bounds(3)=1;
        bounds(4)=1;
    end

    %--- Loop through sensors, setting the selection rectangles ---
    for si=1:numel(vs.sel_h)
        h = vs.sel_h{si};

        bounds(2) = ylim(si,1);
        bounds(4) = ylim(si,2)-ylim(si,1);

        set(h,'Position', bounds, 'FaceColor', faceColor);
    end


    vs.sel_show=false; % show selection rectangle
    vs.sel_h={}; % the selection rectangles
    vs.sel_color=[0.75 0.75 0.75];
end

function ylim = getylim()
    fh = getfh();
    vs = get(fh,'UserData');

    if(vs.axis_pref==1)
        ylim = cell2mat(vs.sensors(vs.sel_sensors,3:4));
    elseif(vs.axis_pref==2)
        ylim = vs.ylim;
    else
        ylim = vs.ylim;
        for idx=1:numel(vs.sens_h)            
            h = vs.sens_h{idx};
            xlim = get(h,'XLim');
            yl=[Inf -Inf];
            
            hc_all = get(h, 'Children');
            
            for hc_idx = 1:numel(hc_all)
                hc = hc_all(hc_idx);
                if(~strcmp('line', get(hc,'Type')) || ismember(hc, [cell2mat(vs.marker_h) cell2mat(vs.an_h)]))
                    continue;
                end
                
                xd = get(hc,'XData');
                yd = get(hc,'YData');
                
                yd = yd(xd <= xlim(2) & xd >= xlim(1));
                yl(1) = min([yd, yl(1)]);
                yl(2) = max([yd, yl(2)]);
            end
            if(yl(1) < yl(2))
                ylim(idx,:) = yl;
            end
        end
    end
end

% This function can be called either on loading a new file
% or even just periodically.
%
% The goal is to load the list of annotation sets. The annotation set
% 'default' must always exist and be second on the list. The first in the
% list is "new..." and can't be actively selected. See
% 'loadAnnotations()' 
function loadAnnotationList()
    fh = getfh();
    vs = get(fh,'UserData');

    must_load = false;

    %--- Make sure directories exist ---
    andir = [vs.datadir filesep 'annotations'];
    defan = [andir filesep vs.an_default];
    if(exist(andir,'dir') == 0)
        % doesn't exist, create
        mkdir(andir);
    end
    if(exist(defan,'dir') == 0)
        mkdir(defan); % make sure that the annotations directory exists
    end

    %save old selection
    if(vs.andir_sel > 1 && vs.andir_sel <= numel(vs.andir_list))
        oldsel = vs.andir_list{vs.andir_sel};
    else
        oldsel = ''; % The old thing had to disappear
    end

    %--- get listing ---
    files = dir(andir);
    % remove nondirectories
    files = files([files.isdir]);
    % remove anything in the prohibitted list
    files = files(~ismember({files.name}, {'.', '..', vs.an_default}));
    % create list of names
    vs.andir_list={'New...', vs.an_default, files.name};

    %--- select the proper item ---
    sel = find(strcmp(oldsel, vs.andir_list),1, 'first');
    if(isempty(sel))
        vs.anmodified = false; % having to switch
        sel = 2;
        must_load = true;
    else
        vs.andir_sel = sel;
    end
    set(fh, 'UserData',vs);

    set(vs.andir_h, 'String', vs.andir_list, 'Value', vs.andir_sel);

    loadCAnnotationList();
    if(must_load)
        loadAnnotations(sel); % load the annotations
    end

end

function loadCAnnotationList()
    fh = getfh();
    vs = get(fh,'UserData');

    oldlist = get(vs.candir_h,'String');
    if(vs.candir_sel < 1 || vs.candir_sel > numel(oldlist))
        old_sel = 'None';
    else
        old_sel = oldlist{vs.candir_sel};
    end

    newlist = vs.andir_list;
    newlist{1} = 'None';

    newsel = find(strcmp(old_sel, newlist),1, 'first');
    if(isempty(newsel) || newsel < 1)
        newsel = 1;
    end

    vs.candir_sel = newsel;

    set(vs.candir_h, 'String', newlist, 'Value', newsel);
    set(fh,'UserData',vs);

    loadCAnnotations();
end

function loadAnnotations(sel_num)
    cancel = saveCheck();
    fh=getfh();
    vs=get(fh,'UserData');

    if(cancel) % ok, switch the annotations back
        set(vs.andir_h, 'Value', vs.andir_sel);
    else % user didn't cancel, we should load the annotations

        if(sel_num==1) % the user wants to create a new annotation
            bad_choice = false;
            aname = inputdlg('Create a new annotation set','Create Annotation',1,{'untitled1'}); % ask for file name
            if(numel(aname) > 0)
                aname = aname{1};
            end
            isgood=regexp(aname,'^[A-Za-z]+[-A-Za-z0-9_]*$'); %is the file good?
            if(isempty(isgood) || ~isgood)
                bad_choice = true;
                aname = vs.an_default;
            else
                if(exist(aname,'dir')==0)
                    andir = [vs.datadir filesep 'annotations' filesep aname];
                    mkdir(andir);
                end
            end

            % now select it for loading
            vs=get(fh,'UserData');
            vs.andir_sel=2;
            vs.andir_list={'',aname};
            set(fh,'UserData',vs);
            loadAnnotationList();
            vs=get(fh,'UserData');
            loadAnnotations(vs.andir_sel);

            return;

        end
        if(sel_num < 2 || sel_num > numel(vs.andir_list))
            sel_num = 2;
        end
        vs.anmodified = false; % we're loading, so reset the modification stuff
        vs.andir_sel = sel_num;

        % find the filename
        aname = vs.andir_list{vs.andir_sel};
        andir = [vs.datadir filesep 'annotations' filesep aname];
        afname = [andir filesep vs.files(vs.sel_file).af];

        if(exist(afname,'file')==0)
            vs.annotations=zeros(0,2);
        else
            vs.annotations=dlmread(afname,',');
        end
        if(size(vs.annotations,1) > 1)
            vs.annote_max = max(vs.annotations(:,2));
            set(vs.maxBtn_h,'Value',vs.annote_max);
        end

        set(fh,'UserData',vs);
    end
    set(vs.andir_h, 'Value', vs.andir_sel);
    drawAnnotations();
end

function loadCAnnotations()
    fh=getfh();
    vs=get(fh,'UserData');

    if(vs.candir_sel==1)
        vs.cannotations=zeros(0,2);
    else
        aname = vs.andir_list{vs.candir_sel};
        andir = [vs.datadir filesep 'annotations' filesep aname];
        afname = [andir filesep vs.files(vs.sel_file).af];

        if(exist(afname,'file')==0)
            vs.cannotations=zeros(0,2);
        else
            vs.cannotations=dlmread(afname,',');
        end
    end
    set(fh,'UserData',vs);
    drawAnnotations();
end


function saveAnnotations()
    fh=getfh();
    vs=get(fh,'UserData');

    if(vs.anmodified==false)
        return; % nothing to do
    end

    % get the filename
    aname = vs.andir_list{vs.andir_sel};
    andir = [vs.datadir filesep 'annotations' filesep aname];
    afname = [andir filesep vs.files(vs.sel_file).af];

    % save the annotations
    an = sortrows(vs.annotations,1);
    an = an(an(:,1) >= 1 & an(:,1) <= vs.data_len,:);
    dlmwrite(afname,an,',');

    vs.anmodified = false;
    set(fh,'UserData',vs);

    drawAnnotations();

end


% if cancel is true, the action that initiated this should be canceled,
% else it should proceed
function cancel = saveCheck()
    fh=getfh();
    vs = get(fh,'UserData');

    cancel = false;
    if(~vs.anmodified)
        return; % nothing to save
    end

    rep = true;
    while(rep)
        rep = false;
        res=questdlg('Do you wish to save annotations?','Save Annotations','Save','Revert','Cancel','Save');
        switch(res)
            case 'Save'
                saveAnnotations();
            case 'Revert'
                vs = get(fh,'UserData');
                vs.anmodified=false;
                set(fh,'UserData',vs);
            case 'Cancel'
                cancel = true;
            otherwise
                rep=true; % repeat again
        end
    end

end

function andirFcn(src, evt)
    fh=getfh();
    vs = get(fh,'UserData');

    loadAnnotations(get(src,'Value'));

end

function compDirFcn(src, evt)
    fh=getfh();
    vs = get(fh,'UserData');
    vs.candir_sel = get(src,'Value');
    set(fh,'UserData',vs);

    loadCAnnotations();

end

function playVideo(cam, rate_factor)
    fh = getfh();
    vs = get(fh,'UserData');
    vs.vid_playing = true;
    set(fh,'UserData',vs);
    
    if(cam < 1 || cam > numel(vs.vid_h))
        return;
    end
    
    vf = vs.files(vs.sel_file).vf{cam};
    fi = aviinfo(vf);
    rate = rate_factor * fi.FramesPerSecond;
    
    td=[];
    td.rate = rate;
    td.cam = cam;
    
    period=round(1000/rate)/1000;
    t = timer('ExecutionMode','fixedRate', 'Period', period, 'UserData', td, 'TimerFcn', @playVideoFcn);
    start(t);
end

function playVideoFcn(src, evt)
    fh = getfh();
    vs = get(fh,'UserData');
    td = get(src,'UserData');
    
    if(vs.vid_playing)
        old_pos = getMarkerPos();
        advanceFrame(1,td.cam);
        drawnow();
        pos = getMarkerPos();
    end
    
    if(~vs.vid_playing || pos==old_pos)
        stop(src);
        delete(src);
    end

end






