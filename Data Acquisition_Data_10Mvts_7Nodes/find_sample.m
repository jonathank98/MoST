% return index of first instance of this frame for first camera
function sample = find_sample(framelist,frame)

% This initial value of i is a parameter to account for some lag
% between the sensor data being taken and the frame number being
% recorded; adjust this if things don't seem quite in sync
i = 2;
sample = [];

while(isempty(sample) && frame(1)+i < max(framelist(:,1)))
    sample = find(framelist(:,1)==frame(1)+i,1);
    i = i + 1;
end

if (isempty(sample))
    sample = 1;
end

end