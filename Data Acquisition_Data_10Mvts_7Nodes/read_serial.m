% Handles live serial recording from a telosb mote
% read_serial(command, ...)
%   command: one of three: 'Initialize', 'start recording', or 'stop
%       recording'
%   'initialize': com_port, motes, data_callback, status_callback
%       com_port: string with the com port
%       motes: array with mote numbers to check for
%       data_callback: callback function for data handling
%         (documentation below). Empty string disables this
%       status_callback: callback_function for status checking. Empty
%         string disables this
%   'start recording': callback_arg. This starts a recording session
%       callback_arg: argument passed to both types of callback
%   'stop recording': no arguments
%
% note: this records nothing. But when recording is started, it will
% repeatedly call the data_callback function with each packet as it is
% received. 
function curtime_fcn = read_serial(command, varargin)

curtime_fcn = @curtime;

%=== Declare variables ===
persistent h7e h7d h5e h5d h1021 h8000; % define hex constants
persistent state_wait_end state_wait_start state_read_char state_read_esc state_off; % define states
persistent status_callback data_callback status_interval callback_arg; 
persistent pckt_tmpl; % packet template
persistent input_buf input_next_idx input_state serial_port start_time;
persistent mote_list;

cur_time = curtime();


switch(lower(command))
    case {'start recording'}
        if(numel(varargin)~=1)
            error('Not enough arguments to command "start recording"');
        end
        my_start_recording(varargin{1});
    case {'stop recording'}
        my_stop_recording();
    case {'initialize'}
        if(numel(varargin) ~= 4)
            error('Not enough arguments to command "Initialize"');
        end
        my_initialize(varargin{1}, varargin{2}, varargin{3}, 30, varargin{4}, 0.5);
end


%--- Initialize data ---
function my_initialize(com_port, the_mote_list, the_data_callback, the_data_wait_size, the_status_callback, the_status_interval)
    
    %=== Create state variables ===
    state_wait_end=1;
    state_wait_start=2;
    state_read_char=3;
    state_read_esc=4;
    state_off=5;
    
    input_state = state_off; % deactivate everything
    input_buf = zeros(1,256);
    input_next_idx = 1;
    
    %=== Initialize Serial Port ===
    com_port = upper(com_port);
    serial_port = instrfind('Port', com_port); % find any serial ports already connected
    delete(serial_port); % disconnect and remove them
    serial_port = serial(com_port); % none were found--connect a new one to the com port
    
    set(serial_port, 'BaudRate', 115200, 'DataBits', 8, 'FlowControl', 'none', 'Parity', 'none', 'StopBits', 1, 'ReadAsyncMode', 'continuous');
    set(serial_port, 'BytesAvailableFcn', @my_statem, 'BytesAvailableFcnCount', the_data_wait_size, 'BytesAvailableFcnMode', 'byte', 'InputBufferSize', 4096);

    %=== Callbacks ===
    status_interval=the_status_interval;
    status_callback=the_status_callback;
    data_callback = the_data_callback;
    callback_arg = '';
    
    %=== Populate hex constants ===
    h7e = hex2dec('7e');
    h7d = hex2dec('7d');
    h5e = hex2dec('5e');
    h5d = hex2dec('5d');
    h1021 = hex2dec('1021');
    h8000 = hex2dec('8000');
    
    %=== Packet template ===
    val = [];
    val.time1 = 0;
    val.time2 = 0;
    val.is_interp = false; % Is this data interpolated?
    val.is_valid = false; % is this a valid packet?
    val.packet_type = -1;
    val.group_id = -1;
    val.mote_id = -1;
    val.transmission_id = -1;
    val.counter = -1;
    val.data1 = zeros(1,7); % the data from all sensors at first sample time
    val.data2 = val.data1; % the data from all sensors at the second sample time

    pckt_tmpl = val;
    
    %=== Mote list ===
    init_mote_list(the_mote_list);
end

% This opens the serial port, adds the status callback, and starts kicking
% ass
function my_start_recording(the_callback_arg)
    my_stop_recording(); % make sure the old recording is fully ended
    callback_arg = the_callback_arg;
    start_time = clock();
        
    % set the initial state
    input_next_idx=1;
    input_state=state_wait_end;
    
    % set initial 'last received'
    [mote_list(:).last_received] = deal(0);
    init_mote_list([mote_list(:).mote_id]);
    
    % open the serial port
    fopen(serial_port);
    
    % add the status callback
    tm = timer('Name', 'read_serial_timer', 'Period', status_interval, 'ExecutionMode', 'fixedRate', 'TimerFcn', @my_timer_fcn);
    start(tm);
end

function my_stop_recording()
    x = instrfind('Port', serial_port.Port);
    if(numel(x)>0)
        fclose(x); % Close all objects connected to this port
    end
    
    %close all timers
    x = timerfind('Name', 'read_serial_timer');
    if(numel(x) > 0)
        stop(x);
        delete(x);
    end

    % turn off state machine
    input_state=state_off;
end

function init_mote_list(the_mote_list)
    ml=[];
    ml.mote_id = -1;
    ml.last_received = -1; % last time received in cputime
    ml.last_interval = -1; % interval between last reception and now
    ml.good_packets = 1; %packets actually received
    ml.miss_packets = 0; % packets that had to be interpolated
    ml.st_good_packets_buf = ones(100,1); % record of last 100 packets
    ml.st_packet_loss = 0;
    ml.sample_interval = 0; % running total of sampling periods
    ml.total_packets = 1; % bad packets
    ml.last_packet = pckt_tmpl; % last packet received
    
    mote_list=ml;
    mote_list(numel(the_mote_list))=ml;
    mote_list(:) = ml;
    the_mote_list = num2cell(the_mote_list);
    [mote_list(:).mote_id] = deal(the_mote_list{:}); % assign the moteIDs to everything in the list   
end

function my_timer_fcn(obj, event, string_arg)
    cur_time=curtime();
    
    if(isa(status_callback, 'function_handle'))
        tp = num2cell([mote_list(:).good_packets] + [mote_list(:).miss_packets]);
        li = num2cell(cur_time - [mote_list(:).last_received]);

        [mote_list(:).last_interval] = deal(li{:});
        [mote_list(:).total_packets] = deal(tp{:});
        
        status_callback(callback_arg, mote_list);
    end
end


%--- Statemachine function ---
function my_statem(obj,event)
    persistent buf;
    cur_time = curtime();

    % get the characters
    if(serial_port.BytesAvailable>0)
        cbuf = fread(serial_port,serial_port.BytesAvailable,'uint8')';
    else
        return;
    end
    buf = [buf cbuf]; % remove semicolon to see buf contents in matlab window
    
    % process the lines
    line_idx = find(buf==h7e);
    for idx=2:numel(line_idx)
        st = line_idx(idx-1);
        en = line_idx(idx);
        line=buf(st:en);
        if(numel(line)<=2)
            continue; % empty line
        end
        
        
        % handle translations
        tr_idx = line == h7d;
        tr_idx2 = [false tr_idx(1:end-1)];
        l5d = line==h5d;
        l5e = line==h5e;
        line(tr_idx2 & l5d) = h7d;
        line(tr_idx2 & l5e) = h7e;
        line(tr_idx)=[]; % Delete the parts of the line with the escape character
        
        % deal with the line
        handleline(line(2:end-1), numel(line)-2);
    end
    
    % remove all
    if(numel(line_idx)==0)
        buf=[];
    elseif(line_idx(end)==1)
        if(numel(buf) > 100)
            buf=[];
        end
    else
        buf(1:(line_idx(end)-1))=[];
    end

%     for cidx=1:numel(cbuf)
%         c=cbuf(cidx);
%         switch(input_state)
%             case state_off % do nothing
%             case state_wait_end
%                 if(c==h7e)
%                     input_state = state_wait_start;
%                 end 
%             case state_wait_start
%                 if(c==h7e)
%                     input_state = state_read_char;
%                     input_next_idx=1;
%                 else
%                     input_state = state_wait_end;
%                 end
%             case state_read_char
%                 if(c == h7d)
%                     input_state = state_read_esc;
%                 elseif(c == h7e)
%                     handleline(input_buf,input_next_idx-1);
%                     input_state=state_wait_start;
%                 elseif(input_next_idx>100) % clearly a runaway line
%                     input_state = state_wait_end;
%                 else
%                     input_buf(input_next_idx)=c;
%                     input_next_idx = input_next_idx+1;
%                 end
%             case state_read_esc
%                 if(c==h5e)
%                     input_buf(input_next_idx) = h7e;
%                     input_next_idx = input_next_idx+1;
%                 elseif(c==h5d)
%                     input_buf(input_next_idx) = h7d;
%                     input_next_idx = input_next_idx+1;
%                 end
%                 input_state = state_read_char;
%         end
% 
%     end
end % end statemachine

%--- Function: handleline ---
function handleline(buf, buflength)
    if(buflength < 2)
        %disp('bad packet');
        return;
    end
    crc_read = buf(buflength-1) + buf(buflength)*256;
    crc_calc = crc_calc(buf,buflength-2);
    if(crc_read ~= crc_calc)
        %disp('bad packet');
        return;
    end
    if(buflength < 39)
        %disp('packet isnt big enough');
        return;
    end

    %=== Populate Packet ===
    val=pckt_tmpl;
    val.is_valid = true;
    val.is_interp = false;
    val.time2 = cur_time; % time of the second sample
    val.time1 = val.time2; % time of the first sample
    val.packet_type = read_short(buf,10);
    val.group_id = buf(12);
    val.mote_id = buf(13);
    val.transmission_id = buf(14);
    val.counter = read_short(buf,15);
       
    % note: I had this in separate fields, but it wasn't very convenient to
    % access. 
    x_accel = read_12bit_s(buf,17);
    y_accel = read_12bit_s(buf, 20);
    z_accel = read_12bit_s(buf, 23);
    x1_gyro = read_12bit(buf,26);
    y1_gyro = read_12bit(buf,29);
    x2_gyro = read_12bit(buf,32);
    y2_gyro = read_12bit(buf,35);
    
    data = [x_accel y_accel z_accel x1_gyro y1_gyro x2_gyro y2_gyro];
    val.data1 = data(2:2:end); % the sensors at first sample time
    val.data2 = data(1:2:end); % the second sample

    idx = find([mote_list(:).mote_id] == val.mote_id,1,'first');
    if(numel(idx)==0 || idx < 1)
        return; % this packet is not from a valid mote
    end
            
    %=== Handle Interpolation ===
    lp = mote_list(idx).last_packet;
    interval = 0;
    if(lp.is_valid)
        ipckts = lp.counter+1:val.counter-1;
        if(val.counter > lp.counter)
            interval = (val.time2-lp.time2)/(val.counter-lp.counter);
        end
    else
        ipckts=[];
    end
    ip=[];
    if(numel(ipckts) > 0) % we need to interpolate
        %interpolate values
        x = [lp.counter+0.5; val.counter];
        y = [lp.data2; val.data1];
        data1 = num2cell(interp1(x,y,ipckts', 'linear'),2);
        data2 = num2cell(interp1(x,y,ipckts'+0.5, 'linear'),2);
        time2 = num2cell(interp1([lp.counter;val.counter], [lp.time2 val.time2], ipckts', 'linear'));
        time1 = num2cell([time2{:}]-interval/2);
        
        
        % create list of interpolated packets
        ip = val;
        ip(numel(ipckts))=val;
        ip(:)=val;
        ipckts2 = num2cell(ipckts);
        [ip(:).counter] = deal(ipckts2{:});
        [ip(:).data1] = deal(data1{:});
        [ip(:).data2] = deal(data2{:});
        [ip(:).time1] = deal(time1{:});
        [ip(:).time2] = deal(time2{:});
        [ip(:).is_interp] = deal(true);
    end

    %=== Update mote_list ===
    mote = mote_list(idx);
    mote.last_packet = val;
    mote.last_received = cur_time;
    mote.good_packets = mote.good_packets + 1;
    mote.miss_packets = mote.miss_packets + numel(ip);
    mote.st_good_packets_buf = [mote.st_good_packets_buf; zeros(numel(ip),1); 1];
    mote.st_good_packets_buf = mote.st_good_packets_buf(numel(mote.st_good_packets_buf)-99:end);
    mote.st_packet_loss = 100 - nnz(mote.st_good_packets_buf);
    mote.sample_interval = mote.sample_interval + interval/2;
    mote_list(idx) = mote;

    %=== Send to callback ===
    if(isa(data_callback, 'function_handle'))       
        for idx=1:numel(ip)
            data_callback(callback_arg, ip(idx)); % send interpolated packets
        end
        val.time1 = val.time2-interval/2;
        data_callback(callback_arg, val);
    end
    

end

function num = read_short(buf, idx)
    num = buf(idx)*256 + buf(idx+1);
end

function nums = read_12bit(buf, idx)
    num1 = buf(idx)*16 + bitshift(buf(idx+1),-4);
    num2 = bitand(buf(idx+1),15)*256 + buf(idx+2);
    nums = [num1 num2];
end

function nums = read_12bit_s(buf, idx)
    nums = read_12bit(buf, idx);
    idx2 = nums>2048;
    nums(idx2) = nums(idx2)-4096;
end

function crc=crc_calc(buf, len)
    crc = 0;
    for idx=1:len
        crc = crc_calc_byte(crc, buf(idx));
    end
end

function crc = crc_calc_byte(crc, x)
    crc = uint32(crc);
    x = uint32(x);
    crc = bitxor(crc, bitshift(x, 8));
    
    for idx=1:8
        if(bitand(crc, h8000) == h8000)
            crc = bitxor(h1021, bitshift(crc, 1));
        else
            crc = bitshift(crc,1);
        end
    end
    crc = bitand(crc,65535);
end

function ctime=curtime()
    if(numel(start_time)==0)
        ctime=0;
    else
        ctime = etime(clock,start_time);
    end
end

end %end main




