function codeConversion()
%this code convert a diary to real data

import java.util.LinkedList
q = LinkedList();
file1 = fopen('standard_synthesis.txt'); %open diary

while 1
    tline1=fgets(file1);
    token=strtok(tline1);
    if strcmp(token,'STOP!')
        break;
    end
end;

fclose(file1);

template={'Right Ankle', 'Waist', 'Right Arm', 'Right Wrist', 'Left Thigh', 'Right Thigh'};
[prev,nodes,post]=strread(tline1, '%s %s %s', 'delimiter', '{}');
c=strsplit(char(nodes),', ');
%t=numel(c);
for i=1:numel(c)-1
    disp(c(i));
    %store movement number
    array1=strcmp(template,char(c(i)));
    q.addFirst(num2str(find(array1==1),'%02d'));
    %elem=c(i);
    
end

disp(q);
%t=str2num(q.getLast());

file = fopen('standard_synthesis.txt'); %open diary

start =0;

while ~start %find starting point of your diary
    tline = fgets(file);
    token = strtok(tline);
    start = strcmp(token, 'START');
end

[start subject date] = strread(tline, '%s %s %s', 'delimiter', ',');
a = char(subject);  %cell to string conversion
switch a   %find subject
    case 'M1 '
       subNum = num2str(1,'%02d');
    case 'Male '
       subNum = num2str(1,'%02d');
    case 'M2 '
       subNum = num2str(5,'%02d');
    case 'F1 '
       subNum = num2str(4,'%02d');
    case 'Female '
       subNum = num2str(4,'%02d');
end

%find the movement
stop =0;
tline = fgets(file);
token = strtok(tline);
mvmt = {'1', '2', 'Kneeling', 'Step_forward_backward', 'Walking', 'Looking_back_right', 'Grasping_floor', 'Turning_90', 'Grasping_shelf', 'Jumping', 'Step_left_right', 'Eating', 'Drinking', 'Using_phone', 'Sitting(1)', 'Sitting(2)', 'Standing(1)', 'Standing(2)', 'Sit_to_stand', 'Stand_to_sit', 'Sit_to_lie', 'Lie_to_sit',  'Basic_sitting','Basic_standing', 'Basic_lying'};
anntNum=1;

%empty old data
new=fopen('temp/new.txt', 'w');
fclose(new);

%empty folders for each sensor node
f = fopen('temp/annotation.txt', 'w');
fopen('temp/new1.txt', 'w');
fopen('temp/new2.txt', 'w');
fopen('temp/new3.txt', 'w');
fopen('temp/new4.txt', 'w');
fopen('temp/new5.txt', 'w');
fopen('temp/new6.txt', 'w');
sequence = fopen('temp/sequence.txt', 'w');
fprintf(sequence, '%s%s%s\r\n', char(subject),'  ', char(date));

while ~stop %until find STOP
    if strcmp(sprintf('\r\n'), tline) %skip emply line
        tline = fgets(file);
        token = strtok(tline);
        continue;   
    elseif strcmp(token, 'STOP!')  % if stop, break
        token
        break;
    end
    
    %find # of repetition
    [myMvmt remain] = strread(tline, '%s %s', 'delimiter', '/');
    [RBE periodType repetition] = strread(char(remain), '%s %s %d', 'delimiter', ',');  %RBE : Randon or Best or Epsilon
    if strcmp(RBE,'REx')
        ran=randi([1,15]);
    else
        RBE='B';
        ran=1;
    end
    if(ran>9)
        num=num2str(ran);
    else 
        num=num2str(ran,'%02d');
    end;
    %store movement number
    array=strcmp(mvmt, token);
    mvmtNum = num2str(find(array==1),'%02d')
    
    %for all 6 nodes
   for j=1:6
       %store node number and file name
        nodeNum = (num2str(j,'%02d'));
        fileName = char(sprintf('m00%s_s%s_m%s_n%s.txt',num, subNum, mvmtNum, nodeNum));
        
        cd ../Data;
        %find the directory of subject
        switch subNum
            case '01'
                cd Claudio
            case '05'
                cd Xianan
            case '04'
                cd Ashley
          
        end   
        %find directory for specific movement
        cd (token);
        
        %copy data file to Utility directory
        cmd1 = ['copy ', fileName];
        cmd = strcat(cmd1, ' temp.txt');
        system(cmd);
        
        for z=0:q.size()-1
            %t=q.get(z);
            if str2double(q.get(z))==j
                copyfile('temp.txt', '../../../Utility/temp/temp2.txt');
                copyfile(fileName, '../../../Data Acquisition_Data_10Mvts_7Nodes/split');
            end
        end;
        %copy video file for vibmotion tool
        %if j==1
         vidFileName = char(sprintf('m0001_s%s_m%s_c01.avi', subNum, mvmtNum));
        copyfile(vidFileName,'../../../Data Acquisition_Data_10Mvts_7Nodes/video'); 
        %end
        
        cd ../../../Utility;
        %no repetition means run only once
        
        if isempty(repetition)
            repetition = 1;
        end
        %store file as text file
        tempNew = char(sprintf('new%i.txt', j))
        cd temp
        copyfile(tempNew, 'new.txt' );
        
        % repeat for all nodes
        for i=1:repetition

           !for %f in (temp2.txt) do type "%f" >> new.txt 
          end
    % copy file to temporary file
    
    copyfile('new.txt', tempNew);
    resetNew = fopen('new.txt', 'w');
    cd ..
    
    fclose(resetNew);
    
    if j==1
      fprintf(sequence, '%s%s%d%s%s\r\n', fileName,' ', repetition,' ',char(RBE));
     
    end
  
   end
  
   %generate annotation file
   %below code is wrote by Claudio
    Data = load('temp/new1.txt');

    Ts = Data(:,10);
    m=length(Ts);
    SubstF= (1:5:(m*5));
    SubstT= (1:1:m);
    Data(:,11)=SubstF;
    Data(:,10)=SubstT;
    Data(:,12)=SubstT;

    fid = fopen('temp/new1.txt', 'w');
    [n,m] = size(Data);
    for i=1:n
     for j=1:m
         if j~=m 
            fprintf(fid,'%d\t',Data(i,j));
         else
            fprintf(fid,'%d\r\n',Data(i,j));
         end    
     end
    %fprintf(fid,'\r\n');
    end
    %i is annotation number

      fclose(fid);
       
      
    fprintf(f, '%d,', i);
    fprintf(f, '%d\r\n', anntNum);
    %fclose(f);
  
    
    anntNum = anntNum +1;
    %READ ANOTATION NUMBER
   
       
    tline = fgets(file);
    token = strtok(tline);
    
end


    %total number of annotations
  
  for k=1:6
    tempNew2 = sprintf('temp/new%i.txt', k);
    Data = load(tempNew2);

    Ts = Data(:,10);
    m=length(Ts);
    SubstF= (1:5:(m*5));
    SubstT= (1:1:m);
    Data(:,11)=SubstF;
    Data(:,10)=SubstT;
    Data(:,12)=SubstT;

    fid2 = fopen(tempNew2, 'w');
    [n,m] = size(Data);
    
    for i=1:n
     for j=1:m
         if j~=m 
            fprintf(fid2,'%d\t',Data(i,j));
         else
            fprintf(fid2,'%d\r\n',Data(i,j));
         end    
     end
    %fprintf(fid,'\r\n');
    

    end
        fclose(fid2);
    %i is annotation number
  end
    
    fclose(f);
    
    %copy file to "Data Acquisition_Data_10Mvts_7Nodes" folder to visualize
  %  
 % t=q.size();
  %m=q.get(0);
 % m2=q.get(1);
    for r=1:6
         nodeNum2= (num2str(r,'%02d'))
         for z=0:q.size()-1
            %t=q.get(z);
            if str2double(q.get(z))==r
                fileName2 = char(sprintf('../Data Acquisition_Data_10Mvts_7Nodes/split/m9999_s99_m99_n%s.txt', nodeNum2))
                fileName3 = char(sprintf('temp/new%i.txt', r))
                copyfile(fileName3, fileName2);
            end
         end
    end
    %copy to data aqusition folder
  copyfile('temp/annotation.txt', '../Data Acquisition_Data_10Mvts_7Nodes/annotations/default/m9999_s99_m99.txt');
  fclose(sequence);
  copyfile('temp/sequence.txt', '../Data Acquisition_Data_10Mvts_7Nodes/split');
  
  disp('done! List output file below'); 
  msgbox('Data output under Split and Video folder','Attention');
  dir( '../Data Acquisition_Data_10Mvts_7Nodes/split');
  dir( '../Data Acquisition_Data_10Mvts_7Nodes/video');
  open('../Data Acquisition_Data_10Mvts_7Nodes/split/sequence.txt');
    %random template, sensor node
