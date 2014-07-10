function cleanup()

global S;
global VID;
global NUM_CAMS;

delete(S);
clear S;

for i = 1:NUM_CAMS
    stoppreview(VID(i));
    delete(VID(i));
end

clear VID;