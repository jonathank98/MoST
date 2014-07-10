function setup(num_cameras,motes,port,baud_rate,packet_size,cache_size)

global MY_FMT;
global S;
global VID;
global PACKET_SIZE;
global CACHE_SIZE;
global C;
global NUM_CAMS;

platforms = {
    'telos',
    'telosb',
    'tmote',
    'micaz',
    'mica2',
    'mica2dot',
    'eyes',
    'intelmote2'
    };
baudrates = [
    115200,
    115200,
    115200,
    57600,
    57600,
    19200,
    115200,
    115200
    ];


%--- Look for available cameras ---
% This code tries to exclusively use QuickCam branded cameras
% remove the first matching code if you want it to work with other cameras
vid_devices = imaqhwinfo('winvideo');
matches = strfind({vid_devices.DeviceInfo.DeviceName}, 'QuickCam'); % our camera is a QuickCam
cam_idx = ~cellfun(@isempty, matches);
vid_devices = vid_devices.DeviceInfo(cam_idx);


%--- Get the requested number of cameras ---
VID=[];
disp(sprintf('number of cameras is %d', numel(vid_devices)));
disp(sprintf('number of cameras is %d', num_cameras))

for idx=1:numel(vid_devices)
    vd = vid_devices(idx);

    % find supported format
    matches = strfind(vd.SupportedFormats, '320x240');
    fmt_idx = find(~cellfun(@isempty,matches),1);
    if(isempty(fmt_idx))
        continue; % the damn thing doesn't support 320x240
    end
    vi = videoinput('winvideo',vd.DeviceID, vd.SupportedFormats{fmt_idx});
    figure('Name', 'My Custom Preview Window'); 

    vidRes = get(vi, 'VideoResolution');
    nBands = get(vi, 'NumberOfBands');
    hImage = image( zeros(vidRes(2), vidRes(1), nBands) );

    preview(vi,hImage);
    vi.FramesPerTrigger = Inf;

    VID = [VID vi];

    if(size(VID,2)>=num_cameras)
        break;
    end
end


%--- Setup packets ---
NUM_CAMS = size(VID,2); % just in case we have fewer cameras than planned

PACKET_SIZE=packet_size;
CACHE_SIZE=cache_size;

frame_cols = max(NUM_CAMS,1);

C = zeros(CACHE_SIZE,PACKET_SIZE+frame_cols);

MY_FMT = '';
MY_FMT((PACKET_SIZE+frame_cols)*5)=' ';
MY_FMT(1:5:(PACKET_SIZE+frame_cols)*5)='%';
MY_FMT(2:5:(PACKET_SIZE+frame_cols)*5)='0';
MY_FMT(3:5:(PACKET_SIZE+frame_cols)*5)='2';
MY_FMT(4:5:(PACKET_SIZE+frame_cols)*5)='X';
MY_FMT(5:5:(PACKET_SIZE+frame_cols)*5)=' ';
MY_FMT = [MY_FMT '\n'];

S = serial(port);
S.BaudRate = baud_rate;
S.BytesAvailableFcn = {'store_line',PACKET_SIZE,motes};
S.BytesAvailableFcnCount = PACKET_SIZE;
S.BytesAvailableFcnMode = 'byte';

end