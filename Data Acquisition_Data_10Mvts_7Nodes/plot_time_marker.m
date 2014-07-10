% For data with video frames embedded in the packets, 
%   framelist = the frame number column from one mote
%   frame = the current frame of the video 
% For other data
%   framelist = []
%   frame = time of the current frame of the video

function [sample, height, hline] = plot_time_marker(framelist, frame, oldsample, hfig, subplotdim1, subplotdim2, hprev)

% These parameters are only needed for data without video frame numbers
% Adjust them to sync the data with the video
sampling_rate = 28.5;
offset = 160;

if (isempty(framelist))
    sample = floor(frame*sampling_rate) + 1 - offset;
    
    if (sample < 1)
        sample = 1;
    end
else
    sample = find_sample(framelist, frame);
end

if (~isempty(oldsample))
    sample = oldsample;
end

hline = zeros(subplotdim1,subplotdim2);
height = zeros(subplotdim1,subplotdim2);

figure(hfig);
subplot(subplotdim1,subplotdim2,1);

for i=1:subplotdim1*subplotdim2
    subplot(subplotdim1,subplotdim2,i)
    if (~isempty(hprev))
        set(hprev(i),'Visible','off');
    end
    axes = get(get(hfig,'CurrentAxes'),'YLim');
    height(i) = 2*(axes(2)-axes(1))/3+axes(1);
    hline(i) = plot([sample sample],axes,'r');
end

end