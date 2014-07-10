% parameter filename: filename (minus extension) to be used to record data.
% empty string or no parameter disables recording
function rtd_plot3(varargin, motes, com_port)
persistent my_h sensors my_axis highlight_missing curtime cons_h seg_h fid is_paused;

% com_port = 'com11';
% motes=[6];
highlight_missing = false; % highlight missing packets
seconds=4; % number of seconds to display on screen
time_between_update=1/10;
time_offset=0; % amount to jump forward every update
missing_timeout = 1; % flag a problem if a mote is missing for more than 1 second
plot_consistency = false;
sensors = [1 2 3 4 5];

if (plot_consistency)
    cons_time = 1;
    leg_motes = [1]; % indexes of leg motes
    cons_ref_axis = 4; % reference axis for segmentation
    cons_left= 1; % index of left reference mote
    cons_right = 1; % index of right reference mote
end

colors='rgbcmyk';
sensor_names={'X Acceleration', 'Y Acceleration', 'Z Acceleration', 'X Angular Velocity', 'Y Angular Velocity', 'Z Angular Velocity', 'Z Angular Velocity'};
bounds=[-2048 2048; -2048 2048; -2048 2048; 0 4096; 0 4096; 0 4096; 0 4096];

% regular window
reg_fig = figure;
is_paused = false;
set(reg_fig,'Renderer', 'painters', 'CloseRequestFcn', @my_window_close, 'WindowButtonDownFcn', @my_window_pause);

% consistency window
if (plot_consistency)
   cons_fig = figure;
   set(cons_fig,'Renderer', 'painters', 'CloseRequestFcn', @my_window_close, 'WindowButtonDownFcn', @my_window_pause);
end

%setup figure 
figure(reg_fig);
my_h = cell(numel(motes), numel(sensors));

my_axis = cell(numel(sensors),1);
for sensor = 1:numel(sensors)
    subplot(numel(sensors),1,sensor);

    hold on;
    x=-seconds;
    y =0;
    for mote = 1:numel(motes)
        my_h{mote,sensor} = plot(x,y,colors(mod(mote-1,numel(colors))+1));
    end
    title(sensor_names{sensors(sensor)});
    axis([-seconds 0 bounds(sensors(sensor),:)]);
    my_axis{sensor} = gca;
    set(gca,'XLimMode', 'manual','YGrid','on','YTick',[-4096 -2048 0 2048 4096]);
end

if (plot_consistency)
    % setup consistency figure
    figure(cons_fig);
    hold on;
    cons_h={};
    cons_h{1}=plot(1,1);
    hold on;
    cons_h{2}=plot(1,1, 'ro ');
    
    % setup segmentation markers for other figure
    figure(reg_fig);
    seg_h=cell(numel(sensors),2);
    for sensor = 1:numel(sensors)
        subplot(numel(sensors),1,sensor);
        seg_h{sensor,1}=stem(0,0,'k-.','Marker','None'); % right leg markers
        seg_h{sensor,2}=stem(0,0,'k:','Marker','None'); % left leg markers
    end
end

if (numel(varargin)<1 || isempty(varargin{1}))
    fid = -1;
else
    fid = fopen(sprintf('raw%s%s.txt',filesep,varargin{1}),'w');
    if (fid == -1)
        warning('File could not be opened. Data will not be recorded.');
    end
end

% initialize and start recording
read_serial('initialize', com_port, motes, @my_data, @my_status);
curtime=read_serial('start recording', '');

% setup the figure scroller
kill_all_timers();
tm = timer('Name', 'rtd_plot_timer', 'Period', time_between_update, 'ExecutionMode', 'fixedRate', 'TimerFcn', @my_scroller);
start(tm);
if (plot_consistency)
    tm2 = timer('Name', 'cons_plot_timer', 'Period', cons_time, 'ExecutionMode', 'fixedRate', 'TimerFcn', @update_consistency);
    start(tm2);
end


% If scrolling happens every time new data comes, it is slower and also
% produces a very jittery motion. Using a separate timer allows us smooth
% scrolling.
function my_scroller(obj, event, string_arg)
   time = curtime()+time_offset;
   for sensor = 1:numel(sensors)
       ax = my_axis{sensor};
       set(ax, 'XLim', [time-seconds time]);
   end
   
end

function update_consistency(obj, event, string_arg)    
   
   % get data
   data = gather_data(my_h, motes, sensors);
   
   % run consistency check
   if(numel(data) > 0 && numel(data{1}) > 10)
       [period, DTot] = consistency(data,leg_motes);
  
       gidx=floor([1:numel(DTot)/2]);
       set(cons_h{2}, 'XData', period, 'YData', DTot(period));
       set(cons_h{1}, 'XData', [1:numel(DTot)], 'YData', DTot);
       %set(gca,'XLim', [1 numel(DTot)], 'YLim', [min(DTot(gidx)) max(DTot(gidx))]);

       ref_axis = find(sensors == cons_ref_axis);
       if (~isempty(ref_axis))
           ref_axis = ref_axis(1);

           h = my_h{cons_right, ref_axis};
           reference_data_right = get(h, 'YData');
           h = my_h{cons_left, ref_axis};
           reference_data_left = get(h, 'YData');
           [minsr,indsr] = find_mins(reference_data_right',period);
           [minsl,indsl] = find_mins(reference_data_left',period);
           for sensor = 1:numel(sensors)
               h = my_h{cons_right,sensor};
               yd = get(h, 'YData');
               xd = get(h, 'XData');
               
               h = seg_h{sensor,1};
%                set(h, 'YData', yd(indsr), 'XData', xd(indsr));
               set(h, 'YData', bounds(sensors(sensor),2)*ones(size(yd(indsr))), 'XData', xd(indsr));
               
               h = my_h{cons_left,sensor};
               yd = get(h, 'YData');
               xd = get(h, 'XData');
               
               h = seg_h{sensor,2};
%                set(h, 'YData', yd(indsl), 'XData', xd(indsl));
               set(h, 'YData', bounds(sensors(sensor),2)*ones(size(yd(indsl))), 'XData', xd(indsl));
           end
       end

   end
end

function my_data(cb_arg, val)
    if (fid ~= -1)
        my_record(fid, val);
    end
    my_update(cb_arg, val);
end

% This is called every time new data arrives from the motes
function my_update(cb_arg, val)
    mote = find(motes==val.mote_id,1,'first');
    if(mote < 1)
        return; % not a valid mote
    end
    
    new_x = [val.time1 val.time2];
    for sensor=1:numel(sensors)
        new_y = [val.data1(sensors(sensor)) val.data2(sensors(sensor))];

        if(val.is_interp && highlight_missing)
            new_y = new_y*0 - 6000;
        end

        h = my_h{mote,sensor};
        ax = my_axis{sensor};
        
        yd = get(h, 'YData');
        xd = get(h, 'XData');
        
        if(new_x(1) >= new_x(2) || xd(end) >= new_x(1)) % data must be strictly increasing in time
            return;
        end
        yd = [yd new_y];
        xd = [xd new_x];

        if (is_paused)
            set(h, 'YData', yd, 'XData', xd);
        else
            idx = xd >= (new_x(2)-seconds);
            set(h, 'YData', yd(idx), 'XData', xd(idx));
        end
    end
end

% This is a periodic status update
function my_status(cb_arg, ml)
    miss_idx = [ml(:).last_interval] > missing_timeout;
    missing = motes(miss_idx);
    
    if(numel(missing) > 0)
        str = '';
        for idx=1:numel(missing)
            str = [str ', ' sprintf('%i', missing(idx))];
        end
        disp(['missing: ' str(3:end)]);
    end
    
    %note: I'm not displaying this, but it could be
    not_missing = [1:numel(motes)];
    not_missing = not_missing(~miss_idx);
%     packet_loss = [ml(:).miss_packets]./ [ml(:).total_packets] .* 100;   % total packet loss
    packet_loss = [ml(:).st_packet_loss]; % short-term packet loss
    sampling_freq = [ml(:).sample_interval]./[ml(:).good_packets];
    sampling_freq = 1./sampling_freq;
    
    disp([sprintf('packet loss: \t\t') sprintf(' \t%3.2f%%', packet_loss)]);
    disp(['sampling frequency: ' sprintf('\t%3.2f', sampling_freq)]);
    disp(sprintf('\n'));
    
%     str='';
%     str2='';
%     for idx=not_missing
%         str = [str sprintf('mote %i: %3.2f%%, ', motes(idx), packet_loss(idx))]; 
%         str2 = [str2 sprintf('mote %i: %3.2f, ', motes(idx), sampling_freq(idx))];
%     end
%     if(numel(not_missing)>0)
%         disp(['packet loss: ' str]);
%         disp(['sampling frequency: ' str2]);
%     end
end

% causes the closing of the figure to stop recording
function my_window_close(the_fig, foo)
    kill_all_timers();
    read_serial('stop recording');

    delete(reg_fig);
    if (plot_consistency)
        delete(cons_fig);
    end
    
    if (fid ~= -1)
        fclose(fid);
    end
end

function my_window_pause(the_fig, foo)
    if (is_paused)
        x = timerfind('Name', 'rtd_plot_timer');
        if(numel(x)>0)
            start(x);
        end
        x = timerfind('Name', 'cons_plot_timer');
        if(numel(x)>0)
            start(x);
        end
        is_paused = false;
    else
        x = timerfind('Name', 'rtd_plot_timer');
        if(numel(x)>0)
            stop(x);
        end
        x = timerfind('Name', 'cons_plot_timer');
        if(numel(x)>0)
            stop(x);
        end
        is_paused = true;
    end
end

% Kills all timers used
function kill_all_timers()
    x = timerfind('Name', 'rtd_plot_timer');
    if(numel(x)>0)
        stop(x);
        delete(x);
    end    
    x = timerfind('Name', 'cons_plot_timer');
    if(numel(x)>0)
        stop(x);
        delete(x);
    end    
end

end

% This function gathers all data into a coherent structure for use with
% other functions. 
function data = gather_data(my_h, motes, sensors)
    data = {};
    FILTER_SIZE=8;
         
    % get the data from the first sensor
    xi_t = get(my_h{1,1}, 'XData');
    xi_t = xi_t(6:end-6);
    if(numel(xi_t) < 3)
        return;
    end
    bad_idx = xi_t == nan;
    
    % collect data from each plot
    data = cell(numel(motes),1);
    for mote=1:numel(motes)
       mdata = zeros(numel(xi_t), numel(sensors));
       for sensor = 1:numel(sensors)
           h = my_h{mote,sensor};
           x = get(h, 'XData');
           y = get(h, 'YData');
           mdata(:,sensor) = interp1(x,y,xi_t, 'linear');
       end

       % check for NANs
       new_bidx = [isnan(sum(mdata,2))]';
       bad_idx = bad_idx | new_bidx;
       data{mote} = mdata;
    end
    
    % remove bad lines
    for mote=1:numel(motes)
        mdata = data{mote};
        data{mote} = mdata(~bad_idx,:);
    end
    
    %filter
    if(size(data{1}) < 2*FILTER_SIZE)
        data={};
        return;
    end
    for idx=1:size(data)
        mdata = data{idx};
        
       mdata = conv2(mdata,ones(FILTER_SIZE,1));
       mdata = mdata(FILTER_SIZE:end-FILTER_SIZE,:);
       data{idx} = mdata;
    end

end

% This is called every time new data arrives from the motes
function my_record(fid, val)
%     if (fid == -1)
%         return;
%     end

    data1 = [val.packet_type, val.group_id, val.mote_id, val.transmission_id, val.counter*2, val.data1, val.time1, val.is_interp];
    data2 = [val.packet_type, val.group_id, val.mote_id, val.transmission_id, val.counter*2+1, val.data2, val.time2, val.is_interp];
    
    my_fmt = repmat(' %d',1,numel(data1));
    my_fmt = [my_fmt '\n'];
%     my_fmt
    
    fprintf(fid, my_fmt, data1);
    fprintf(fid, my_fmt, data2);
end