function store_line(obj,event,packet_size,motes)

global S;
global FID;
global MY_FMT;
global A;
global C;
global k;
global CACHE_SIZE;
global VID;
global NUM_CAMS;

A = [A; fread(S,packet_size)];

if (NUM_CAMS < 1)
    frame = k;
else
    frame = zeros(NUM_CAMS,1);

    for i = 1:NUM_CAMS
        frame(i) = VID(i).FramesAcquired;
    end
end

starts = find(A == 126);

j = 1;
while (j < numel(starts))
    B = A(starts(j):starts(j+1));

    if (numel(B) < packet_size)
        j = j + 1;
        continue;
    else
        if (numel(B) > packet_size)
            % 7D and 7E are reserved, so they are transmitted as 7D5D and 7D5E
            % respectively; fix this
            tofix = find(B == 125);

            for i = numel(tofix):-1:1
                if (tofix(i) < packet_size-1)
                    B = [B(1:tofix(i)-1); B(tofix(i)+1)+32; B(tofix(i)+2:end)];
                else
                    if (tofix(i) < packet_size)
                        B = [B(1:tofix(i)-1); B(tofix(i)+1)+32];
                    else
                        B = B(1:tofix(i)-1);
                    end
                end
            end
            if (numel(B) ~= packet_size)
                j = j + 1;
                continue;
            end
        end
    end


    % B is a full packet; remove it from A
    A = A(starts(j+1)+1:end);
    starts = starts-(starts(j+1));
    
    B = [B; frame];
%     disp(B')
    
    fprintf(FID,MY_FMT,B);
    C(mod(k,CACHE_SIZE)+1,:) = B';
       
    if (numel(unique(C(1:min(k,size(C,1)),11))) > 1)
        display(strcat(datestr(now),' Transmission error. If it persists, restart base station.'));
    end
        
    k = k + 1;
        
    if (k >= numel(motes) && mod(k,numel(motes))==0)
        livemotes = unique(C(1:min(k,size(C,1)),14));
        deadmotes = setdiff(motes,livemotes);
            
        if (numel(deadmotes) > 0)
            display(strcat(datestr(now),' Motes ',sprintf(' %d',deadmotes),' missing.'));
        end
    end
    j = j + 2;
end
end