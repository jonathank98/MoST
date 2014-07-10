function stop_recording()

global FID;
global S;
global VID;
global NUM_CAMS;

fclose(S);

for i = 1:NUM_CAMS
    stop(VID(i));
end

fclose(FID);

for i = 1:NUM_CAMS
    while (VID(i).FramesAcquired ~= VID(i).DiskLoggerFrameCount)
        display(VID(i).FramesAcquired - VID(i).DiskLoggerFrameCount);
        pause(10);
    end
    
    M = VID(i).DiskLogger;
    M = close(M);
end

end