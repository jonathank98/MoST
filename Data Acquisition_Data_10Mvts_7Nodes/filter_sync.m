% splits raw data by mote
% Remove lines with out of sync packet numbers
% If frame numbers are available, use them to keep nodes in sync

% data_out = filter_renumber(data_in, col_packet_num, col_mote_num, col_group_num, col_frame_num, motes)

%   data_in: a two-dimensional array. columns represent individual sensor
%     streams.
%   col_packet_num: the column containing the packet numbers
%   col_mote_num: the column containing the mote numbers
%   col_group_num: the column containing the group numbers
%     alternatively, any column that should be the same for all packets
%   col_frame_num: the column containing the frame numbers, if available
%     if frame numbers are not available, some number <= 0
%   data_out: cell containing matrices for individual nodes
%     packet numbers are in order, and if frames were available, nodes are
%     in sync

function data_out = filter_sync(data_in, col_packet_num, col_mote_num, col_group_num, col_frame_num, motes)

MAX_TO_REMOVE = 20;
MAX_TO_INSERT = 20;
MAX_LAG = 4;

data_out = data_in;

badids = unique(data_out(:,col_group_num));
        
groupid = 0;
numinstances = 0;
        
for i = 1:numel(badids)
    numthisid = numel(find(data_out(:,col_group_num) == badids(i)));
    if (numthisid > numinstances)
        groupid = badids(i);
        numinstances = numthisid;
    end
end
        
badids = setdiff(badids, groupid);
        
for i = 1:numel(badids)
    keeplines = (data_out(:,col_group_num) ~= badids(i));
    data_out = data_out(keeplines,:);
end

split = cell(numel(motes),1);
lastpackets = zeros(numel(motes),1);
lastframes = zeros(numel(motes),1);

for mote = 1:numel(motes)

    disp(sprintf('mote = %d', motes(mote)));
    thismote = data_out(data_out(:,col_mote_num) == motes(mote),:);

    pl = 1 - size(thismote,1)/(thismote(end,col_packet_num)-thismote(1,col_packet_num)+1);
    disp(sprintf('Packet loss rate = %.4f%%',pl*100));
%     pause
    
    % Look for out of sync packet numbers
    
    % case 1: group of them somewhere in the middle
    %           or beginning numbers too large
    %           or ending numbers too small
    
    diff = thismote(2:end,col_packet_num) - thismote(1:end-1,col_packet_num);
    badlines = find(diff < 1);
    
    while (numel(badlines) > 0)
    
        for i = numel(badlines):-1:1
            % search backward and forward until you find the end of the bad
            % section
        
            j = 1;
            gapforward = diff(badlines(i));
            gapbackward = diff(badlines(i));
            while (j <= MAX_TO_REMOVE && (badlines(i)+j <= numel(diff) || badlines(i)-j > 0))
                if (badlines(i)+j <= numel(diff))
                    gapforward = gapforward + diff(badlines(i)+j);
                    if (gapforward > 0)
                        break;
                    end
                end
                if (badlines(i)-j > 0)
                    gapbackward = gapbackward + diff(badlines(i)-j);
                    if (gapbackward > 0)
                        break;
                    end
                end
                j = j + 1;
            end
        
            if (gapforward > 0)
                thismote = [thismote(1:badlines(i),:); thismote(badlines(i)+j+1:end,:)];
            else
                if (gapbackward > 0)
                    thismote = [thismote(1:badlines(i)-j,:); thismote(badlines(i)+1:end,:)];
                else
                    if (badlines(i) <= MAX_TO_REMOVE)
                        thismote = thismote(badlines(i)+1:end,:);
                    else
                        if (size(thismote,1) - badlines(i) <= MAX_TO_REMOVE)
                            thismote = thismote(1:badlines(i),:);
                        else
                            % try going both ways
                            j = 1;
                            gap = diff(badlines(i));
                            while (j <= MAX_TO_REMOVE/2 && badlines(i)+j <= numel(diff) && badlines(i)-j > 0)
                                gap = gap + diff(badlines(i)+j) + diff(badlines(i)-j);
                                if (gap > 0)
                                    break;
                                end
                                j = j + 1;
                            end
                            
                            if (gap > 0)
                                thismote = [thismote(1:badlines(i)-j,:); thismote(badlines(i)+j+1:end,:)];
                            else
                                disp(sprintf('cannot resolve error around line %d, %d',badlines(i),motes(mote)));
                            end
                        end
                    end
                end
            end
        end
        
        diff = thismote(2:end,col_packet_num) - thismote(1:end-1,col_packet_num);
        badlines = find(diff < 1);
    end
    
    diff = thismote(2:end,col_packet_num) - thismote(1:end-1,col_packet_num);
    badlines = find(diff > MAX_TO_INSERT);
    
    for i = numel(badlines):-1:1
        % case 2: group too small at the beginning
        if (badlines(i) <= MAX_TO_REMOVE)
            thismote = thismote(badlines(i)+1:end,:);
        else
        % case 3: group too large at the end
            if (size(thismote,1) - badlines(i) <= MAX_TO_REMOVE)
                thismote = thismote(1:badlines(i),:);
            end
        end
    end
    
    thismote(:,col_packet_num) = thismote(:,col_packet_num)-thismote(1,col_packet_num)+1;
    
    split{mote} = thismote;
    if (col_frame_num > 0)
        lastframes(mote) = thismote(end,col_frame_num);
        lastpackets(mote) = thismote(end,col_packet_num);
    end
end
% disp(lastpackets)

if (col_frame_num > 0)
    % for now just sync using first camera
    highestframe = max(lastframes);
    
    i = 0;
    while (i < highestframe)
        nums = zeros(numel(motes),1)-1;
        for mote = 1:numel(motes)
            thismote = split{mote};
            index = find(thismote(:,col_frame_num) == i);
            if (numel(index) > 0)
                nums(mote) = thismote(index(1),col_packet_num);
            end
        end

        target = max(nums);
        
        for mote = 1:numel(motes)
            thismote = split{mote};
            index = find(thismote(:,col_frame_num) >= i);
            if (numel(index) > 0 && target > 0)
                gap = target - thismote(index(1),col_packet_num);
                if (gap > MAX_LAG)
                    thismote(index(1):end,col_packet_num) = thismote(index(1):end,col_packet_num) + gap;
                end
            end
            split{mote} = thismote;
        end
        i = i + 1;
    end
    
    for i = 1:numel(motes)
        thismote = split{i};
        lastpackets(i) = thismote(end,col_packet_num);
    end
end
% disp(lastpackets)
data_out = split;

end
