
%% Read the indices of the frame and select the target video
% _Indices are the output of annotation phase (they are generated originally by the VibMotion2 and well formatted by Java software)_
%%

function [ output_args ] = Untitled3( starting,ending,numAnnotation )
clc;
close all;
switch nargin

% _nargin=1 means that script is used inside Java annotation tool, only argument required is the total number of video to create, see line 41_
    case 1 
%read indices from a txt file
Data = load('indices.txt');
%choose video to edit

folder = fullfile(matlabroot,'..\Data Acquisition_Data_10Mvts_7Nodes\video');

% Check to see that it exists.

	
		[baseFileName, folderName, FilterIndex] = uigetfile('*.avi');
		if ~isequal(baseFileName, 0)
			movieFullFileName = fullfile(folderName, baseFileName);
		else
			return;
		end
	

% Output folder

outputFolder = fullfile(cd, 'frames');
if ~exist(outputFolder, 'dir')
mkdir(outputFolder);
end

%% Getting frames from the selected video 
% _Selecting the right frames and save them as png pictures_

for ix=1:2:starting
    baseFileName
    mov = VideoReader(movieFullFileName); %#ok<*TNMLP>
    numberOfFrames = mov.NumberOfFrames;
   numberOfFramesWritten = 0;
      starting=Data(ix);
  ending=Data(ix+1);
for frame = starting: ending

thisFrame = read(mov, frame);
outputBaseFileName = sprintf('%1.1d.png', frame);
outputFullFileName = fullfile(outputFolder, outputBaseFileName);
imwrite(thisFrame, outputFullFileName, 'png');
progressIndication = sprintf('Wrote frame %4d of %d.', frame,numberOfFrames);
disp(progressIndication);
numberOfFramesWritten = numberOfFramesWritten + 1;
end
progressIndication = sprintf('Wrote %d frames to folder "%s"',numberOfFramesWritten, outputFolder);
disp(progressIndication);
if (ix>18)
current_annotation=['m00',int2str((ix/2)),'_',baseFileName(7:17),'.avi']
else
    current_annotation=['m000',int2str((ix/2)),'_',baseFileName(7:17),'.avi']
end
mov = VideoWriter(current_annotation);
mov.FrameRate=15;
open(mov);
estensione = '.png';

%% Merging the previous selected frames into a new sub-video

for i=starting:ending
p = double(i);
p = int2str(p);
nomefile = strcat('frames\',p, estensione);
immagine = imread(nomefile);
writeVideo(mov,immagine);
end;
close(mov);

end;



%% For stand-alone use and not inside Java annotation tool
% _Arguments required are frame starting,frame ending and annotation number (for video renaming)_
    case 3

na=numAnnotation;
int2str(na)
% Open an sample avi file
folder = fullfile(matlabroot,'..\Data Acquisition_Data_10Mvts_7Nodes\video');

% Check to see that it exists.

	
		[baseFileName, folderName, FilterIndex] = uigetfile('*.avi');
		if ~isequal(baseFileName, 0)
			movieFullFileName = fullfile(folderName, baseFileName);
		else
			return;
		end
	
	
mov = VideoReader(movieFullFileName);

% Output folder

outputFolder = fullfile(cd, 'frames');
if ~exist(outputFolder, 'dir')
mkdir(outputFolder);
end

%getting no of frames

numberOfFrames = mov.NumberOfFrames;
numberOfFramesWritten = 0;
for frame = starting: ending

thisFrame = read(mov, frame);
outputBaseFileName = sprintf('%1.1d.png', frame);
outputFullFileName = fullfile(outputFolder, outputBaseFileName);
imwrite(thisFrame, outputFullFileName, 'png');
progressIndication = sprintf('Wrote frame %4d of %d.', frame,numberOfFrames);
disp(progressIndication);
numberOfFramesWritten = numberOfFramesWritten + 1;
end
progressIndication = sprintf('Wrote %d frames to folder "%s"',numberOfFramesWritten, outputFolder);
disp(progressIndication);
if (na>18)
current_annotation=['m00',int2str(na),'_',baseFileName(7:17),'.avi']
else
    current_annotation=['m000',int2str(na),'_',baseFileName(7:17),'.avi']
end
mov = VideoWriter(current_annotation);
mov.FrameRate=15;
open(mov);
estensione = '.png';
for i=starting:ending
p = double(i);
p = int2str(p);
nomefile = strcat('frames\',p, estensione);
immagine = imread(nomefile);
writeVideo(mov,immagine);
end;
close(mov);


end
end

