function split_video(filename, frame_pairs, packet_size,num_cams)

if (num_cams ~= 1)
    disp('Error: Number of cameras must be 1.')
    return;
end

segment = 1;

my_fmt = '';
my_fmt((packet_size+num_cams)*5)=' ';
my_fmt(1:5:(packet_size+num_cams)*5)='%';
my_fmt(2:5:(packet_size+num_cams)*5)='0';
my_fmt(3:5:(packet_size+num_cams)*5)='2';
my_fmt(4:5:(packet_size+num_cams)*5)='X';
my_fmt(5:5:(packet_size+num_cams)*5)=' ';
my_fmt = [my_fmt '\n'];

fid = fopen(strcat('raw\\',filename,'.txt'));
AGData = fscanf(fid,'%X');
fclose(fid);

if (size(AGData,1)==0)
    return;
end

AGData = reshape(AGData,packet_size+num_cams,[]);
AGData = AGData';
framelist = AGData(:,end);

for i = 1:2:numel(frame_pairs)-1
    
    % load video from frame_pairs(i) to frame_pairs(i+1)
    % for now support only camera 1
    m = aviread(strcat('video\\',filename,'_c01.avi'),[frame_pairs(i):frame_pairs(i+3)]);

    vidfname = sprintf('video\\%s_c01_s%02d.avi',filename,segment);
    outfname = sprintf('raw\\%s_s%02d.txt',filename,segment);
    
    movie2avi(m,vidfname,'Compression','None');
    
    startpt = find(framelist < frame_pairs(i));
    if (~isempty(startpt))
        startpt = startpt(end);
    else
        startpt = 1;
    end
    
    endpt = find(framelist > frame_pairs(i+1));
    if (~isempty(endpt))
        endpt = endpt(1);
    else
        endpt = size(AGData,1);
    end
    
    thissegment = AGData(startpt:endpt,:);
    thissegment(:,end) = max(0,thissegment(:,end)-frame_pairs(i)+1);
    
    fid = fopen(outfname,'w');
    
    for j = 1:size(thissegment,1)
        fprintf(fid,my_fmt,thissegment(j,:));
    end
    
    fclose(fid);
    
    segment = segment + 1;
end
end