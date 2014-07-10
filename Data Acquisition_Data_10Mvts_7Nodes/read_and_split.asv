
PACKET_SIZE = 41;
NUM_CAMS = 2;
ERROR_MARGIN = 100;
MAX_TO_REMOVE = 10;

motes = [6,8,10];
mvts = [1];
subjects = [1];
experiment = 1;

num_frame_cols = max(NUM_CAMS,1);

MAX_COL = PACKET_SIZE + num_frame_cols;

my_fmt='';
my_fmt(MAX_COL*2)='s';
my_fmt(1:2:MAX_COL*2)='%';
my_fmt(2:2:MAX_COL*2)='s';
my_fmt = [my_fmt '%*[^\n]'];

out_fmt = '';
out_fmt((21+num_frame_cols)*3)=' ';
out_fmt(1:3:(21+num_frame_cols)*3)='%';
out_fmt(2:3:(21+num_frame_cols)*3)='d';
out_fmt(3:3:(21+num_frame_cols)*3)=' ';
out_fmt = [out_fmt '\n'];

tic
for mvt = mvts
    for subject = subjects
        fname = sprintf('raw\\m0001_s01_m01.txt',experiment,subject,mvt);
        fname 
        dataFile = fopen(fname);
        data = textscan(dataFile, my_fmt);
        fclose(dataFile);
        toc;

        %==== Turn it into a regular cell array ===
        % Note: the last line may not be complete, so some columns
        % will have an extra element. Make all columns the same size
        max_len = numel(data{end});
        for col_idx = 1:size(data,2)
            data{col_idx} = data{col_idx}(1:max_len);
        end
        data = horzcat(data{:});
        toc;

        %=== Convert to decimal ===%
        data(strcmp(data, ''))={'00'};
        data = reshape(hex2dec(data),size(data,1),size(data,2));
        
        %=== Convert two-sample packet into an array of individual samples
        packet = zeros(size(data,1)*2, 21+num_frame_cols);

        % header (3:11) -> (1:9)
        % packet type (12) -> (10)
        % group id (13) -> (11)
        % mote id (14) -> (12)
        % transmission id (15) -> (13)
        packet(1:2:end,1:13) = data(:,3:15);
        packet(2:2:end,1:13) = packet(1:2:end,1:13);

        % counter (16:17) -> (14)
        packet(1:2:end,14) = (data(:,16)*256 + data(:,17)) * 2;
        packet(2:2:end,14) = packet(1:2:end,14) + 1;

        % sensor data
        % x-accel (18:20) -> (15)
        % y-accel (21:23) -> (16)
        % z-accel (24:26) -> (17)
        % gyro 1 x (27:29) -> (18)
        % gyro 1 y (30:32) -> (19)
        % gyro 2 x (33:35) -> (20)
        % gyro 2 y (36:38) -> (21)
        packet(1:2:end,15:21) = data(:,18:3:36)*16 + bitand(data(:,19:3:37),240)/16;
        packet(2:2:end,15:21) = bitand(data(:,19:3:37),15)*256 + data(:,20:3:38);
        
        % frame numbers (last NUM_CAMS columns or last column if no cameras)
        packet(1:2:end,22:(22+num_frame_cols-1)) = data(:,(end-num_frame_cols+1):end);
        packet(2:2:end,22:(22+num_frame_cols-1)) = packet(1:2:end,22:(22+num_frame_cols-1));
        
%         packet = packet(20:end,:);
        
        toc;

        % === Renumber === %
        if (NUM_CAMS > 0)
            frame_col = size(packet,2) - NUM_CAMS + 1;
        else
            % packets without frame numbers have a counter for how many
            % packets the base station received. This is the last column
            % and can also be used for syncing motes together.
            frame_col = size(packet,2);
        end
        split=filter_sync(packet,14,12,11,frame_col,motes);
        toc;

        % === Split === %
        for mote = 1:numel(motes)
            fnameout = sprintf('split\\m%04d_s%02d_m%02d_n%02d.txt',experiment,subject,mvt,motes(mote));

            fidout = fopen(fnameout, 'w');
            
            thismote = split{mote};
            
            thismote = filter_unsigned2signed(thismote, [15:17], 12);
            disp(sprintf('mvt = %d, subject = %d, mote = %d', mvt, subject, motes(mote)));
            thismote = filter_datafill(thismote, 14, 'linear');
            
%             if (mote == 5 && subject == 2)
%                 thismote = rotate_mote_data(thismote);
%             end
            
            for j = 1:size(thismote,1)
                fprintf(fidout, out_fmt,thismote(j,:));
            end
            
            fclose(fidout);
        end
        toc;
    end
end