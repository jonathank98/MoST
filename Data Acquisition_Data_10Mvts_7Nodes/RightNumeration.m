%% Script for make text file values of columns 10,11,12 consistent for VibMotion2 data&video analysis
% _Select files to fix_
[fileName,PathName,FilterIndex] = uigetfile('*.txt','MultiSelect','on');

if iscell(fileName)
    nbfiles = length(fileName);
elseif fileName ~= 0
    nbfiles = 1;
else
    nbfiles = 0;
end
fprintf (' number of files open') ;
disp(nbfiles)

if nbfiles>1
% for each file, replace 10,11,12 colums values with progressive value
for i=1:nbfiles
path=strcat(PathName,fileName{i});
disp(path)


Data = load(path);

Ts = Data(:,10);
m=length(Ts);
SubstF= (1:5:(m*5));
SubstT= (1:1:m);
Data(:,11)=SubstF;
Data(:,10)=SubstT;
Data(:,12)=SubstT;

fid = fopen(path, 'w');
[n,m] = size(Data);
for i=1:n
 for j=1:m
 fprintf(fid,'%d\t',Data(i,j));
 end
fprintf(fid,'\r\n');
end
fclose(fid);
end
else %single file
path=strcat(PathName,fileName);
disp(path)


Data = load(path);

Ts = Data(:,10);
m=length(Ts);
SubstF= (1:5:(m*5));
SubstT= (1:1:m);
Data(:,11)=SubstF;
Data(:,10)=SubstT;
Data(:,12)=SubstT;

fid = fopen(path, 'w');
[n,m] = size(Data);
for i=1:n
 for j=1:m
 fprintf(fid,'%d\t',Data(i,j));
 end
fprintf(fid,'\r\n');
end
fclose(fid);
end