function start_recording(filename)

global FID;
global S;
global FNAME;
global VID;
global A;
global C;
global k;
global NUM_CAMS;

FNAME = filename;

A = [];
C = zeros(size(C));
k = 0;

% % % %trigger emg
% % % trig
% % % %trigger emg

FID = fopen(strcat(sprintf('raw%s',filesep),FNAME,'.txt'),'wt');

for i = 1:NUM_CAMS
    disp(sprintf('got here %d',i));
    M = avifile(strcat(sprintf('video%s',filesep),FNAME,sprintf('_c%02d',i),'.avi'),'Compression','Indeo5','Fps',15);
    VID(i).LoggingMode = 'disk';
    VID(i).DiskLogger = M;
end

fopen(S);

for i = 1:NUM_CAMS
    start(VID(i));
end

% % for emg synchronization
% 
%pause(30);

%stop_recording
% 
% % for emg synchronization


end